import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'auth/login_screen.dart';
import 'onboarding/onboarding_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    Future checkInternetConnection() async {
      var connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult != ConnectivityResult.none) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        bool isFirstTime = prefs.getBool('isFirstTime') ?? true;

        if (isFirstTime) {
          prefs.setBool('isFirstTime', false);
          Navigator.pushReplacementNamed(context, "/onBoardingScreen");
        } else {
          Navigator.pushReplacementNamed(context, "/loginScreen");
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No Internet Connection'),
          ),
        );
      }
    }

    // Check internet connection after delay
    Future.delayed(const Duration(seconds: 5), () {
      checkInternetConnection();
    });

    return Scaffold(
      backgroundColor: const Color(0xFF39b54a),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: size.width / 3,
              child: Image.asset(
                'assets/utsargo_App_Logo_green.png',
                fit: BoxFit.scaleDown,
                color: Colors.white,
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            SizedBox(
              width: size.width / 3,
              child: const LinearProgressIndicator(
                backgroundColor: Color(0xFF39b54a),
                valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
