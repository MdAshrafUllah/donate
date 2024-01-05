// ignore_for_file: use_build_context_synchronously

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConnectionChecker {
  static bool _isOnlineMessageShown = false;
  static Future<void> checkAndNavigate({
    required BuildContext context,
    String? onBoardingRoute,
    String? loginRoute,
  }) async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult != ConnectivityResult.none) {
      if (!_isOnlineMessageShown) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.green,
          content: Text(
            'Back to Online',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Roboto',
            ),
          ),
        ));
        _isOnlineMessageShown =
            true; // Update flag to indicate the message was shown
      }

      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool isFirstTime = prefs.getBool('isFirstTime') ?? true;

      if (isFirstTime) {
        prefs.setBool('isFirstTime', false);
        if (onBoardingRoute != null) {
          Navigator.pushReplacementNamed(context, onBoardingRoute);
        } else {}
      } else {
        if (loginRoute != null) {
          Navigator.pushReplacementNamed(context, loginRoute);
        } else {}
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.red,
        content: Text(
          'No Internet Connection',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Roboto',
          ),
        ),
      ));
    }
  }
}
