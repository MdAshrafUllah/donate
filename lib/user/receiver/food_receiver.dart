// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../widget/initialize_current_user.dart';

class FoodReceiver extends StatefulWidget {
  const FoodReceiver({super.key});
  @override
  State<FoodReceiver> createState() => _FoodReceiverState();
}

class _FoodReceiverState extends State<FoodReceiver> {
  late List<QueryDocumentSnapshot> receiverList = [];
  late Map<String, String> senderNames = {};
  late Map<String, String> postTitles = {};
  late Map<String, String> postsImages = {};
  @override
  void initState() {
    super.initState();
    fetchReceiverList();
  }

  Future<void> fetchReceiverList() async {
    try {
      if (AuthService.currentUser != null) {
        final currentUserId = AuthService.currentUser!.uid;
        QuerySnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUserId)
            .collection('receiver')
            .get();
        setState(() {
          receiverList = userSnapshot.docs;
        });
        await fetchSenderNames();
        await fetchPostTitlesAndImages();
      }
    } catch (e) {
      debugPrint('Error fetching post owner\'s receiver list: $e');
    }
  }

  Future<void> fetchSenderNames() async {
    for (var doc in receiverList) {
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
    for (var doc in receiverList) {
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
          .collection('receiver')
          .doc(requestId)
          .delete();
      await fetchReceiverList();
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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
            title: const Text("Food Receiver"),
          ),
          body: receiverList.isEmpty
              ? const Center(
                  child: Text("You don't have Receiver Data"),
                )
              : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListView.builder(
                    itemCount: receiverList.length,
                    itemBuilder: (context, index) {
                      String senderId = receiverList[index]['senderId'];
                      String postId = receiverList[index]['postId'];
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
                              "${senderNames[senderId]} want to receive your food"),
                          subtitle: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ElevatedButton(
                                onPressed: () async {
                                  String senderId =
                                      receiverList[index]['senderId'];
                                  String postId = receiverList[index]['postId'];
                                  try {
                                    await saveProductDetails(senderId, postId);
                                  } catch (e) {
                                    debugPrint(
                                        'Error accepting request and saving product details: $e');
                                  }
                                  await cancelRequest(receiverList[index].id);
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
                                  cancelRequest(receiverList[index].id);
                                },
                                style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    backgroundColor: Colors.red),
                                child: const Text('Cancel'),
                              ),
                              const Spacer(),
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
          .collection('forReceive')
          .add({
        'senderId': AuthService.currentUser!.uid,
        'postId': postId,
      });
    } catch (e) {
      debugPrint('Error saving product details: $e');
      rethrow;
    }
  }
}
