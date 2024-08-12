import 'package:ecommerce/services/postService.dart';
import 'package:flutter/material.dart';
import 'package:ecommerce/screens/post/post_screen.dart';
import 'package:ecommerce/screens/post/post_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FavoritesScreen extends StatefulWidget {
  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<Map<String, dynamic>>? favPosts;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF282828),
        title: Text('Your favorites'),
      ),
      body: FutureBuilder(
        future: getUserFavs(),
        builder: (BuildContext context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            if (snapshot.data == -2) {
              return const Center(child: Text('You have no favorite posts'));
            }
            else if (snapshot.data == 1){
              return GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                ),
                itemCount: favPosts!.length,
                itemBuilder: (context, index) {
                  final post =  favPosts![index] as Map<String, dynamic>;
                  return GestureDetector(
                      onTap: () {
                       goToPost(context, favPosts![index]['id']);
                      },
                      child: PostWidget(postInfos: post));
                },
              );
            } else {
              return const Center(child: Text('errooooor'));
            }
          } else {
            return const Center(child: Text('error'));}
        }
      ),
    );
  }












  Future<int> getUserFavs() async {
      favPosts = await PostService.getFavoritePosts(
          FirebaseAuth.instance.currentUser!.uid);
      if (favPosts == null) {
        return -1;
      }
      if (favPosts!.isEmpty) {
        return -2;
      }
      return 1;

  }


  void goToPost(BuildContext context, String id) async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PostScreen(postId: id)),
    );
  }



}
