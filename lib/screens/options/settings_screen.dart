import 'package:flutter/material.dart';
import 'package:ecommerce/services/UserService.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isLoading = false;
  bool isAuthenticated = false;
  bool profileExists = false;

  @override
  void initState() {
    super.initState();
    checkUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text('Change Language'),
            onTap: () {},
          ),
          ListTile(
            title: Text('Terms and Conditions'),
            onTap: () {
              Navigator.pushNamed(context, '/terms');
            },
          ),
          ListTile(
            title: Text('Tutorial'),
            onTap: () {
              // Add logic for tutorial
            },
          ),
          if (isAuthenticated && profileExists)
            ListTile(
              title: Text('Edit Profil'),
              onTap: () {
                Navigator.pushNamed(context, '/editProfile');
              },
            ),
          if (isAuthenticated)
            ListTile(
              title: const Text(
                'LogOut',
                style: TextStyle(
                  color: Colors.red, // Text color
                ),
              ),
              onTap: () {
                logout();
              },
            ),
          const SizedBox(height: 50),
          _isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : SizedBox()
        ],
      ),
    );
  }





  //we set isAuth and profilexists based on response from checkuserauth
  //they stay false if user is not auth or if there was an error when checking userAuth
  Future<void> checkUser() async {
    int a = await UserService.checkUserAuth();
    if (a == 1) {
      isAuthenticated = true;
    }
    if (a == 2) {
      isAuthenticated = true;
      profileExists = true;
    }
    if(!mounted){return;}
    setState(() {});
  }




  //if logout is done we popout if not we show error, and ofc we check mounted in async funcitons
  Future<void> logout() async {
    _isLoading = true;
    setState(() {});
    int? a = await UserService.logout();
    _isLoading = false;

    if(!mounted) {return;}
    setState(() {});
    if (a == 1) {
      print("logout done");
      Navigator.of(context).pop();
    } else {
      print("logout error");
    }
  }



}
