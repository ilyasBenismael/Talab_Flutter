import 'package:flutter/material.dart';
import 'package:ecommerce/services/UserService.dart';

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  bool _isLoading = false;
  String profilState = ''; // Track the loading state

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: Icon(Icons.settings),
                onPressed: () {
                  Navigator.pushNamed(context, '/settings');
                },
              )
            ],
          ),
          SizedBox(height: 80),
          const Text('WELCOME',
              style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold)),
          const Text('TO TALAB',
              style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold)),
          const SizedBox(height: 45),
          ElevatedButton.icon(
            onPressed: _isLoading ? null : signInWithGoogle,
            // Disable button when loading
            icon: const Icon(Icons.mail_rounded),
            label: const Text('Sign in with Google'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white, // White button color
              foregroundColor: Colors.black, // Text color
            ),
          ),
          const SizedBox(height: 20), // Add spacing between buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('By signing in, you agree to the ',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/terms');
                },
                child: Text(
                  'Terms and Conditions',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }




  void signInWithGoogle() async {
    setState(() {
      _isLoading = true; // Set loading state to true
    });
    await UserService.signInWithGoogle();
    setState(() {
      _isLoading = false; // Set loading state to false when complete
    });
  }

}
