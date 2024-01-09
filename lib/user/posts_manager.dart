import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../posts/item_details_page.dart';
import '../widget/initialize_current_user.dart';
import '../widget/post_delete_services.dart';

class PostsManagerScreen extends StatefulWidget {
  const PostsManagerScreen({super.key});

  @override
  State<PostsManagerScreen> createState() => _PostsManagerScreenState();
}

class _PostsManagerScreenState extends State<PostsManagerScreen> {
  List<Map<String, dynamic>> postsManage = [];

  @override
  void initState() {
    super.initState();
    fetchPosts();
  }

  Future<void> fetchPosts() async {
    FirebaseFirestore.instance
        .collection('posts')
        .where('email', isEqualTo: AuthService.currentUser!.email)
        .get()
        .then((QuerySnapshot postQuerySnapshot) {
      List<Map<String, dynamic>> fetchedPosts = [];

      for (var postDoc in postQuerySnapshot.docs) {
        Map<String, dynamic> postData = postDoc.data() as Map<String, dynamic>;
        fetchedPosts.add({
          'image':
              postData['foodImages'][0] ?? '', // Update with your image logic
          'subtitle': postData['district'] ?? '',
          'title': postData['title'] ?? '',
          'productId': postDoc.id,
          // Add other necessary fields from your document
        });
      }

      setState(() {
        postsManage = fetchedPosts;
      });
    }).catchError((error) {
      debugPrint("Error fetching posts: $error");
    });
  }

  Future<void> _handleRefresh() async {
    await fetchPosts();
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Manage Posts"),
        ),
        body: postsManage.isEmpty
            ? const Center(
                child: Text("You don't have any Posts"),
              )
            : Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView.builder(
                  itemCount: postsManage.length,
                  itemBuilder: (context, index) {
                    Map<String, dynamic> currentItem = postsManage[index];

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
                                      Object exception,
                                      StackTrace? stackTrace) {
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
                                onPressed: () async {
                                  await PostService.showConfirmationDialog(
                                    context: context,
                                    title: currentItem['title'],
                                    content: currentItem['productId'],
                                    deletePostList: _handleRefresh,
                                  );
                                },
                                color: Colors.white,
                                height: size.height * 0.04,
                                minWidth: size.width * 0.085,
                                padding: const EdgeInsets.all(0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.more_vert,
                                  size: size.height * 0.03,
                                  color: Colors.black,
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
