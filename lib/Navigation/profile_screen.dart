import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

String currentPic = ' ';
String bio = '';
String name = '';

class _ProfileScreenState extends State<ProfileScreen> {

  FirebaseAuth auth = FirebaseAuth.instance;
  User? user;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      if (auth.currentUser != null) {
        setState(() {
          isLoading = true;
        });

        user = auth.currentUser;
        final querySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: user?.email)
            .get();

        for (var doc in querySnapshot.docs) {
          setState(() {
            currentPic = doc["profileImage"];
            bio = doc['bio'];
            name = doc['name'];
          });
        }

        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
        body: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(
          child: Column(
            children: [
              Container(
                width: size.width / 4.5,
                height: size.height / 9.5,
                decoration: ShapeDecoration(
                  image: DecorationImage(
                    image: NetworkImage(currentPic),
                    fit: BoxFit.fill,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                  shadows: const [
                    BoxShadow(
                      color: Color(0x2D525252),
                      blurRadius: 10,
                      offset: Offset(2, 2),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                child: Column(
                  children: [
                    Text(
                      name,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF1E1E1E),
                        fontSize: size.width / 19,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: size.height / 70),
                    Text(
                      bio,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF1E1E1E),
                        fontSize: size.width / 30,
                        fontWeight: FontWeight.w400,
                        height: 0,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: size.height / 24),
        Container(
          padding: EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: size.width / 1.09,
                    height: size.height / 20,
                    child: Row(
                      children: [
                        Icon(
                          Icons.account_circle,
                          size: size.width / 12,
                          color: Color(0xFF39b54a),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: Text('Manage Profile',
                              style: TextStyle(
                                  fontSize: size.width / 22,
                                  color: Colors.black54)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Container(
                    width: size.width / 1.09,
                    height: size.height / 20,
                    child: Row(
                      children: [
                        Icon(
                          Icons.bookmark,
                          size: size.width / 12,
                          color: Color(0xFF39b54a),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: Text('Save',
                              style: TextStyle(
                                  fontSize: size.width / 22,
                                  color: Colors.black54)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Container(
                    width: size.width / 1.09,
                    height: size.height / 20,
                    child: Row(
                      children: [
                        Icon(
                          Icons.settings,
                          size: size.width / 12,
                          color: Color(0xFF39b54a),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: Text('Setting',
                              style: TextStyle(
                                  fontSize: size.width / 22,
                                  color: Colors.black54)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Container(
                    width: size.width / 1.09,
                    height: size.height / 20,
                    child: Row(
                      children: [
                        Icon(
                          Icons.privacy_tip,
                          size: size.width / 12,
                          color: Color(0xFF39b54a),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: Text('Privacy & Security',
                              style: TextStyle(
                                  fontSize: size.width / 22,
                                  color: Colors.black54)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: size.height / 15,
              ),
              Row(
                children: [
                  Container(
                    width: size.width / 1.09,
                    height: size.height / 20,
                    child: Row(
                      children: [
                        Icon(
                          Icons.logout,
                          size: size.width / 12,
                          color: Color(0xFF39b54a),
                        ),
                        TextButton(
                          onPressed: () async {
                            // setStatus("Offline");
                            Future<void> _deleteAppDir() async {
                              Directory appDocDir =
                              await getApplicationDocumentsDirectory();

                              if (appDocDir.existsSync()) {
                                appDocDir.deleteSync(recursive: true);
                              }
                            }

                            await FirebaseAuth.instance.signOut();
                            Navigator.pushNamed(context, '/');
                          },
                          child: Text('Logout',
                              style: TextStyle(
                                  fontSize: size.width / 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red)),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ],
    ));
  }
}

