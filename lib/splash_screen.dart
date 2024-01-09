// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';

import 'widget/connection_checker.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    Future.delayed(const Duration(seconds: 3), () {
      ConnectionChecker.checkAndNavigate(
        context: context,
        onBoardingRoute: "/onBoardingScreen",
        loginRoute: "/loginScreen",
      );
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
