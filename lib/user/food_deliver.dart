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
      print('Error fetching post owner\'s deliver list: $e');
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
      // Remove the document from the collection 'receiver'
      await FirebaseFirestore.instance
          .collection('users')
          .doc(AuthService.currentUser!.uid)
          .collection('Deliver')
          .doc(requestId)
          .delete();

      // Update the UI by refetching the receiverList after deletion
      await fetchDeliveryList();
    } catch (e) {
      print('Error canceling request: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
            title: const Text("Food Deliver"),
          ),
          body: deliveryList.isEmpty
              ? Center(
                  child: Text("You don't have Delivery Data"),
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
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                ),
                                child: Text('Accept'),
                              ),
                              SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () {
                                  cancelRequest(deliveryList[index].id);
                                },
                                style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    backgroundColor: Colors.red),
                                child: Text('Cancel'),
                              ),
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
