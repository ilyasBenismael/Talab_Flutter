import 'package:ecommerce/services/UserService.dart';
import 'package:ecommerce/services/postService.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../user/other_profile_screen.dart';

class PostScreen extends StatefulWidget {
  final String postId;

  PostScreen({required this.postId});

  @override
  _PostScreenState createState() => _PostScreenState();
}



class _PostScreenState extends State<PostScreen> {
  final CollectionReference postsCollection =
      FirebaseFirestore.instance.collection('posts');
  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');
  Map<String, dynamic>? postData;
  Map<String, dynamic>? userData;
  List? favPosts = [];
  bool isHeartClickable = true;
  int? userAuthState;
  String? currentuid;
  ValueNotifier<int> favState = ValueNotifier<int>(0);

  // int pageState = 0;
  // 0 ; loading, 1 error occured, 3 all alright


  @override
  void initState() {
    super.initState();
    getPostAndUser(widget.postId);
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Post Details'),
      ),
      body: FutureBuilder(
        future: getPostAndUser(widget.postId),
        builder: (context, postSnapshot) {
          if (postSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (postSnapshot.hasError) {
            return Center(child: Text('Error: ${postSnapshot.error}'));
          } else if (postSnapshot.data != 1) {
            return Center(child: Text('error occured'));
          } else {
            return SingleChildScrollView(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: AspectRatio(
                        aspectRatio: 1.0,
                        child: ClipRRect(
                          borderRadius: const BorderRadius.all(Radius.circular(8)),
                          child: Container(
                            width: double.infinity,
                            color: Colors.grey,
                            child: Image.network(postData!['imageUrl'],
                                fit: BoxFit.cover),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            postData!['price'],
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          GestureDetector(
                            onTap: handleFav,
                            child: ValueListenableBuilder<int>(
                              valueListenable: favState,
                              builder: (context, favState, child) {
                                return Icon(
                                  size: 40,
                                  favPosts!.contains(widget.postId)
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: Colors.red,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(11.0, 4, 8, 3),
                      child: Text(
                        postData!['title'],
                        style: TextStyle(
                            fontSize: 24.0, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(11.0, 8, 8, 3),
                      child: Text(
                        postData!['description'],
                        style: TextStyle(fontSize: 16.0),
                      ),
                    ),
                    SizedBox(
                      height: 40,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        onTap: () {
                          goToUser(context, postData!['userId']);
                        },
                        child: Row(children: [
                          Stack(
                            children: [
                              ClipOval(
                                child: Image.asset(
                                  'images/profileX.jpeg',
                                  width: 50,
                                  height: 50,
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
                              // Use SizedBox if no image is picked
                            ],
                          ),
                          SizedBox(width: 16),
                          Text(
                            userData!['name'],
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ]),
                      ),
                    ),
                  ]),
            );
          }
        },
      ),
    );
  }






  void goToUser(BuildContext context, String userId) {
    //if the currentuser is the postowner he can't visit his profil this way,
    //if he is not auth then currentuid==null, so he can visit it
    if (userId != currentuid) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => OtherProfileScreen(userId: userId)),
      );
    }
  }







  //we get the data of the post and then we get the data of the considered user
  //if they are null/ an error occured we don't return 1
  Future<int> getPostAndUser(String postId) async {
    try {
      //currentuid will be null if no user is auth
      currentuid = FirebaseAuth.instance.currentUser?.uid;
      userAuthState = await UserService.checkUserAuth();
      postData = await PostService.getPostById(postId);
      userData = await UserService.getUserById(postData!["userId"]);
      if (userAuthState == 2) {
        favPosts = await PostService.getFavoritePostsIds(currentuid!);
      }
      if (postData == null || userData == null || favPosts == null) {
        return 0;
      }
      return 1;
    } catch (e) {
      print("catch error");
      return 0;
    }
  }







  void handleFav() async {
    //if user is not auth we return
    if (userAuthState != 2) {
      print('u need to auth');
      return;
    }
    //if heart is still handling from a previous click, we return
    if (isHeartClickable) {
      isHeartClickable = false;
      DocumentReference userRef = FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid);
      //if favposts contains postId we remove, else we add
      if (favPosts!.contains(widget.postId)) {
        favPosts!.remove(widget.postId);
        favState.value = 11;
        await userRef.update({'favPosts': favPosts});
        //if the postid is removed from favposts and not from firestore this won't cause a prob,
        //in the next addtofav it will be working again
      } else {
        favPosts!.add(widget.postId);
        favState.value = 10;
        await userRef.update({'favPosts': favPosts});
      }
     // setState(() {});
      isHeartClickable = true;
    }
    return;
  }





}
