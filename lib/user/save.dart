import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../posts/item_details_page.dart';
import '../widget/initialize_current_user.dart';

class SaveItemsScreen extends StatefulWidget {
  const SaveItemsScreen({Key? key});

  @override
  State<SaveItemsScreen> createState() => _SaveItemsScreenState();
}

class _SaveItemsScreenState extends State<SaveItemsScreen> {
  List<Map<String, dynamic>> savedPosts = [];

  @override
  void initState() {
    super.initState();
    fetchSavedPosts();
  }

  Future<void> fetchSavedPosts() async {
    if (AuthService.currentUser != null) {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(AuthService.currentUser!.uid)
          .collection('save post')
          .get();

      List<Map<String, dynamic>> posts = [];

      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> postData = doc.data() as Map<String, dynamic>;
        posts.add(postData);
      }

      setState(() {
        savedPosts = posts;
      });
    }
  }

  Future<void> savePost(Map<String, dynamic> post) async {
    try {
      final String userId = AuthService.currentUser!.uid;

      if (userId.isNotEmpty) {
        final CollectionReference savedPostsRef = FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('save post');

        QuerySnapshot querySnapshot = await savedPostsRef
            .where('productId', isEqualTo: post['productId'])
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          // Post is already saved, delete it
          await Future.forEach(querySnapshot.docs, (doc) async {
            await savedPostsRef.doc(doc.id).delete();
          });
          await fetchSavedPosts();

          // Update local list to reflect the change
          setState(() {
            for (var item in savedPosts) {
              if (item['productId'] == post['productId']) {
                item['isSaved'] = false;
              }
            }
          });

          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
            content: Text(
              'Post removed from saved!',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Roboto',
              ),
            ),
          ));
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.red,
        content: Text(
          "Error saving post",
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
          title: const Text("Saved Posts"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView.builder(
            itemCount: savedPosts.length,
            itemBuilder: (context, index) {
              Map<String, dynamic> currentItem = savedPosts[index];

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ItemDetailsScreen(
                        listItem: {'productId': currentItem['productId']},
                      ),
                    ),
                  );
                },
                child: Card(
                  child: Row(
                    children: [
                      Expanded(
                        child: ListTile(
                          leading: Image.network(
                            currentItem['image'] ??
                                'https://via.placeholder.com/150',
                            // Replace with your error widget if image fails to load
                            errorBuilder: (BuildContext context,
                                Object exception, StackTrace? stackTrace) {
                              return const Icon(Icons.error);
                            },
                          ),
                          title: Text(currentItem['title'] ??
                              ''), // Handling null values
                          subtitle: Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                color: const Color(0xFF39b54a),
                                size: size.width * 0.035,
                              ),
                              Text(currentItem['subtitle'] ?? ''),
                            ],
                          ), // Handling null values
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: MaterialButton(
                          onPressed: () {
                            setState(() {
                              currentItem["isSaved"] = !currentItem["isSaved"];
                              savePost(currentItem);
                            });
                          },
                          color: Colors.white,
                          height: size.height * 0.04,
                          minWidth: size.width * 0.085,
                          padding: const EdgeInsets.all(0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            currentItem["isSaved"]
                                ? Icons.bookmark_border
                                : Icons.bookmark,
                            size: size.height * 0.03,
                            color: currentItem["isSaved"]
                                ? Colors.black
                                : const Color(0xFF39b54a),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
