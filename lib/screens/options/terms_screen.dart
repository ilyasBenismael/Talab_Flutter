import 'package:flutter/material.dart';

class TermsScreen extends StatefulWidget {
  const TermsScreen({super.key});

  @override
  TermsScreenState createState() => TermsScreenState();
}

class TermsScreenState extends State<TermsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF282828),
        title: const Text('Terms and Conditions'),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Terms and Conditions',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              'Welcome to Our E-commerce App! By using our app, you agree to comply with and be bound by the following terms and conditions of use. Please review these terms carefully before using the app.\n\n'
                  '1. The content of the pages of this app is for your general information and use only. It is subject to change without notice.\n\n'
                  '2. Neither we nor any third parties provide any warranty or guarantee as to the accuracy, timeliness, performance, completeness, or suitability of the information and materials found or offered on this app for any particular purpose.\n\n'
                  '3. Your use of any information or materials on this app is entirely at your own risk, for which we shall not be liable. It shall be your own responsibility to ensure that any products, services, or information available through this app meet your specific requirements.\n\n'
                  '4. This app contains material that is owned by or licensed to us. This material includes, but is not limited to, the design, layout, look, appearance, and graphics. Reproduction is prohibited other than in accordance with the copyright notice, which forms part of these terms and conditions.\n\n'
                  '5. All trademarks reproduced in this app, which are not the property of, or licensed to the operator, are acknowledged on the app.\n\n'
                  '6. Unauthorized use of this app may give rise to a claim for damages and/or be a criminal offense.\n\n'
                  '7. From time to time, this app may also include links to other apps. These links are provided for your convenience to provide further information. They do not signify that we endorse the app(s). We have no responsibility for the content of the linked app(s).\n\n'
                  '8. Your use of this app and any dispute arising out of such use of the app is subject to the laws of the United States of America.\n\n'
                  'Thank you for reading our terms and conditions. Enjoy using our app!',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

