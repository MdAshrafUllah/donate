import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../widget/initialize_current_user.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  late List<QueryDocumentSnapshot> deliveryList = [];
  late List<QueryDocumentSnapshot> receiverList = [];
  late Map<String, String> senderNames = {};
  late Map<String, String> postTitles = {};
  late Map<String, String> postsImages = {};

  @override
  void initState() {
    super.initState();
    fetchDeliveryList();
    fetchReceiverList();
  }

  Future<void> fetchDeliveryList() async {
    try {
      if (AuthService.currentUser != null) {
        final currentUserId = AuthService.currentUser!.uid;

        QuerySnapshot deliverySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUserId)
            .collection('Deliver')
            .get();

        setState(() {
          deliveryList = deliverySnapshot.docs;
        });

        await fetchNotificationsInfo(deliveryList);
      }
    } catch (e) {
      print('Error fetching delivery notifications: $e');
    }
  }

  Future<void> fetchReceiverList() async {
    try {
      if (AuthService.currentUser != null) {
        final currentUserId = AuthService.currentUser!.uid;

        QuerySnapshot receiverSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUserId)
            .collection('receiver')
            .get();

        setState(() {
          receiverList = receiverSnapshot.docs;
        });

        await fetchNotificationsInfo(receiverList);
      }
    } catch (e) {
      print('Error fetching received notifications: $e');
    }
  }

  Future<void> fetchNotificationsInfo(
      List<QueryDocumentSnapshot> notificationList) async {
    for (var doc in notificationList) {
      String senderId = doc['senderId'];
      String postId = doc['postId'];

      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(senderId)
          .get();

      DocumentSnapshot postSnapshot = await FirebaseFirestore.instance
          .collection('posts')
          .doc(postId)
          .get();

      setState(() {
        senderNames[senderId] = userSnapshot['name'];
        postTitles[postId] = postSnapshot['title'] ?? '';
        List<dynamic> images = postSnapshot['foodImages'] ?? [];
        postsImages[postId] = images.isNotEmpty ? images[0] : '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: deliveryList.isEmpty && receiverList.isEmpty
            ? Center(
                child: Text("You don't have any Notifications"),
              )
            : ListView(
                children: [
                  if (deliveryList.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, "/foodDeliver");
                            },
                            child: ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: deliveryList.length,
                              itemBuilder: (context, index) {
                                String senderId =
                                    deliveryList[index]['senderId'];
                                String postId = deliveryList[index]['postId'];
                                return ListTile(
                                  leading: Image.network(
                                    postsImages[postId] ??
                                        'https://via.placeholder.com/150',
                                    errorBuilder: (BuildContext context,
                                        Object exception,
                                        StackTrace? stackTrace) {
                                      return const Icon(Icons.error);
                                    },
                                  ),
                                  title: Text(
                                      "${senderNames[senderId]} wants to deliver your food"),
                                  subtitle:
                                      Text('Post Title: ${postTitles[postId]}'),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (receiverList.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, "/foodReceiver");
                            },
                            child: ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: receiverList.length,
                              itemBuilder: (context, index) {
                                String senderId =
                                    receiverList[index]['senderId'];
                                String postId = receiverList[index]['postId'];

                                return ListTile(
                                  leading: Image.network(
                                    postsImages[postId] ??
                                        'https://via.placeholder.com/150',
                                    errorBuilder: (BuildContext context,
                                        Object exception,
                                        StackTrace? stackTrace) {
                                      return const Icon(Icons.error);
                                    },
                                  ),
                                  title: Text(
                                      "${senderNames[senderId]} wants to receive your food"),
                                  subtitle:
                                      Text('Post Title: ${postTitles[postId]}'),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}
