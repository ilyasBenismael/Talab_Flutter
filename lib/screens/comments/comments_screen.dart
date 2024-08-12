import 'package:ecommerce/screens/comments/comment_widget.dart';
import 'package:ecommerce/services/commentService.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CommentsScreen extends StatefulWidget {
  final String postId;

  const CommentsScreen({super.key, required this.postId});

  @override
  CommentsScreenState createState() => CommentsScreenState();
}

class CommentsScreenState extends State<CommentsScreen> {
  final TextEditingController _commentController = TextEditingController();

  bool _isLoading = false;
  List<Map<String, dynamic>> commentsWithUser = [];
  User? currentUser;

  @override
  void initState() {
    super.initState();
    currentUser = FirebaseAuth.instance.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF282828),
        title: const Text('Comments'),
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder(
              future: getComments(widget.postId),
              builder: (context, postSnapshot) {
                if (postSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (postSnapshot.hasData && postSnapshot.data == 1) {
                  return ListView.builder(
                    itemCount: commentsWithUser.length,
                    itemBuilder: (context, index) {
                      String commentData =
                          commentsWithUser[index]['value'] ?? "";
                      String userId = commentsWithUser[index]['userId'] ?? "";
                      String commentId =
                          commentsWithUser[index]['commentId'] ?? "";
                      var userData = commentsWithUser[index]['user'];
                      return GestureDetector(
                          onLongPress: () {
                            _showDeleteDialog(context, commentId, userId);
                          },
                          child: CommentWidget(
                            commentData: commentData,
                            userData: userData,
                          ));
                    },
                  );
                } else {
                  return const Center(child: Text('can\'t show comments'));
                }
              },
            ),
          ),
          if (currentUser != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: InputDecoration(
                        hintText: 'Write a comment...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  ElevatedButton(
                    onPressed: addComment,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    child: const Text('Send'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

//////////////////////////////////////////////////// GET COMMENT /////////////////////////////////////////////////////////////////

  Future<int> getComments(String postId) async {
    //if getComments is not finished then we can't add a new comment
    _isLoading = true;
    //we make the comments list empty cause we might be fetching them again
    //we put them in this safe place [commentsWithUser2] in case an error occured to show old comments
    List<Map<String, dynamic>> commentsWithUser2 = commentsWithUser;
    commentsWithUser = [];
    try {
      //we first get the comments
      QuerySnapshot commentsSnapshot = await FirebaseFirestore.instance
          .collection('comments')
          .where('postId', isEqualTo: postId)
          .orderBy('timeStamp', descending: true)
          .get();

      // Iterate through each comment document and save it as a map
      for (QueryDocumentSnapshot commentDoc in commentsSnapshot.docs) {
        Map<String, dynamic> commentData =
            commentDoc.data() as Map<String, dynamic>;
        commentData['commentId'] = commentDoc.id;

        // Fetch the user who puts the comment
        DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(commentData['userId'])
            .get();

        //if he exists we get him as map and add him as element to the comment data
        if (userSnapshot.exists) {
          // Add the user details to the comment data
          Map<String, dynamic> userData =
              userSnapshot.data() as Map<String, dynamic>;
          commentData['user'] = userData;

          // Add the comment with user details to the list
          commentsWithUser.add(commentData);
        } else {
          commentsWithUser = commentsWithUser2;
          _isLoading = false;
          return -1;
        }
      }
      print(commentsWithUser.length);
      _isLoading = false;
      return 1;
    } catch (e) {
      _isLoading = false;
      commentsWithUser = commentsWithUser2;
      print(e);
      return -1;
    }
  }

//////////////////////////////////////////////////////// ADD COMMENT /////////////////////////////////////////////////////////////////

  void addComment() async {
    //if still loading we return
    if (_isLoading) {
      return;
    }
    _isLoading = true;

    //we first check emptiness
    String value = _commentController.text.trim();
    if (value.isEmpty) {
      _isLoading = false;
      return;
    }

    //just re-check user connection :) then we add the comment, if all good : make the text empty,
    //increase post nbrofcmnts and refresh
    if (currentUser != null) {
      int a = await CommentService.addComment(
          widget.postId, value, currentUser!.uid);
      if (a == 1) {
        FirebaseFirestore.instance
            .collection('posts')
            .doc(widget.postId)
            .update({'comments': (commentsWithUser.length + 1)});
        _commentController.text = '';
        setState(() {});
      } else {
        print('error');
      }
    }
    _isLoading = false;
  }

  ///////////////////////////////////////////////// show_delete_dialogue ////////////////////////////////////////////////////////

  void _showDeleteDialog(
      BuildContext context, String commentId, String userId) {
    if (currentUser != null && currentUser?.uid == userId && !_isLoading) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Delete Comment'),
            content:
                const Text('Are you sure you want to delete this comment?'),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('Delete'),
                onPressed: () {
                  _deleteComment(commentId);
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  /////////////////////////////////////////////////// DELETECOMMENT /////////////////////////////////////////////////////////////

  void _deleteComment(String commentId) async {
    _isLoading = true;
    try {
      await FirebaseFirestore.instance
          .collection('comments')
          .doc(commentId)
          .delete();
      FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.postId)
          .update({'comments': (commentsWithUser.length - 1)});
      _isLoading = false;
      if (!mounted) {
        return;
      }
      setState(() {});
    } catch (e) {
      _isLoading = false;
      print(e);
    }
  }

  toastMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}
