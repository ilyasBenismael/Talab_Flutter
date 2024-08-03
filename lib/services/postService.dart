import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class PostService {


  static Future<int> addPost(Map<String, dynamic> postInfos) async {
    try {
      //store the image file in firebasestorage and get its url
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference ref = FirebaseStorage.instance.ref().child('posts/$fileName');
      await ref.putFile(postInfos['imageFile']);
      String downloadURL = await ref.getDownloadURL();

      //store user data in Firestore.
      await FirebaseFirestore.instance.collection('posts').add({
        'title': postInfos['title'],
        'price': postInfos['price'],
        'description': postInfos['description'],
        'categories': postInfos['categories'],
        'keywords': postInfos['keywords'],
        'imageUrl': downloadURL,
        'userId': FirebaseAuth.instance.currentUser!.uid.toString(),
        'timeStamp': FieldValue.serverTimestamp()
      });
      return 1;
    } catch (e) {
      print(e.toString());
      return -1;
    }
  }




  static Future<int> updatePost(Map<String, dynamic> postInfos, bool isImgEdited, String postId, String? previousImgUrl) async {
    try {
      if (postInfos['title'].isEmpty ||
          postInfos['price'].isEmpty ||
          postInfos['description'].isEmpty ||
          postInfos['categories'].isEmpty ||
          postInfos['keywords'].isEmpty ||
          postInfos['imageFile'] == null) {
        return -1;
      }

      if(isImgEdited) {
      //store the image file in firebasestorage and get its url
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference ref = FirebaseStorage.instance.ref().child('posts/$fileName');
      await ref.putFile(postInfos['imageFile']);
      postInfos['imageFile'] = await ref.getDownloadURL();

      if (previousImgUrl != null) {
        FirebaseStorage.instance.refFromURL(previousImgUrl).delete();
      }
      }


      //store user data in Firestore.
      await FirebaseFirestore.instance.collection('posts').doc(postId).update({
        'title': postInfos['title'],
        'price': postInfos['price'],
        'description': postInfos['description'],
        'categories': postInfos['categories'],
        'keywords': postInfos['keywords'],
        'imageUrl': postInfos['imageFile'],
        'userId': FirebaseAuth.instance.currentUser!.uid.toString(),
        'timeStamp': FieldValue.serverTimestamp()
      });
      return 1;
    } catch (e) {
      print(e.toString());
      return -2;
    }
  }






  //returns null if error, an empty list [] if there is no posts , a list of docs
  static Future<dynamic> getPostsByUser(String userId) async {
    try {
      CollectionReference postsRef =
          FirebaseFirestore.instance.collection('posts');
      QuerySnapshot querySnapshot =
          await postsRef.where('userId', isEqualTo: userId).get();
      return querySnapshot.docs;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }


  static Future<Map<String, dynamic>?> getPostById(String postId) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> postSnapshot =
          await FirebaseFirestore.instance
              .collection('posts')
              .doc(postId)
              .get();
      if (postSnapshot.exists) {
        Map<String, dynamic>? postData = postSnapshot.data();
        return postData;
      }else {
        return null;
      }
    } catch (error) {
      print('Error fetching post: $error');
      return null;
    }
  }



  static Future<List<Map<String, dynamic>>?> getFavoritePosts(
      String userId) async {
    try {
      //we get the user from the id first
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      Map<String, dynamic>? userData =
          userSnapshot.data() as Map<String, dynamic>?;

      //we ge the favposts ids and we get the posts having those ids as query snapshot
      List favPosts = userData?['favPosts'] ?? [];

      //if it's empty there is no need to fetch anything
      if (favPosts.isEmpty) {
        return [];
      }
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('posts')
          .where(FieldPath.documentId, whereIn: favPosts)
          .get();

      //we turn that query snapshot to list of maps representing the post
      List<Map<String, dynamic>> posts = querySnapshot.docs.map((doc) {
        Map<String, dynamic> post = doc.data() as Map<String, dynamic>;
        //we addd the id to the map because we will need to visit the post (goToPost)
        post.addAll({'id': doc.id});
        return post;
      }).toList();
      return posts;
    } catch (error) {
      //if any error we return null
      print(error.toString());
      return null;
    }
  }

  static Future<List?> getFavoritePostsIds(String userId) async {
    try {
      //we get the user from the id first
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      Map<String, dynamic>? userData =
          userSnapshot.data() as Map<String, dynamic>?;
      return userData?['favPosts'];
    } catch (error) {
      return null;
    }
  }
}
