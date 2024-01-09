// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../widget/initialize_current_user.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  String userID = '';
  TextEditingController nameCngController = TextEditingController();
  TextEditingController bioCngController = TextEditingController();
  TextEditingController mobileController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    if (AuthService.currentUser != null) {
      FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: AuthService.currentUser!.email)
          .get()
          .then((QuerySnapshot querySnapshot) {
        for (var doc in querySnapshot.docs) {
          String documentId = doc.id;
          userID = documentId;
          nameCngController.text = doc["name"];
          bioCngController.text = doc['bio'];
          mobileController.text = doc['mobile'];
          cityController.text = doc['city'];
          addressController.text = doc['address'];
        }
      });
    }
  }

  Future<void> updateProfile() async {
    try {
      if (AuthService.currentUser != null) {
        final userRef =
            FirebaseFirestore.instance.collection('users').doc(userID);

        await userRef.update({
          'name': nameCngController.text,
          'bio': bioCngController.text,
          'mobile': mobileController.text,
          'city': cityController.text,
          'address': addressController.text
        });

        FirebaseFirestore.instance
            .collection('posts')
            .where('userId', isEqualTo: AuthService.currentUser!.uid)
            .get()
            .then((QuerySnapshot postQuerySnapshot) {
          for (var postDoc in postQuerySnapshot.docs) {
            FirebaseFirestore.instance
                .collection('posts')
                .doc(postDoc.id)
                .update({'name': nameCngController.text});
          }
        });

        // Show a success message to the user
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green,
            content: Text(
              'Profile Info updated successfully!',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Roboto',
              ),
            )));
      }
    } catch (e) {
      // Show an error message if something goes wrong
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.redAccent,
          content: Text(
            'Error updating profile Info.',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Roboto',
            ),
          )));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back)),
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Roboto',
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white, size: 35.0),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Profile Information",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Roboto',
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            const Text(
              "Name",
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Roboto',
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            TextField(
              cursorColor: const Color(0xFF39b54a),
              style: const TextStyle(color: Colors.black),
              controller: nameCngController,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Color(0xFF39b54a), width: 2.0),
                  ),
                  hintText: "Your Name",
                  suffixIcon: Icon(Icons.edit, color: Color(0xFF39b54a))),
            ),
            const SizedBox(
              height: 5,
            ),
            const Text(
              "Bio",
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Roboto',
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            TextField(
              cursorColor: const Color(0xFF39b54a),
              style: const TextStyle(color: Colors.black),
              maxLength: 50,
              controller: bioCngController,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Color(0xFF39b54a), width: 2.0),
                  ),
                  hintText: "Your Bio",
                  suffixIcon: Icon(Icons.edit, color: Color(0xFF39b54a))),
            ),
            const SizedBox(
              height: 5,
            ),
            const Text(
              "Email",
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Roboto',
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            TextField(
                enabled: false,
                decoration: InputDecoration(
                  hintText: AuthService.currentUser!.email,
                  border: const OutlineInputBorder(),
                  focusedBorder: const OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Color(0xFF39b54a), width: 2.0),
                  ),
                )),
            const SizedBox(
              height: 5,
            ),
            const Text(
              "Mobile Number",
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Roboto',
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            TextField(
              cursorColor: const Color(0xFF39b54a),
              keyboardType: TextInputType.phone,
              style: const TextStyle(color: Colors.black),
              maxLength: 12,
              controller: mobileController,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Color(0xFF39b54a), width: 2.0),
                  ),
                  hintText: "Your Mobile Number",
                  suffixIcon: Icon(Icons.edit, color: Color(0xFF39b54a))),
            ),
            const SizedBox(
              height: 5,
            ),
            const Text(
              "Your City",
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Roboto',
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            TextField(
              cursorColor: const Color(0xFF39b54a),
              style: const TextStyle(color: Colors.black),
              maxLength: 50,
              controller: cityController,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Color(0xFF39b54a), width: 2.0),
                  ),
                  hintText: "Your City",
                  suffixIcon: Icon(
                    Icons.edit,
                    color: Color(0xFF39b54a),
                  )),
            ),
            const SizedBox(
              height: 15,
            ),
            const Text(
              "Your address",
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Roboto',
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            TextField(
              cursorColor: const Color(0xFF39b54a),
              style: const TextStyle(color: Colors.black),
              maxLength: 200,
              controller: addressController,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Color(0xFF39b54a), width: 2.0),
                  ),
                  hintText: "Your address",
                  suffixIcon: Icon(
                    Icons.edit,
                    color: Color(0xFF39b54a),
                  )),
            ),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green, // Background color
                ),
                onPressed: () async {
                  await updateProfile();
                  Navigator.pop(context);
                },
                child: const Text(
                  'Save',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
