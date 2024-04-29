import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:geolocator/geolocator.dart';

class UserService {
  // Sign in with Google
  static Future<String> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication googleAuth =
          await googleUser!.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
      return 'done';
    } catch (e) {
      return 'Error signing in with Google: $e';
    }
  }



  //we sign the user out from google and from firebase
  static Future<int> logout() async {
    try {
      final GoogleSignIn _googleSignIn = GoogleSignIn();
      await _googleSignIn.signOut();
      FirebaseAuth.instance.signOut();
      return 1;
    } catch (e) {
      print(e.toString());
      return -1;
    }
  }






  static Future<Map<String, dynamic>?> getUserById(String id) async {
    try {
      DocumentSnapshot userSnapshot =
      await FirebaseFirestore.instance.collection('users').doc(id).get();
      if (userSnapshot.exists) {
        Map<String, dynamic> userData =
        userSnapshot.data() as Map<String, dynamic>;
        return userData;
      } else {
        return null;
      }
    }catch(e){
      return null;
    }
  }





  static Future<String> updateUser(Map<String, dynamic> userInfos,
      bool isEdited, String? previousImgUrl) async {
    try {
      //we reformate the date to be stored in firestore
      //make the url as the old one, it's useful if the user hasn't changed the profil
      userInfos['birthDay'] = Timestamp.fromDate(userInfos['birthDay']);
      String? downloadURL = previousImgUrl;

      //put img in firebase(if it exist and edited)
      if (userInfos['imageFile'] != null && isEdited) {
        //we delete the previous one if it exists
        if (previousImgUrl != null) {
          FirebaseStorage.instance.refFromURL(previousImgUrl).delete();
        }
        //make the image name
        String fileName = DateTime.now().millisecondsSinceEpoch.toString();
        Reference ref =
            FirebaseStorage.instance.ref().child('profils/$fileName');
        //put the image in storage and get its url
        await ref.putFile(userInfos['imageFile']);
        downloadURL = await ref.getDownloadURL();
      }

      //store user data in Firestore.
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({
        'name': userInfos['name'],
        'city': userInfos['city'],
        'birthDay': userInfos['birthDay'],
        'description': userInfos['description'],
        'imageUrl': downloadURL,
        'location': userInfos['location'],
        'phone': userInfos['phone'],
      });
      return "done";
    } catch (e) {
      return "Registration failed: $e";
    }
  }

  Future<String> registerUser(Map<String, dynamic> userInfos) async {
    if (userInfos['name'].isEmpty ||
        userInfos['city'].isEmpty ||
        userInfos['birthDay'] == null) {
      return "Please fill in all required fields and select an image.";
    }

    userInfos['birthDay'] = Timestamp.fromDate(userInfos['birthDay']);

    try {
      //store the image file in firebasestorage and get its url
      String? downloadURL;
      if (userInfos['imageFile'] != null) {
        String fileName = DateTime.now().millisecondsSinceEpoch.toString();
        Reference ref =
            FirebaseStorage.instance.ref().child('profils/$fileName');
        await ref.putFile(userInfos['imageFile']);
        downloadURL = await ref.getDownloadURL();
      }
      //store user data in Firestore.
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .set({
        'name': userInfos['name'],
        'city': userInfos['city'],
        'birthDay': userInfos['birthDay'],
        'description': userInfos['description'],
        'imageUrl': downloadURL,
        'role': 0,
        'note': null,
        'location': null,
        'phone': null,
        'favPosts': []
      });
      return "done";
    } catch (e) {
      return "Registration failed: $e";
    }
  }


  //checking user auth, -1 if error, 0 if not auth, 1 if auth and not registered, 2 if both
  static Future<int> checkUserAuth() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return 0;
      } else {
        CollectionReference userCollection =
            FirebaseFirestore.instance.collection('users');
        DocumentSnapshot documentSnapshot =
            await userCollection.doc(user.uid).get();
        if (documentSnapshot.exists) {
          return 2;
        } else {
          return 1;
        }
      }
    } catch (e) {
      return -1;
    }
  }



  Future<int?> getUserRole() async {
    try {
      String? userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        CollectionReference users =
            FirebaseFirestore.instance.collection('users');

        DocumentSnapshot documentSnapshot = await users.doc(userId).get();
        if (documentSnapshot.exists) {
          return documentSnapshot.get('role');
        } else {
          return null;
        }
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<String?> makeUserChef(Map<String, dynamic> userInfos) async {
    try {
      DocumentReference userRef = FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser?.uid);
      await userRef.update(userInfos);
      return "done";
    } catch (e) {
      return "Error updating user fields: $e";
    }
  }

  static Future<List> getLocation() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return [-1];
    } else if (permission == LocationPermission.deniedForever) {
      return [-1];
    } else {
      try {
        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
        return [position.latitude, position.longitude];
      } catch (e) {
        return [-3];
      }
    }
  }
}