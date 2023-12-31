import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'home_screen.dart';
import 'message_screen.dart';
import 'notification_screen.dart';
import 'profile_screen.dart';

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  FirebaseAuth auth = FirebaseAuth.instance;
  User? user;
  String userID = '';

  @override
  void initState() {
    super.initState();
    if (auth.currentUser != null) {
      user = auth.currentUser;
      FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: user?.email)
          .get()
          .then((QuerySnapshot querySnapshot) {
        for (var doc in querySnapshot.docs) {
          String documentId = doc.id;
          userID = documentId;
          // setStatus("Online");
        }
      });
    }
    requestAndCheckPermissions();
  }

  Future<void> requestAndCheckPermissions() async {
    // Check if camera permission is already granted
    PermissionStatus cameraStatus = await Permission.camera.status;
    if (!cameraStatus.isGranted) {
      // Request camera permission
      await Permission.camera.request();
    }

    // Check if file permission is already granted
    PermissionStatus fileStatus = await Permission.storage.status;
    if (!fileStatus.isGranted) {
      // Request file permission
      await Permission.storage.request();
    }

    // Check if notification permission is already granted
    PermissionStatus notificationStatus = await Permission.notification.status;
    if (!notificationStatus.isGranted) {
      // Request notification permission
      await Permission.notification.request();
    }

    // Check if photo permission is already granted
    PermissionStatus photoStatus = await Permission.photos.status;
    if (!photoStatus.isGranted) {
      // Request notification permission
      await Permission.photos.request();
    }
  }

  int index = 0;
  final screens = [
    const HomeScreen(),
    const MessageScreen(),
    const NotificationScreen(),
    const ProfileScreen(),
  ];
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(
            'utsargo'.toUpperCase(),
            style: TextStyle(
                letterSpacing: 1,
                fontSize: size.width / 15,
                color: Colors.white,
                fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          // actions: <Widget>[
          //   Builder(
          //     builder: (BuildContext context) {
          //       return IconButton(
          //         icon: const Icon(Icons.shopping_cart_outlined),
          //         color: Colors.white,
          //         onPressed: () {
          //           Scaffold.of(context).openEndDrawer();
          //         },
          //       );
          //     },
          //   ),
          // ],
        ),
        body: WillPopScope(
          onWillPop: () async => _onBackbuttonpressed(context),
          child: screens[index],
        ),
        bottomNavigationBar: NavigationBarTheme(
          data: NavigationBarThemeData(
              indicatorColor: const Color(0xFF39b54a).withOpacity(0.3),
              labelTextStyle: MaterialStateProperty.all(const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ))),
          child: NavigationBar(
            height: 60,
            backgroundColor: const Color(0xFF39b54a).withOpacity(0.15),
            labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
            animationDuration: const Duration(seconds: 1),
            selectedIndex: index,
            onDestinationSelected: (index) =>
                setState(() => this.index = index),
            destinations: const [
              NavigationDestination(
                icon: Icon(
                  Icons.home_outlined,
                  color: Color(0xFF39b54a),
                ),
                selectedIcon: Icon(
                  Icons.home,
                  color: Color(0xFF39b54a),
                ),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(
                  Icons.email_outlined,
                  color: Color(0xFF39b54a),
                ),
                selectedIcon: Icon(
                  Icons.email,
                  color: Color(0xFF39b54a),
                ),
                label: 'Message',
              ),
              NavigationDestination(
                icon: Icon(
                  Icons.notifications_none,
                  color: Color(0xFF39b54a),
                ),
                selectedIcon: Icon(
                  Icons.notifications,
                  color: Color(0xFF39b54a),
                ),
                label: 'Notification',
              ),
              NavigationDestination(
                icon: Icon(
                  Icons.person_outline,
                  color: Color(0xFF39b54a),
                ),
                selectedIcon: Icon(
                  Icons.person,
                  color: Color(0xFF39b54a),
                ),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _onBackbuttonpressed(BuildContext context) async {
    bool exitApp = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            "Really ?",
            style: TextStyle(color: Colors.black),
          ),
          content: const Text(
            "Do you want to close the app ?",
            style: TextStyle(color: Colors.black),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text(
                "No",
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF39b54a),
                  foregroundColor: Colors.white),
              onPressed: () {
                exit(0);
              },
              child: const Text("Yes"),
            ),
          ],
        );
      },
    );
    return exitApp;
  }
}
