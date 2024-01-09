import 'package:flutter/material.dart';

class TermsandConditions extends StatelessWidget {
  const TermsandConditions({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Terms and Conditions',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Roboto',
            ),
          ),
        ),
        body: const SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "User Eligibility:",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                  ),
                ),
                Text(
                  "The Food Donation App is intended for use by individuals willing to donate surplus food to those in need. By using the App, you confirm that you are willing to donate food and comply with all relevant food safety and handling guidelines in your jurisdiction.",
                ),
                SizedBox(height: 10),
                Text(
                  "Food Donation Guidelines:",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                  ),
                ),
                Text(
                  "Users are responsible for ensuring that donated food is safe for consumption and complies with local health and safety regulations. The App encourages donating fresh, unspoiled, and properly packaged food.",
                ),
                SizedBox(height: 10),
                Text(
                  "User Conduct:",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                  ),
                ),
                Text(
                  "Users are expected to conduct themselves respectfully and responsibly. Any misuse of the app, including posting misleading information or engaging in fraudulent activities related to food donation, is strictly prohibited.",
                ),
                SizedBox(height: 10),
                Text(
                  "Privacy and Data Security:",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                  ),
                ),
                Text(
                  "The App collects and processes user data as outlined in the Privacy Policy. By using the App, you consent to the collection, use, and storage of your personal information as described in the Privacy Policy.",
                ),
                // ... (Continue with similar sections as necessary)
                SizedBox(height: 10),
                Text(
                  "App Modifications:",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                  ),
                ),
                Text(
                  "The Food Donation App reserves the right to update, modify, or discontinue the App or any part of it without prior notice. These modifications may include adding or removing features or functionalities.",
                ),
                SizedBox(height: 10),
                Text(
                  "Termination of Access:",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                  ),
                ),
                Text(
                  "The Food Donation App reserves the right to terminate or suspend access to the App at its discretion, without any liability, if a user violates these Terms or engages in any unlawful or harmful activities.",
                ),
                // ... (Continue with remaining sections)
                SizedBox(height: 10),
                Text(
                  "Entire Agreement:",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                  ),
                ),
                Text(
                  "These Terms constitute the entire agreement between the user and the Food Donation App concerning the use of the App, superseding any prior or contemporaneous agreements, communications, or representations.",
                ),
                SizedBox(height: 10),
                Text(
                  "By using the UTSARGO App, you acknowledge that you have read, understood, and agreed to abide by these Terms and Conditions. If you do not agree with any of the provisions mentioned herein, you must refrain from using the App.",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                  ),
                ),
              ],
            )),
      ),
    );
  }
}
