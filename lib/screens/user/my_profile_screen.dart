import 'package:ecommerce/screens/post/post_screen.dart';
import 'package:ecommerce/screens/widgets/postWidget.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});

  @override
  _MyProfileScreenState createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  bool _isLoading = false;
  String id = FirebaseAuth.instance.currentUser!.uid;
  List<DocumentSnapshot>? posts = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(id).get(),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.settings),
                        onPressed: () {
                          Navigator.pushNamed(context, '/settings');
                        },
                      ),
                    ],
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
                                    ? CachedNetworkImage(
                                        imageUrl: userData?['imageUrl'],
                                        placeholder: (context, url) =>
                                            Container(),
                                        errorWidget: (context, url, error) =>
                                            Container(),
                                        fit: BoxFit.cover,
                                        width: 80,
                                        height: 80,
                                      )
                                    : Container(),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          userData?['note'] != null
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
                          SizedBox(
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
                  const SizedBox(height: 16),
                  _isLoading ? const CircularProgressIndicator() : Container(),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {},
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all<Color>(Colors.blue)),
                        icon: const Icon(
                          Icons.chat,
                          color: Colors.white,
                          size: 16,
                        ),
                        // Icon
                        label: const Text(
                          'Chats',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Colors.white, // Text color for "Chats"
                          ),
                        ), // Text label
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(context, '/favorites');
                        },
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all<Color>(Colors.red)),
                        icon: const Icon(
                          Icons.favorite,
                          color: Colors.white,
                          size: 16,
                        ),
                        label: const Text(
                          'Favs',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.white, // Text color for "Favorites"
                          ),
                        ), // Text label
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/addPost');
                        },
                        child: const Text('Add Post'),
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
                  const SizedBox(height: 30),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('posts')
                          .where('userId', isEqualTo: id)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        } else if (snapshot.hasData &&
                            snapshot.data!.docs.isEmpty) {
                          return const Text('No posts');
                        } else if (snapshot.hasData && snapshot.data != null) {
                          posts = snapshot.data!.docs;
                          return GridView.builder(
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
              Text(':( , ${snapshot.error ?? 'something unexpected happened'}'),
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
      ),
    );
  }

  void goToPost(BuildContext context, String id) async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PostScreen(postId: id)),
    );
  }
}
