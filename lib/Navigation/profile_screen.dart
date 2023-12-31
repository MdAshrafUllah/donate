import 'dart:io';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:path_provider/path_provider.dart';

import '../user/save.dart';

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
          if (doc["email"] == user?.email) {
            FirebaseFirestore.instance
                .collection("users")
                .doc(doc.id)
                .update({'profileImage': downloadUrl.toString()});
          }
        }
      });
      // Update user's profile image in the 'posts' collection
      FirebaseFirestore.instance
          .collection('posts')
          .where('userId', isEqualTo: user?.uid)
          .get()
          .then((QuerySnapshot postQuerySnapshot) {
        for (var postDoc in postQuerySnapshot.docs) {
          FirebaseFirestore.instance
              .collection('posts')
              .doc(postDoc.id)
              .update({'profileImage': downloadUrl.toString()});

          // Update commenter's profile image in the 'comments' subCollection
          FirebaseFirestore.instance
              .collection('posts')
              .doc(postDoc.id)
              .collection('comments')
              .get()
              .then((QuerySnapshot commentQuerySnapshot) {
            for (var commentDoc in commentQuerySnapshot.docs) {
              if (commentDoc["commenterEmail"] == user?.email) {
                FirebaseFirestore.instance
                    .collection('posts')
                    .doc(postDoc.id)
                    .collection('comments')
                    .doc(commentDoc.id)
                    .update({'commenterProfileUrl': downloadUrl.toString()});
              }
            }
          });
        }
      });

      // Update commenter's profile image in the 'comments' subCollection
      FirebaseFirestore.instance
          .collection('posts')
          .get()
          .then((QuerySnapshot postQuerySnapshot) {
        for (var postDoc in postQuerySnapshot.docs) {
          FirebaseFirestore.instance
              .collection('posts')
              .doc(postDoc.id)
              .collection('comments')
              .where('commenterEmail', isEqualTo: user?.email)
              .get()
              .then((QuerySnapshot commentQuerySnapshot) {
            for (var commentDoc in commentQuerySnapshot.docs) {
              FirebaseFirestore.instance
                  .collection('posts')
                  .doc(postDoc.id)
                  .collection('comments')
                  .doc(commentDoc.id)
                  .update({'commenterProfileImage': downloadUrl.toString()});
            }
          });
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
          if (doc["email"] == user?.email) {
            FirebaseFirestore.instance
                .collection("users")
                .doc(doc.id)
                .update({'profileImage': downloadUrl.toString()});
          }
        }
      });

      // Update user's profile image in the 'posts' collection
      FirebaseFirestore.instance
          .collection('posts')
          .where('userId', isEqualTo: user?.uid)
          .get()
          .then((QuerySnapshot postQuerySnapshot) {
        for (var postDoc in postQuerySnapshot.docs) {
          FirebaseFirestore.instance
              .collection('posts')
              .doc(postDoc.id)
              .update({'profileImage': downloadUrl.toString()});

          // Update commenter's profile image in the 'comments' subCollection
          FirebaseFirestore.instance
              .collection('posts')
              .doc(postDoc.id)
              .collection('comments')
              .get()
              .then((QuerySnapshot commentQuerySnapshot) {
            for (var commentDoc in commentQuerySnapshot.docs) {
              if (commentDoc["commenterEmail"] == user?.email) {
                FirebaseFirestore.instance
                    .collection('posts')
                    .doc(postDoc.id)
                    .collection('comments')
                    .doc(commentDoc.id)
                    .update({'commenterProfileUrl': downloadUrl.toString()});
              }
            }
          });
        }
      });

      // Update commenter's profile image in the 'comments' subCollection
      FirebaseFirestore.instance
          .collection('posts')
          .get()
          .then((QuerySnapshot postQuerySnapshot) {
        for (var postDoc in postQuerySnapshot.docs) {
          FirebaseFirestore.instance
              .collection('posts')
              .doc(postDoc.id)
              .collection('comments')
              .where('commenterEmail', isEqualTo: user?.email)
              .get()
              .then((QuerySnapshot commentQuerySnapshot) {
            for (var commentDoc in commentQuerySnapshot.docs) {
              FirebaseFirestore.instance
                  .collection('posts')
                  .doc(postDoc.id)
                  .collection('comments')
                  .doc(commentDoc.id)
                  .update({'commenterProfileImage': downloadUrl.toString()});
            }
          });
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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
        body: ModalProgressHUD(
      inAsyncCall: isLoading,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
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
                border: Border.all(width: 1, color: Color(0xFF39b54a))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(
                  padding: EdgeInsets.all(5),
                  child: Column(
                    children: [
                      Text(
                        "Total Donate",
                        style: TextStyle(fontSize: size.width * 0.045),
                      ),
                      Text(
                        "00",
                        style: TextStyle(
                            fontSize: size.width * 0.07,
                            fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                ),
                VerticalDivider(
                  color: Color(0xFF39b54a),
                ),
                Container(
                  padding: EdgeInsets.all(5),
                  child: Column(
                    children: [
                      Text(
                        "Total Received",
                        style: TextStyle(fontSize: size.width * 0.045),
                      ),
                      Text(
                        "00",
                        style: TextStyle(
                            fontSize: size.width * 0.07,
                            fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                ),
                VerticalDivider(
                  color: Color(0xFF39b54a),
                ),
                Container(
                  padding: EdgeInsets.all(5),
                  child: Column(
                    children: [
                      Text(
                        "Total Deliver",
                        style: TextStyle(fontSize: size.width * 0.045),
                      ),
                      Text(
                        "00",
                        style: TextStyle(
                            fontSize: size.width * 0.07,
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
                      width: size.width / 1.09,
                      height: size.height / 20,
                      child: Row(
                        children: [
                          Icon(
                            Icons.bookmark,
                            size: size.width / 12,
                            color: const Color(0xFF39b54a),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      const SaveItemsScreen(),
                                ),
                              );
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
                      width: size.width / 1.09,
                      height: size.height / 20,
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
                      width: size.width / 1.09,
                      height: size.height / 20,
                      child: Row(
                        children: [
                          Icon(
                            Icons.privacy_tip,
                            size: size.width / 12,
                            color: const Color(0xFF39b54a),
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
                    SizedBox(
                      width: size.width / 1.09,
                      height: size.height / 20,
                      child: Row(
                        children: [
                          Icon(
                            Icons.logout,
                            size: size.width / 12,
                            color: const Color(0xFF39b54a),
                          ),
                          TextButton(
                            onPressed: () async {
                              // setStatus("Offline");
                              Directory appDocDir =
                                  await getApplicationDocumentsDirectory();
                              if (appDocDir.existsSync()) {
                                appDocDir.deleteSync(recursive: true);
                              }

                              await FirebaseAuth.instance.signOut();
                              Navigator.pushNamed(context, '/loginScreen');
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
