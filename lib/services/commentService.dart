import 'package:cloud_firestore/cloud_firestore.dart';

class CommentService {





  /////////////////////////////////////////////////////// ADD COMMENT //////////////////////////////////////////////////////////////
  static Future<int> addComment(
      String? postId, String value, String userId) async {
    try {
      await FirebaseFirestore.instance.collection('comments').add({
        'value': value,
        'userId': userId,
        'postId': postId,
        'timeStamp': FieldValue.serverTimestamp(),
      });
      return 1;
    } catch (e) {
      print('Error adding comment: $e');
      return -1;
    }
  }
}
