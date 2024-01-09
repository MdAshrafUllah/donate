import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import '../../widget/initialize_current_user.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  late List<QueryDocumentSnapshot> deliveryList = [];
  late List<QueryDocumentSnapshot> receiverList = [];
  late Map<String, String> senderNames = {};
  late Map<String, String> postTitles = {};
  late Map<String, String> postsImages = {};
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchNotificationList();
  }

  Future<void> fetchNotificationList() async {
    try {
      setState(() {
        isLoading = true;
      });
      if (AuthService.currentUser != null) {
        final currentUserId = AuthService.currentUser!.uid;

        QuerySnapshot deliverySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUserId)
            .collection('Deliver')
            .get();

        QuerySnapshot receiverSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUserId)
            .collection('receiver')
            .get();

        setState(() {
          deliveryList = deliverySnapshot.docs;
          receiverList = receiverSnapshot.docs;
        });
        await fetchNotificationsInfo(deliveryList);
        await fetchNotificationsInfo(receiverList);
      }
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching delivery notifications: $e');
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
        body: ModalProgressHUD(
          inAsyncCall: isLoading,
          child: RefreshIndicator(
            onRefresh: () async {
              setState(() {});
              return Future<void>.delayed(const Duration(seconds: 1));
            },
            child: deliveryList.isEmpty && receiverList.isEmpty
                ? const Padding(
                    padding: EdgeInsets.only(top: 100),
                    child: Center(
                      child: Text("You don't have any Notifications"),
                    ),
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
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: deliveryList.length,
                                  itemBuilder: (context, index) {
                                    String senderId =
                                        deliveryList[index]['senderId'];
                                    String postId =
                                        deliveryList[index]['postId'];
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
                                      subtitle: Text(
                                          'Post Title: ${postTitles[postId]}'),
                                    );
                                  },
                                ),
                              ),
                              const Divider()
                            ],
                          ),
                        ),
                      if (receiverList.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(left: 8, right: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(context, "/foodReceiver");
                                },
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: receiverList.length,
                                  itemBuilder: (context, index) {
                                    String senderId =
                                        receiverList[index]['senderId'];
                                    String postId =
                                        receiverList[index]['postId'];

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
                                      subtitle: Text(
                                          'Post Title: ${postTitles[postId]}'),
                                    );
                                  },
                                ),
                              ),
                              const Divider()
                            ],
                          ),
                        ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
