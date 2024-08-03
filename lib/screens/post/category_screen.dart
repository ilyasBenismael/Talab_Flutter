import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ecommerce/screens/post/post_screen.dart';
import 'package:ecommerce/screens/widgets/postWidget.dart';


class CategoryScreen extends StatefulWidget {
  final String categoryId;
  final String categoryName;
  const CategoryScreen({Key? key, required this.categoryId, required this.categoryName}) : super(key: key);

  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  late Future<QuerySnapshot> _postsFuture;

  @override
  void initState() {
    super.initState();
    _postsFuture = FirebaseFirestore.instance
        .collection('posts')
        .where('categories', arrayContains: widget.categoryId)
        .get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF282828),
        title: Text(widget.categoryName),
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: _postsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No posts available in this category.'));
          } else {
            final posts = snapshot.data!.docs;
            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
              ),
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index].data() as Map<String, dynamic>;
                return GestureDetector(
                  onTap: () {
                    goToPost(context, posts[index].id);
                  },
                  child: PostWidget(postInfos: post),
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
      MaterialPageRoute(
        builder: (context) => PostScreen(postId: postId),
      ),
    );
  }
}
