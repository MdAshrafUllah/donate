// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import '../../data/drd_total_data.dart';
import '../../widget/active_status.dart';
import '../../widget/clear_catch.dart';
import '../../widget/initialize_current_user.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

String imageUrl = ' ';
String currentPic = ' ';
String bio = '';
String name = '';

class _ProfileScreenState extends State<ProfileScreen> {
  bool isLoading = false;
  List<QueryDocumentSnapshot> completeDonateList = [];
  List<QueryDocumentSnapshot> completeReceivedList = [];
  List<QueryDocumentSnapshot> completeDeliveredList = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      if (AuthService.currentUser != null) {
        setState(() {
          isLoading = true;
        });

        completeDonateList =
            await FirestoreManager.fetchCompleteList('complete Donate');
        completeReceivedList =
            await FirestoreManager.fetchCompleteList('complete Received');
        completeDeliveredList =
            await FirestoreManager.fetchCompleteList('complete Deliver');

        setState(() {});

        final querySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: AuthService.currentUser!.email)
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

  void uploadCameraImage() async {
    try {
      setState(() {
        isLoading = true; // Show the spinner
      });

      final image = await ImagePicker().pickImage(source: ImageSource.camera);
      String fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(10000)}.jpg';
      Reference ref = FirebaseStorage.instance.ref().child(fileName);
      await ref.putFile(File(image!.path));
      String downloadUrl = await ref.getDownloadURL();
      ref.getDownloadURL().then((pImage) {
        setState(() {
          imageUrl = pImage;
        });
      });

      // Update user's profile image in the 'users' collection
      FirebaseFirestore.instance
          .collection('users')
          .get()
          .then((QuerySnapshot querySnapshot) {
        for (var doc in querySnapshot.docs) {
          if (doc["email"] == AuthService.currentUser!.email) {
            FirebaseFirestore.instance
                .collection("users")
                .doc(doc.id)
                .update({'profileImage': downloadUrl.toString()});
          }
        }
      });
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.green,
        content: Text(
          'Profile Picture updated successfully!',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Roboto',
          ),
        ),
      ));
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.red,
        content: Text(
          'Error uploading profile picture.',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Roboto',
          ),
        ),
      ));
    }
  }

  void uploadGalleryImage() async {
    try {
      setState(() {
        isLoading = true;
      });
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      String fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(10000)}.jpg';
      Reference ref = FirebaseStorage.instance.ref().child(fileName);
      await ref.putFile(File(image!.path));
      String downloadUrl = await ref.getDownloadURL();
      ref.getDownloadURL().then((pImage) {
        setState(() {
          imageUrl = pImage;
        });
      });

      // Update user's profile image in the 'users' collection
      FirebaseFirestore.instance
          .collection('users')
          .get()
          .then((QuerySnapshot querySnapshot) {
        for (var doc in querySnapshot.docs) {
          if (doc["email"] == AuthService.currentUser!.email) {
            FirebaseFirestore.instance
                .collection("users")
                .doc(doc.id)
                .update({'profileImage': downloadUrl.toString()});
          }
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.green,
        content: Text(
          'Profile Picture updated successfully!',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Roboto',
          ),
        ),
      ));
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.red,
        content: Text(
          'Error uploading profile picture.',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Roboto',
          ),
        ),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
        body: ModalProgressHUD(
      inAsyncCall: isLoading,
      opacity: 0.5,
      blur: 0,
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 15),
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50.0,
                    backgroundColor: const Color(0xFF39b54a),
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ShowImage(
                            imageUrl: currentPic,
                          ),
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 48.0,
                        backgroundImage: imageUrl != " "
                            ? CachedNetworkImageProvider(imageUrl)
                            : CachedNetworkImageProvider(currentPic),
                        child: Transform.translate(
                          offset: const Offset(30, 35),
                          child: IconButton(
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      content: SizedBox(
                                        height: 120,
                                        child: Column(
                                          children: [
                                            ListTile(
                                              onTap: () {
                                                uploadCameraImage();
                                                Navigator.pop(context);
                                              },
                                              leading: const Icon(
                                                Icons.camera,
                                                color: Color(0xFF39b54a),
                                              ),
                                              title: const Text(
                                                'Camera',
                                                style: TextStyle(
                                                    color: Colors.black),
                                              ),
                                            ),
                                            ListTile(
                                              onTap: () {
                                                uploadGalleryImage();
                                                Navigator.pop(context);
                                              },
                                              leading: const Icon(
                                                Icons.image,
                                                color: Color(0xFF39b54a),
                                              ),
                                              title: const Text('Gallery',
                                                  style: TextStyle(
                                                      color: Colors.black)),
                                            )
                                          ],
                                        ),
                                      ),
                                    );
                                  });
                            },
                            icon: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: const Color(
                                    0xFF39b54a), // set the background color here
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Column(
                    children: [
                      Text(
                        name,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: const Color(0xFF1E1E1E),
                          fontSize: size.width / 19,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: size.height / 70),
                      Text(
                        bio,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: const Color(0xFF1E1E1E),
                          fontSize: size.width / 30,
                          fontWeight: FontWeight.w400,
                          height: 0,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: size.height / 24),
            Container(
              height: size.height * 0.10,
              width: double.infinity,
              decoration: BoxDecoration(
                  border: Border.all(width: 1, color: const Color(0xFF39b54a))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Container(
                    padding: const EdgeInsets.all(5),
                    child: Column(
                      children: [
                        Text(
                          "Total Donate",
                          style: TextStyle(fontSize: size.width * 0.045),
                        ),
                        Text(
                          completeDonateList.length.toString(),
                          style: TextStyle(
                              fontSize: size.width * 0.05,
                              fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                  ),
                  const VerticalDivider(
                    color: Color(0xFF39b54a),
                  ),
                  Container(
                    padding: const EdgeInsets.all(5),
                    child: Column(
                      children: [
                        Text(
                          "Total Received",
                          style: TextStyle(fontSize: size.width * 0.045),
                        ),
                        Text(
                          completeReceivedList.length.toString(),
                          style: TextStyle(
                              fontSize: size.width * 0.05,
                              fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                  ),
                  const VerticalDivider(
                    color: Color(0xFF39b54a),
                  ),
                  Container(
                    padding: const EdgeInsets.all(5),
                    child: Column(
                      children: [
                        Text(
                          "Total Deliver",
                          style: TextStyle(fontSize: size.width * 0.045),
                        ),
                        Text(
                          completeDeliveredList.length.toString(),
                          style: TextStyle(
                              fontSize: size.width * 0.05,
                              fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: size.height / 24),
            Container(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      SizedBox(
                        child: Row(
                          children: [
                            Icon(
                              Icons.backup_table_rounded,
                              size: size.width / 12,
                              color: const Color(0xFF39b54a),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/postsManager');
                              },
                              child: Text('Manage Posts',
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
                      SizedBox(
                        child: Row(
                          children: [
                            Icon(
                              Icons.people_alt,
                              size: size.width / 12,
                              color: const Color(0xFF39b54a),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/foodReceiver');
                              },
                              child: Text('Food Receiver',
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
                      SizedBox(
                        child: Row(
                          children: [
                            Icon(
                              Icons.call_received,
                              size: size.width / 12,
                              color: const Color(0xFF39b54a),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pushNamed(context, "/receiverList");
                              },
                              child: Text('Received Food List',
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
                      SizedBox(
                        child: Row(
                          children: [
                            Icon(
                              Icons.pedal_bike,
                              size: size.width / 12,
                              color: const Color(0xFF39b54a),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/foodDeliver');
                              },
                              child: Text('Food Deliver',
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
                      SizedBox(
                        child: Row(
                          children: [
                            Icon(
                              Icons.arrow_forward,
                              size: size.width / 12,
                              color: const Color(0xFF39b54a),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pushNamed(context, "/deliveryList");
                              },
                              child: Text('Food Delivered List',
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
                      SizedBox(
                        child: Row(
                          children: [
                            Icon(
                              Icons.arrow_outward,
                              size: size.width / 12,
                              color: const Color(0xFF39b54a),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pushNamed(context, "/donateList");
                              },
                              child: Text('Food Donate List',
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
                      SizedBox(
                        child: Row(
                          children: [
                            Icon(
                              Icons.bookmark,
                              size: size.width / 12,
                              color: const Color(0xFF39b54a),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pushNamed(
                                    context, '/saveItemsScreen');
                              },
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
                      SizedBox(
                        child: Row(
                          children: [
                            Icon(
                              Icons.settings,
                              size: size.width / 12,
                              color: const Color(0xFF39b54a),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pushNamed(context, "/settingScreen");
                              },
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
                      SizedBox(
                        child: Row(
                          children: [
                            Icon(
                              Icons.privacy_tip,
                              size: size.width / 12,
                              color: const Color(0xFF39b54a),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pushNamed(
                                    context, "/privacyAndSecurity");
                              },
                              child: Text('Terms and Conditions',
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
                      SizedBox(
                        child: Row(
                          children: [
                            Icon(
                              Icons.logout,
                              size: size.width / 12,
                              color: const Color(0xFF39b54a),
                            ),
                            TextButton(
                              onPressed: () async {
                                statusOffline();
                                deleteCacheDir();
                                deleteAppDir();
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
        ),
      ),
    ));
  }
}

class ShowImage extends StatelessWidget {
  final String imageUrl;

  const ShowImage({required this.imageUrl, super.key});

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        height: size.height,
        width: size.width,
        color: Colors.black,
        child: CachedNetworkImage(imageUrl: imageUrl.trim()),
      ),
    );
  }
}
