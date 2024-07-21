import 'package:ecommerce/screens/post/post_screen.dart';
import 'package:ecommerce/screens/widgets/postWidget.dart';
import 'package:ecommerce/services/postService.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class OtherProfileScreen extends StatefulWidget {
  final String userId;

  OtherProfileScreen({required this.userId});

  @override
  _OtherProfileScreenState createState() => _OtherProfileScreenState();
}

class _OtherProfileScreenState extends State<OtherProfileScreen> {
  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');
  List<DocumentSnapshot>? posts;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('user profile'),
        ),
        body: FutureBuilder(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(widget.userId)
              .get(),
          builder:
              (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasData) {
              Map<String, dynamic>? userData =
                  snapshot.data!.data() as Map<String, dynamic>?;
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 30,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          children: [
                            Stack(
                              children: [
                                ClipOval(
                                  child: Image.asset(
                                    'images/profileX.jpeg',
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                ClipOval(
                                  child: userData?['imageUrl'] != null
                                      ? Image.network(
                                          userData?['imageUrl'] ?? '',
                                          width: 80,
                                          height: 80,
                                          fit: BoxFit.cover,
                                        )
                                      : Container(),
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            Row(children: [
                              const Icon(
                                Icons.star,
                                color: Colors.yellow,
                                size: 17,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                userData?['note'].toString() ?? "__",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11.5,
                                  color: Colors.black,
                                ),
                              ),
                            ])
                          ],
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userData?['name'] ?? '',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              userData?['city'] ?? '',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              userData?['number'] ?? '',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Container(
                              width: 240,
                              child: Text(
                                userData?['description'] ?? '',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {},
                          style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Colors.blue)),
                          icon: const Icon(
                            Icons.chat,
                            color: Colors.white,
                            size: 16,
                          ),
                          label: const Text(
                            'Message',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: Colors.white, // Text color for "Chats"
                            ),
                          ), // Text label
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            openMaps(userData?['location']);
                          },
                          style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all<Color>(Colors.red)),
                          icon: const Icon(
                            Icons.location_on_outlined,
                            color: Colors.white,
                            size: 16,
                          ),
                          label: const Text(
                            'Location',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Colors.white, // Text color for "Favorites"
                            ),
                          ), // Text label
                        ),
                        ElevatedButton.icon(
                          onPressed: () {},
                          style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Colors.green)),
                          icon: const Icon(
                            Icons.rate_review,
                            color: Colors.white,
                            size: 16,
                          ),
                          label: const Text(
                            'Rate chef',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Colors.white, // Text color for "Favorites"
                            ),
                          ), // Text label
                        ),
                      ],
                    ),
                    const SizedBox(height: 50),
                    const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Posts',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.black,
                                decoration:
                                    TextDecoration.underline, // Underline style
                              ))
                        ]),
                    const SizedBox(height: 20),
                    Expanded(
                      child: FutureBuilder<List<DocumentSnapshot>>(
                        future: getUserPosts(widget.userId),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasData) {
                            return GridView.builder(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                              ),
                              itemCount: posts!.length,
                              itemBuilder: (context, index) {
                                final post = posts![index].data()
                                    as Map<String, dynamic>;
                                return GestureDetector(
                                  onTap: () {
                                    goToPost(context, posts![index].id);
                                  },
                                  child: PostWidget(postInfos: post),
                                );
                              },
                            );
                          } else {
                            return Center(
                                child: Text(
                                    ':( , ${snapshot.error ?? 'something unexpected happened'}'));
                          }
                        },
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return Column(children: [
                Text(
                    ':( , ${snapshot.error ?? 'something unexpected happened'}'),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    setState(() {});
                  },
                  child: const Text('Retry'),
                ),
              ]);
            }
          },
        ));
  }

  Future<List<DocumentSnapshot>> getUserPosts(String id) async {
    posts = await PostService.getPostsByUser(id);
    posts ??= [];
    return posts!;
  }

  void goToPost(BuildContext context, String id) async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PostScreen(postId: id)),
    );
  }



  void openMaps(List? location) async {
    try {
      if (location != null) {
        String url =
            'https://www.google.com/maps/search/?api=1&query=${location[0]},${location[1]}';
        if (await canLaunchUrl(Uri.parse(url))) {
          launchUrl(Uri.parse(url));
        } else {
          print('can\'t launch url');
        }
      } else {
        print("location is null");
      }
    } catch (e) {
      print(e.toString());
    }
  }



}
