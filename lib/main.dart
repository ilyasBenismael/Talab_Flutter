import 'package:ecommerce/screens/options/settings_screen.dart';
import 'package:ecommerce/screens/options/terms_screen.dart';
import 'package:ecommerce/screens/post/add_post_screen.dart';
import 'package:ecommerce/screens/user/edit_profile_screen.dart';
import 'package:ecommerce/screens/user/favoritesScreen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:ecommerce/screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Ensure that Flutter is initialized.
  await Firebase.initializeApp(); // Initialize Firebase.
  runApp(MyApp());
}


class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        routes: {
          '/': (context) => MainScreen(),
          '/addPost': (context) => AddPostScreen(),
          '/settings': (context) => SettingsScreen(),
          '/terms': (context) => TermsScreen(),
          '/editProfile': (context) => EditProfileScreen(),
          '/favorites': (context) => FavoritesScreen(),
        });
  }
}
