import 'package:flutter/material.dart';
import 'package:ecommerce/screens/post/post_screen.dart';
import 'package:ecommerce/screens/post/post_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SearchTab extends StatefulWidget {
  const SearchTab({super.key});

  @override
  SearchTabState createState() => SearchTabState();
}

class SearchTabState extends State<SearchTab>
    with AutomaticKeepAliveClientMixin {
  final TextEditingController _searchController = TextEditingController();
  Future<List<DocumentSnapshot>?>? _futurePosts;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF282828),
        title: const Text('Search Screen'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Search...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onChanged: (text) => updateSearch(text),
            ),
          ),
          if (_futurePosts == null)
            Expanded(
              child: FutureBuilder<List<DocumentSnapshot>?>(
                future: _futurePosts,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError || snapshot.data == null) {
                    return Container();
                  } else if (snapshot.data!.isEmpty) {
                    return const Center(child: Text('No results found'));
                  } else {
                    final posts = snapshot.data!;
                    return GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
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
            ),
        ],
      ),
    );
  }

  //////////////////////////////////////////////// UPDATE SEARCH /////////////////////////////////////////////////////////////

  void updateSearch(String text) {
    text = text.trim();
    if (text.length > 2) {
      _futurePosts = getPostsFromSearch(text);
    } else {
      _futurePosts = null;
    }
    setState(() {});
  }

  //////////////////////////////////////////////////// GET POSTS /////////////////////////////////////////////////////////

  Future<List<DocumentSnapshot>?> getPostsFromSearch(String query) async {
    try {
      List<String> keywords =
          query.split(' ').where((keyword) => keyword.isNotEmpty).toList();

      Query queryRef = FirebaseFirestore.instance.collection('posts');

      // Create a query with array-contains for each keyword
      for (String keyword in keywords) {
        queryRef = queryRef.where('keywords', arrayContains: keyword);
      }

      QuerySnapshot querySnapshot = await queryRef.get();
      return querySnapshot.docs;
    } catch (e) {
      return null;
    }
  }

  /////////////////////////////////////////////// GO TO POST ////////////////////////////////////////////////////////////////

  void goToPost(BuildContext context, String id) async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PostScreen(postId: id)),
    );
  }



}



//ay post tla7 knrevisiw tags o kitktbo mzn o kit7ydo wla ytzado chi whdin



//categories : more general
//tags : details