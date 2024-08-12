import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce/screens/post/post_widget.dart';
import 'package:ecommerce/screens/post/post_screen.dart';
import '../post/category_screen.dart';


class HomeTab extends StatefulWidget {
  @override
  HomeTabState createState() => HomeTabState();
}

class HomeTabState extends State<HomeTab> with AutomaticKeepAliveClientMixin {
  late Future<Map<String, Map<String, dynamic>>> _categoriesWithPostsFuture;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    //we initialize the futureVar _categoriesWithPostsFuture with the fetch mthd (at the beginning the futureVar
    //will be in waiting state before the methode is completed and a value is returned
    _categoriesWithPostsFuture = fetchCategoriesAndPosts();
  }

  //in refresh we call this method which sets _categoriesWithPostsFuture to a new value then we show page again
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
        backgroundColor: const Color(0xFF282828),
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
                              onTap: () => goToCateg(context, categoryContent['categoryId'], categoryName),
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
                        const SizedBox(height: 8),
                        SizedBox(
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
      //this will hold everything :
      Map<String, Map<String, dynamic>> categoriesWithPosts = {};

      //we get categories
      QuerySnapshot categorySnapshot = await FirebaseFirestore.instance.collection('categories').get();


      //biggest loop : we loop on all the categories and :
      for (var categoryDoc in categorySnapshot.docs) {
        //1-get the catgoryid
        String categoryId = categoryDoc.id;
        Map<String, dynamic> categoryData = categoryDoc.data() as Map<String, dynamic>;

        //2-we get the postsnapchot with the categoryId
        QuerySnapshot postSnapshot = await FirebaseFirestore.instance
            .collection('posts')
            .where('categories', arrayContains: categoryId).orderBy('timeStamp', descending: true)
            .limit(5)
            .get();

        //3-for each postdoc we get its data and we add doc-id and make it one map representing the post,
        //ofc in the end of the map function we call toList() to make a list of post maps
        List<Map<String, dynamic>> posts = postSnapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return {
            ...data, // Spread the existing data
            'id': doc.id, // Add the document ID as a new key
          };
        }).toList();

        //for each categ we put its name as key and the value is : map with the category id and the list of posts
        categoriesWithPosts[categoryData['name']] = {
          'categoryId': categoryId,
          'posts': posts,
        };
      }
      //! post id and categ id can't be null (we will get error if it's null)
      return categoriesWithPosts;
    } catch (e) {
      //all this is inside try catch if any thing was null we will get error once we call a function on it
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




  void goToCateg(BuildContext context, String categId, String categName) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CategoryScreen(categoryId: categId, categoryName : categName)),
    );
  }






}


