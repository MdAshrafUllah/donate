// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:utsargo/widget/initialize_current_user.dart';

class FoodDeliver extends StatefulWidget {
  const FoodDeliver({super.key});

  @override
  State<FoodDeliver> createState() => _FoodDeliverState();
}

class _FoodDeliverState extends State<FoodDeliver> {
  late List<QueryDocumentSnapshot> deliveryList = [];
  late Map<String, String> senderNames = {};
  late Map<String, String> postTitles = {};
  late Map<String, String> postsImages = {};

  @override
  void initState() {
    super.initState();
    fetchDeliveryList();
  }

  Future<void> fetchDeliveryList() async {
    try {
      if (AuthService.currentUser != null) {
        final currentUserId = AuthService.currentUser!.uid;

        QuerySnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUserId)
            .collection('Deliver')
            .get();

        setState(() {
          deliveryList = userSnapshot.docs;
        });

        await fetchSenderNames();
        await fetchPostTitlesAndImages();
      }
    } catch (e) {
      debugPrint('Error fetching post owner\'s deliver list: $e');
    }
  }

  Future<void> fetchSenderNames() async {
    for (var doc in deliveryList) {
      String senderId = doc['senderId'];
      DocumentSnapshot senderSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(senderId)
          .get();

      setState(() {
        senderNames[senderId] = senderSnapshot['name'];
      });
    }
  }

  Future<void> fetchPostTitlesAndImages() async {
    for (var doc in deliveryList) {
      String postId = doc['postId'];
      DocumentSnapshot postSnapshot = await FirebaseFirestore.instance
          .collection('posts')
          .doc(postId)
          .get();

      setState(() {
        postTitles[postId] = postSnapshot['title'] ?? '';
        List<dynamic> images = postSnapshot['foodImages'] ?? [];
        postsImages[postId] = images.isNotEmpty ? images[0] : '';
      });
    }
  }

  Future<void> cancelRequest(String requestId) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(AuthService.currentUser!.uid)
          .collection('Deliver')
          .doc(requestId)
          .delete();
      await fetchDeliveryList();
    } catch (e) {
      debugPrint('Error canceling request: $e');
    }
  }

  Future<void> createContact(
      String senderId, String senderName, String senderUid) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(AuthService.currentUser!.uid)
          .collection('contacts')
          .doc(senderId)
          .set({
        'name': senderName,
        'uid': senderUid,
      });

      await FirebaseFirestore.instance
          .collection('users')
          .doc(senderId)
          .collection('contacts')
          .doc(AuthService.currentUser!.uid)
          .set({
        'name': AuthService.currentUser!.displayName,
        'uid': AuthService.currentUser!.uid,
      });

      Navigator.pushReplacementNamed(context, "/navigationScreen",
          arguments: 1);
    } catch (e) {
      debugPrint("Error creating contact: $e");
    }
  }

  Future<void> saveProductDetails(String senderId, String postId) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(AuthService.currentUser!.uid)
          .collection('forDonate')
          .add({
        'senderId': senderId,
        'postId': postId,
      });

      await FirebaseFirestore.instance
          .collection('users')
          .doc(senderId)
          .collection('forDeliver')
          .add({
        'senderId': AuthService.currentUser!.uid,
        'postId': postId,
      });
    } catch (e) {
      debugPrint('Error saving product details: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
            title: const Text("Food Deliver"),
          ),
          body: deliveryList.isEmpty
              ? const Center(
                  child: Text("You don't have Delivers Data"),
                )
              : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListView.builder(
                    itemCount: deliveryList.length,
                    itemBuilder: (context, index) {
                      String senderId = deliveryList[index]['senderId'];
                      String postId = deliveryList[index]['postId'];

                      return Card(
                        child: ListTile(
                          leading: Image.network(
                            postsImages[postId] ??
                                'https://via.placeholder.com/150',
                            errorBuilder: (BuildContext context,
                                Object exception, StackTrace? stackTrace) {
                              return const Icon(Icons.error);
                            },
                          ),
                          title: Text(
                              "${senderNames[senderId]} Want to Deliver Your Food"),
                          subtitle: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ElevatedButton(
                                onPressed: () async {
                                  String senderId =
                                      deliveryList[index]['senderId'];
                                  String postId = deliveryList[index]['postId'];
                                  try {
                                    await saveProductDetails(senderId, postId);
                                  } catch (e) {
                                    debugPrint(
                                        'Error accepting request and saving product details: $e');
                                  }
                                  await cancelRequest(deliveryList[index].id);
                                  Navigator.pushNamed(context, '/donateList');
                                },
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                ),
                                child: const Text('Accept'),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () {
                                  cancelRequest(deliveryList[index].id);
                                },
                                style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    backgroundColor: Colors.red),
                                child: const Text('Cancel'),
                              ),
                              IconButton(
                                onPressed: () {
                                  createContact(
                                      senderId,
                                      senderNames[senderId].toString(),
                                      senderId);
                                },
                                icon: Icon(
                                  Icons.chat,
                                  size: size.width * 0.1,
                                ),
                                color: const Color(0xFF39b54a),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                )),
    );
  }
}
