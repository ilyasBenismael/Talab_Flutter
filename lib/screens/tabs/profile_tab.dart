import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ecommerce/screens/user/login_screen.dart';
import 'package:ecommerce/screens/user/my_profile_screen.dart';
import 'package:ecommerce/screens/user/register_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilTab extends StatefulWidget {
  @override
  _ProfilTabState createState() => _ProfilTabState();
}

class _ProfilTabState extends State<ProfilTab>
    with AutomaticKeepAliveClientMixin<ProfilTab> {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.data != null) {
          return ProfileStreamWidget();
        } else {
          return SignInScreen();
        }
      },
    );
  }
}

////////////////////////////////////////////////////////////////////////

class ProfileStreamWidget extends StatefulWidget {
  @override
  _ProfileStreamWidgetState createState() => _ProfileStreamWidgetState();
}

class _ProfileStreamWidgetState extends State<ProfileStreamWidget> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final User? _currentUser = _auth.currentUser;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: _firestore.collection('users').doc(_currentUser!.uid).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        } else {
          if (snapshot.hasData && snapshot.data!.exists) {
            return MyProfileScreen();
          } else {
            return RegisterScreen();
          }
        }
      },
    );
  }
}
