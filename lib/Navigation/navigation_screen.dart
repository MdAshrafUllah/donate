import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../widget/initialize_current_user.dart';
import 'All Navigation Screens/home_screen.dart';
import 'All Navigation Screens/message_screen.dart';
import 'All Navigation Screens/notification_screen.dart';
import 'All Navigation Screens/profile_screen.dart';

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();

  static void setStatus(String s) {}
}

class _NavigationScreenState extends State<NavigationScreen> {
  String userID = '';

  @override
  void initState() {
    super.initState();
    if (AuthService.currentUser != null) {
      FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: AuthService.currentUser!.email)
          .get()
          .then((QuerySnapshot querySnapshot) {
        for (var doc in querySnapshot.docs) {
          String documentId = doc.id;
          userID = documentId;
          setStatus("Online");
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    final int? argument = ModalRoute.of(context)?.settings.arguments as int?;
    if (argument != null) {
      setState(() {
        index = argument;
      });
    }
  }

  void setStatus(String status) async {
    if (AuthService.currentUser != null) {
      await FirebaseFirestore.instance.collection('users').doc(userID).update({
        "status": status,
      });
    }
  }

  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // online
      setStatus("Online");
    } else {
      setStatus("Offline");
    }
  }

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
