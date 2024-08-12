import 'package:ecommerce/screens/comments/comments_screen.dart';
import 'package:ecommerce/screens/post/edit_post_screen.dart';
import 'package:ecommerce/services/UserService.dart';
import 'package:ecommerce/services/postService.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../user/other_profile_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';

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
  bool _isLoading = false; //only delete method has hand on this var
  ValueNotifier<int> favState =
      ValueNotifier<int>(0); //favstat is int initialized with 0

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF282828),
        title: Text('Post Details'),
      ),
      body: FutureBuilder(
        future: getPostAndUser(widget.postId),
        builder: (context, postSnapshot) {
          if (postSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (postSnapshot.data == 1) {
            return SingleChildScrollView(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: AspectRatio(
                        aspectRatio: 1.0,
                        child: ClipRRect(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(8)),
                          child: Container(
                              width: double.infinity,
                              color: Colors.grey,
                              child: CachedNetworkImage(
                                imageUrl: postData!['imageUrl'] ?? '',
                                placeholder: (context, url) => Container(),
                                errorWidget: (context, url, error) =>
                                    Container(),
                                fit: BoxFit.cover,
                              )),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            postData!['price'] ?? "",
                            style: const TextStyle(
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
                    const SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(11.0, 4, 8, 3),
                      child: Text(
                        postData!['title'] ?? "",
                        style: const TextStyle(
                            fontSize: 24.0, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(11.0, 8, 8, 3),
                      child: Text(
                        postData!['description'] ?? "",
                        style: const TextStyle(fontSize: 16.0),
                      ),
                    ),
                    SizedBox(
                      height: 40,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                          onTap: () {
                            goToUser(context, postData!['userId'] ?? "");
                          },
                          child: ClipRRect(
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(16),
                              bottomRight: Radius.circular(16),
                              topLeft: Radius.circular(16),
                              topRight: Radius.circular(16),
                            ),
                            child: Container(
                              padding: EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                // Border color
                              ),
                              child: Row(
                                children: [
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
                                        child: userData!['imageUrl'] != null
                                            ? CachedNetworkImage(
                                                imageUrl:
                                                    userData!['imageUrl'] ?? '',
                                                placeholder: (context, url) =>
                                                    Container(),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        Container(),
                                                width: 50,
                                                height: 50,
                                                fit: BoxFit.cover,
                                              )
                                            : Container(),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 16),
                                  Text(
                                    userData!['name'] ?? "",
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )),
                    ),
                    const SizedBox(width: 16),
                    InkWell(
                      onTap: () => goToComments(context, widget.postId),
                      child: Padding(
                        padding: const EdgeInsets.all(13.0),
                        child: Text(
                          '${postData!['comments'] ?? ''} comments',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 50),
                    if (postData!['userId'] == currentuid && currentuid != null)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(height: 30, width: 10),
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => goToEditPost(widget.postId),
                            tooltip: 'Edit',
                          ),
                          const SizedBox(height: 30, width: 10),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () =>
                                _showDeleteConfirmationDialog(context),
                            tooltip: 'Delete',
                          ),
                        ],
                      )
                  ]),
            );
          } else {
            return const Center(child: Text('Post not Available'));
          }
        },
      ),
    );
  }

  void goToUser(BuildContext context, String userId) {
    //if the currentuser is the postowner he can't visit his profil this way,
    //if he is not auth then currentuid==null, so he can visit it
    if (userId != currentuid && !_isLoading) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => OtherProfileScreen(userId: userId)),
      );
    }
  }

  //////////////////////////////////////////////////////////////////////////////////////////////////

  void goToComments(BuildContext context, postId) {
    if(_isLoading){
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CommentsScreen(postId: postId)),
    );
  }

  //////////////////////////////////////////////////////////////////////////////////////////////////

  //we get the data of the post and then we get the data of the considered user
  //if they are null an error occured we don't return 1
  Future<int> getPostAndUser(String postId) async {
    try {
      //currentuid will be null if no user is auth
      currentuid = FirebaseAuth.instance.currentUser?.uid;
      userAuthState = await UserService
          .checkUserAuth(); //checkUserAuth() returns 2 if the user is authenticated
      postData = await PostService.getPostById(postId);
      userData = await UserService.getUserById(postData!["userId"]);

      //if the user is auth we get his favposts
      if (userAuthState == 2) {
        favPosts = await PostService.getFavoritePostsIds(currentuid!);
      }

      //if any of these values is null means there was an error
      if (postData == null || userData == null || favPosts == null) {
        return 0;
      }
      return 1;
    } catch (e) {
      print(e);
      return 0;
    }
  }

  //we run the favclick method asynch to not block the process
  void handleFav() async {
    if (_isLoading) {
      return;
    }
    try {
      //if user is not auth we return
      if (userAuthState != 2) {
        toastMsg('u need to login');
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
          favState.value =
              11; //when changing the value of favstate the heart will be rebuilt
          await userRef.update({'favPosts': favPosts});
          //if the postid is removed from favposts and not from firestore this won't cause a prob,
          //cause in next tap we will add it again to favposts and we will update in firestore with the same value as before but no prob
        } else {
          favPosts!.add(widget.postId);
          favState.value = 10;
          await userRef.update({'favPosts': favPosts});
        }
        isHeartClickable = true;
      }
      return;
    } catch (e) {
      //if any error we will leave making sure that the heart is clickable again
      isHeartClickable = true;
      print(e);
      return;
    }
  }

  toastMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  //can't edit post if u not the post owner
  goToEditPost(postId) {
    if (postData!['userId'] == currentuid && currentuid != null && !_isLoading) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => EditPostScreen(postId: postId)),
      );
    }
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    if (!mounted) {
      return;
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to delete this post?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                deletePost(widget.postId); // Call delete function
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }







  Future<void> deletePost(String postId) async {

    //if still deleting from old click and the user auth isn't post owner we go back
    if (_isLoading || postData!['userId'] != currentuid) {
      return;
    }

    //when deleting, can't add to favorite or edit/delete the post
    _isLoading = true;

    int a = await PostService()
        .deletePostAndComments(postId, postData!['imageUrl']);
    if (a == 1) {
      print('deleted succesfully');
    } else {
      print('error occured');
    }
    //we return and show either done or  not done msg
    if (mounted) {
      Navigator.of(context).pop();
    }
    _isLoading = false;
  }



}
