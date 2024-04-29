import 'package:ecommerce/screens/post/postScreen.dart';
import 'package:ecommerce/screens/widgets/postWidget.dart';
import 'package:ecommerce/services/postService.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/UserService.dart';
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
  Map<String, dynamic>? userData;

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
          future: getUserData(widget.userId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (snapshot.data != 1) {
              return Center(child: Text('error occured'));
            } else {
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
                                  child: userData!['imageUrl'] != null
                                      ? Image.network(
                                          userData!['imageUrl'] ?? '',
                                          width: 80,
                                          height: 80,
                                          fit: BoxFit.cover,
                                        )
                                      : Container(),
                                ),
                                // Use SizedBox if no image is picked
                              ],
                            ),
                            const SizedBox(height: 5),
                            userData!['note'] != null
                                ? Row(children: [
                                    const Icon(
                                      Icons.star,
                                      color: Colors.yellow,
                                      size: 17,
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      userData!['note'].toString(),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11.5,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ])
                                : Container(),
                          ],
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userData!['name'] ?? '',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              userData!['city'] ?? '',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              userData!['number'] ?? '',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Container(
                              width: 240,
                              child: Text(
                                userData!['description'] ?? '',
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
                          // Icon
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
                            openMaps();
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
                    SizedBox(height: 50),
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
                    SizedBox(height: 20),
                    Expanded(
                      child: GridView.builder(
                        shrinkWrap: false,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                        ),
                        itemCount: posts!.length,
                        itemBuilder: (context, index) {
                          final post =
                              posts![index].data() as Map<String, dynamic>;
                          return GestureDetector(
                              onTap: () {
                                goToPost(context, posts![index].id);
                              },
                              child: PostWidget(postInfos: post));
                        },
                      ),
                    ),
                  ],
                ),
              );
            }
          },
        ));
  }


  //we get the userdata then the posts of the user and if everything is good we return 1
  Future<int> getUserData(String userId) async {
    try {
      userData = await UserService.getUserById(userId);
      posts = await PostService.getPostsByUser(userId);
      if (userData == null || posts == null) {
        return 0;
      }
      return 1;
    } catch (e) {
      return 0;
    }
  }

  void goToPost(BuildContext context, String id) async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PostScreen(postId: id)),
    );
  }




  void openMaps() async {
    try {
      if (userData?['location'] != null) {
        String url = 'https://www.google.com/maps/search/?api=1&query=${userData?['location'][0]},${userData?['location'][1]}';
        if (await canLaunchUrl(Uri.parse(url))) {
          await launchUrl(Uri.parse(url));
        } else {
          print('can\'t launch url');
        }
      }
    } catch (e) {
      print('can\'t launch url');
    }
  }




}
