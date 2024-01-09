import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:utsargo/widget/initialize_current_user.dart';

import '../donate/sender_delivery_status.dart';

class DonateList extends StatefulWidget {
  const DonateList({super.key});

  @override
  State<DonateList> createState() => _DonateListState();
}

class _DonateListState extends State<DonateList> {
  late List<QueryDocumentSnapshot> donateList = [];
  late List<QueryDocumentSnapshot> completeList = [];
  late Map<String, String> senderNames = {};
  late Map<String, String> postTitles = {};
  late Map<String, String> postsImages = {};

  @override
  void initState() {
    super.initState();
    fetchDonateList();
    fetchCompleteList();
  }

  Future<void> fetchDonateList() async {
    try {
      if (AuthService.currentUser != null) {
        final currentUserId = AuthService.currentUser!.uid;

        QuerySnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUserId)
            .collection('forDonate')
            .get();

        setState(() {
          donateList = userSnapshot.docs;
        });

        await fetchSenderNames();
        await fetchPostTitlesAndImages();
      }
    } catch (e) {
      debugPrint('Error fetching post owner\'s deliver list: $e');
    }
  }

  Future<void> fetchCompleteList() async {
    try {
      if (AuthService.currentUser != null) {
        final currentUserId = AuthService.currentUser!.uid;

        QuerySnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUserId)
            .collection('complete Donate')
            .get();

        setState(() {
          completeList = userSnapshot.docs;
        });

        await fetchSenderNames();
        await fetchPostTitlesAndImages();
      }
    } catch (e) {
      debugPrint('Error fetching post owner\'s deliver list: $e');
    }
  }

  Future<void> fetchSenderNames() async {
    for (var doc in donateList) {
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
    for (var doc in donateList) {
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Food Donate List"),
        ),
        body: donateList.isEmpty && completeList.isEmpty
            ? const Center(
                child: Text("You don't have any Food for Donate"),
              )
            : Column(
                children: [
                  if (completeList.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: completeList.length,
                        itemBuilder: (context, index) {
                          String postImage = completeList[index]['postImage'];
                          String postTitle = completeList[index]['postTitle'];

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 15),
                            child: ListTile(
                              leading: Image.network(
                                postImage,
                              ),
                              title: Text(postTitle),
                              trailing: const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  if (donateList.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: donateList.length,
                        itemBuilder: (context, index) {
                          String senderId = donateList[index]['senderId'];
                          String postId = donateList[index]['postId'];

                          return Card(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ListTile(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          SenderDeliveryStatus(
                                        foodImage: postsImages[postId] ??
                                            'https://via.placeholder.com/150',
                                        foodTitle: postTitles[postId] ?? '',
                                        senderId: senderId,
                                        postId: postId,
                                      ),
                                    ),
                                  );
                                },
                                leading: Image.network(
                                  postsImages[postId] ??
                                      'https://via.placeholder.com/150',
                                ),
                                title: Text(
                                  "Your are going to Donate Food to ${senderNames[senderId]}",
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}
