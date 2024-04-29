import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce/screens/widgets/postWidget.dart';
import 'package:ecommerce/screens/post/postScreen.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

class HomeTab extends StatefulWidget {
  @override
  _HomeTabState createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with AutomaticKeepAliveClientMixin {
  late Future _categoriesFuture;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _categoriesFuture =
        FirebaseFirestore.instance.collection('categories').get();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return LiquidPullToRefresh(
      onRefresh: () async {
        await Future.delayed(
            Duration(milliseconds: 50)); // Simulate loading for 2 seconds.
        setState(() {}); // Trigger a rebuild to refresh the content.
      },
      child: FutureBuilder(
        future: _categoriesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final categories = snapshot.data!.docs;
            return ListView.builder(
              itemCount: categories.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(3, 15, 3, 60),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(categories[index].data()['name'],
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold)),
                      Container(
                        height: 140,
                        child: FutureBuilder(
                          future: FirebaseFirestore.instance
                              .collection('posts')
                              .where('categories',
                                  arrayContains: categories[index].id)
                              .get(),
                          builder: (context, postSnapshot) {
                            if (postSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Text('waiting');
                            } else if (postSnapshot.hasError) {
                              return Center(
                                  child: Text('Error: ${postSnapshot.error}'));
                            } else if (postSnapshot.data == null) {
                              return const Center(
                                  child: Text('no posts in this category'));
                            } else {
                              final posts = postSnapshot.data!.docs;
                              return ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: posts.length,
                                itemBuilder: (context, index) {
                                  final post = posts[index].data()
                                      as Map<String, dynamic>;
                                  return GestureDetector(
                                      onTap: () {
                                        goToPost(context, posts[index].id);
                                      },
                                      child: PostWidget(postInfos: post));
                                },
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }



  void goToPost(BuildContext context, String postId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PostScreen(postId: postId)),
    );
  }
}
