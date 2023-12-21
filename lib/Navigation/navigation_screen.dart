import 'package:flutter/material.dart';

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
  int index = 0;
  final screens = [
    HomeScreen(),
    MessageScreen(),
    NotificationScreen(),
    ProfileScreen(),
  ];
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFF39b54a),
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
          actions: <Widget>[
            Builder(
              builder: (BuildContext context) {
                return IconButton(
                  icon: const Icon(Icons.shopping_cart_outlined),
                  color: Colors.white,
                  onPressed: () {
                    Scaffold.of(context).openEndDrawer();
                  },
                );
              },
            ),
          ],
        ),
        drawer: Drawer(),
        body: screens[index],
        bottomNavigationBar: NavigationBarTheme(
          data: NavigationBarThemeData(
              indicatorColor: Color(0xFF39b54a).withOpacity(0.3),
              labelTextStyle: MaterialStateProperty.all(TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ))),
          child: NavigationBar(
            height: 60,
            backgroundColor: Color(0xFF39b54a).withOpacity(0.15),
            labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
            animationDuration: Duration(seconds: 1),
            selectedIndex: index,
            onDestinationSelected: (index) =>
                setState(() => this.index = index),
            destinations: const [
              NavigationDestination(
                icon: Icon(
                  Icons.view_agenda_outlined,
                  color: Color(0xFF39b54a),
                ),
                selectedIcon: Icon(
                  Icons.view_agenda,
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
                  Icons.account_box_outlined,
                  color: Color(0xFF39b54a),
                ),
                selectedIcon: Icon(
                  Icons.account_box_rounded,
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
}
