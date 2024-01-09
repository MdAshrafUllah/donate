// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import '../data/bd_districts.dart';
import '../widget/initialize_current_user.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({super.key});

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String selectedDistricts = 'Chattogram';
  bool isLoading = false;
  String imageUrl = ' ';
  final List<File> _selectedImages = [];

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController foodTypeController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController postCodeController = TextEditingController();
  final TextEditingController postOfficeController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  Future<void> _captureImage(ImageSource source) async {
    final pickedImage = await ImagePicker().pickImage(source: source);
    if (pickedImage != null) {
      setState(() {
        _selectedImages.add(File(pickedImage.path));
      });
    }
  }

  void uploadToFirebase() async {
    try {
      if (AuthService.currentUser == null ||
          AuthService.currentUser!.email == null) {
        debugPrint('User or email is null');
        return;
      }

      List<String> downloadUrls = [];

      for (var image in _selectedImages) {
        String fileName =
            '${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(10000)}.jpg';
        Reference ref = FirebaseStorage.instance.ref().child('post/$fileName');
        await ref.putFile(image);
        String downloadUrl = await ref.getDownloadURL();
        downloadUrls.add(downloadUrl);
      }

      String productId =
          FirebaseFirestore.instance.collection('posts').doc().id;

      await FirebaseFirestore.instance.collection('posts').doc(productId).set({
        'productId': productId,
        'email': AuthService.currentUser!.email!,
        'foodImages': downloadUrls,
        'title': titleController.text,
        'description': descriptionController.text,
        'foodType': foodTypeController.text,
        'quantity': quantityController.text,
        'mobile': mobileController.text,
        'address': addressController.text,
        'postCode': postCodeController.text,
        'postOffice': postOfficeController.text,
        'district': selectedDistricts,
      });

      setState(() {
        isLoading = false;
        _selectedImages.clear();
        titleController.text = '';
        descriptionController.text = '';
        foodTypeController.text = '';
        quantityController.text = '';
        mobileController.text = '';
        addressController.text = '';
        postCodeController.text = '';
        postOfficeController.text = '';
        selectedDistricts = 'Chattogram';
      });

      Navigator.pushReplacementNamed(context, "/navigationScreen");

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.green,
        content: Text(
          'Created Post successfully!',
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
          'Error sharing post',
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
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Create Post"),
        ),
        body: ModalProgressHUD(
          inAsyncCall: isLoading,
          opacity: 0.5,
          blur: 0,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (_selectedImages.isNotEmpty)
                            Row(
                              children:
                                  _selectedImages.asMap().entries.map((entry) {
                                final index = entry.key;
                                final image = entry.value;

                                return Stack(
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(right: 8.0),
                                      height: size.height * 0.09,
                                      width: size.width * 0.2,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          width: 2,
                                          color: const Color(0xFF39b54a),
                                        ),
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: Image.file(
                                        image,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Positioned(
                                      top: -12,
                                      left: -12,
                                      child: IconButton(
                                        onPressed: () {
                                          setState(() {
                                            _selectedImages.removeAt(index);
                                          });
                                        },
                                        icon: Container(
                                          decoration: const BoxDecoration(
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.white,
                                                spreadRadius: 0,
                                                blurRadius: 0.5,
                                                offset: Offset(0, 0),
                                              ),
                                            ],
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.cancel,
                                            color: Colors.redAccent,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          const SizedBox(
                            width: 10,
                          ),
                          GestureDetector(
                              onTap: () {
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
                                                  _captureImage(
                                                      ImageSource.camera);
                                                  Navigator.pop(context);
                                                },
                                                leading: const Icon(
                                                  Icons.camera_alt,
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
                                                  _captureImage(
                                                      ImageSource.gallery);
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
                              child: Container(
                                height: size.height * 0.09,
                                width: size.width * 0.2,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    width: 2,
                                    color: const Color(0xFF39b54a),
                                  ),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: Color(0xFF39b54a),
                                ),
                              )),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      controller: titleController,
                      maxLength: 100,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Title",
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: descriptionController,
                      maxLength: 1000,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Description",
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a Description';
                        }
                        return null;
                      },
                    ),
                    Container(
                      constraints:
                          const BoxConstraints(maxWidth: double.infinity),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: foodTypeController,
                              maxLength: 50,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: "Food Type",
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a Food Type';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextFormField(
                              controller: quantityController,
                              keyboardType: TextInputType.number,
                              maxLength: 5,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: "Quantity",
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter Quantity';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextFormField(
                      controller: mobileController,
                      maxLength: 11,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Mobile",
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter Your Mobile';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: addressController,
                      maxLength: 150,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Address",
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please Your Address';
                        }
                        return null;
                      },
                    ),
                    Container(
                      constraints:
                          const BoxConstraints(maxWidth: double.infinity),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: postCodeController,
                              maxLength: 4,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: "Post Code",
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter Your Post Code';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextFormField(
                              controller: postOfficeController,
                              maxLength: 50,
                              keyboardType: TextInputType.text,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: "Post Office",
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter Your Post Office';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      constraints:
                          const BoxConstraints(maxWidth: double.infinity),
                      child: DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Select Districts',
                        ),
                        value: selectedDistricts,
                        onChanged: (newValue) {
                          setState(() {
                            selectedDistricts = newValue!;
                          });
                        },
                        items: districts.map((districts) {
                          return DropdownMenuItem<String>(
                            value: districts['name'],
                            child: Text(districts['name']!),
                          );
                        }).toList(),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a district';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Center(
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate() &&
                              _selectedImages.isNotEmpty) {
                            setState(() {
                              isLoading = true;
                            });
                            uploadToFirebase();
                          } else {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: Colors.red,
                              content: Text(
                                'All Field Are Required include image',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Roboto',
                                ),
                              ),
                            ));
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                          ),
                        ),
                        child: const Text('Post'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
