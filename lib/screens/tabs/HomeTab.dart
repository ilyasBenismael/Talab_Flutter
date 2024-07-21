import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce/screens/widgets/postWidget.dart';
import 'package:ecommerce/screens/post/post_screen.dart';
import '../post/category_screen.dart';


class HomeTab extends StatefulWidget {
  @override
  HomeTabState createState() => HomeTabState();
}

class HomeTabState extends State<HomeTab> with AutomaticKeepAliveClientMixin {
  Future<Map<String, Map<String, dynamic>>>? _categoriesWithPostsFuture;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _categoriesWithPostsFuture = fetchCategoriesAndPosts();
  }

  Future<void> _refreshData() async {
    setState(() {
      _categoriesWithPostsFuture = fetchCategoriesAndPosts();
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: FutureBuilder<Map<String, Map<String, dynamic>>>(
          future: _categoriesWithPostsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No categories or posts found'));
            } else {
              final categoriesWithPosts = snapshot.data!;
              return ListView(
                children: categoriesWithPosts.entries.map((entry) {
                  final categoryName = entry.key;
                  final categoryContent = entry.value;
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              categoryName,
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                            GestureDetector(
                              onTap: () => goToCateg(context, categoryContent['categoryId']),
                              child: const Text(
                                'See All',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Container(
                          height: 140,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: categoryContent['posts'].length,
                            itemBuilder: (context, index) {
                              final post = categoryContent['posts'][index];
                              return GestureDetector(
                                onTap: () {
                                  goToPost(context, post['id']);
                                },
                                child: PostWidget(postInfos: post),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  );
                }).toList(),
              );
            }
          },
        ),
      ),
    );
  }

  Future<Map<String, Map<String, dynamic>>> fetchCategoriesAndPosts() async {
    try {
      QuerySnapshot categorySnapshot = await FirebaseFirestore.instance.collection('categories').get();
      Map<String, Map<String, dynamic>> categoriesWithPosts = {};

      for (var categoryDoc in categorySnapshot.docs) {
        String categoryId = categoryDoc.id;
        Map<String, dynamic> categoryData = categoryDoc.data() as Map<String, dynamic>;

        QuerySnapshot postSnapshot = await FirebaseFirestore.instance
            .collection('posts')
            .where('categories', arrayContains: categoryId)
            .get();

        List<Map<String, dynamic>> posts = postSnapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return {
            ...data, // Spread the existing data
            'id': doc.id, // Add the document ID as a new key
          };
        }).toList();

        categoriesWithPosts[categoryData['name']] = {
          'categoryId': categoryId,
          'posts': posts,
        };
      }
      return categoriesWithPosts;
    } catch (e) {
      print('Error fetching categories and posts: $e');
      throw e;
    }
  }

  void goToPost(BuildContext context, String postId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PostScreen(postId: postId)),
    );
  }

  void goToCateg(BuildContext context, String categId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CategoryScreen(categoryId: categId)),
    );
  }


}


