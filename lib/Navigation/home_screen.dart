import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:utsargo/Navigation/item_details_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _locationController = TextEditingController();
  List<Map<String, dynamic>> listItem = [];

  @override
  void initState() {
    super.initState();
    fetchPosts();
  }

  Future<void> fetchPosts() async {
    try {
      QuerySnapshot posts =
          await FirebaseFirestore.instance.collection('posts').get();

      List<Map<String, dynamic>> postList = posts.docs.map((doc) {
        String firstImageUrl = doc['foodImages'][0];

        return {
          'image': firstImageUrl,
          'subtitle': doc['district'],
          'title': doc['title'],
          'productId': doc['productId'],
          'isSaved': false,
        };
      }).toList();
      setState(() {
        listItem = postList;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error fetching posts: $e"),
        ),
      );
    }
  }

  Future<void> _handleRefresh() async {
    await fetchPosts();
    await Future.delayed(const Duration(seconds: 1));
  }

  Future<void> savePost(Map<String, dynamic> post) async {
    try {
      final String userId = FirebaseAuth.instance.currentUser?.uid ?? '';

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

          // Update local list to reflect the change
          setState(() {
            listItem.forEach((item) {
              if (item['productId'] == post['productId']) {
                item['isSaved'] = false;
              }
            });
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
        } else {
          // Post is not saved, add it
          await savedPostsRef.add(post);

          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green,
            content: Text(
              'Post saved successfully!',
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

  Future<void> fetchSavedPosts() async {
    try {
      final String userId = FirebaseAuth.instance.currentUser?.uid ?? '';

      if (userId.isNotEmpty) {
        QuerySnapshot savedPostsSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('save post')
            .get();

        Set<String> savedProductIds = Set<String>.from(
            savedPostsSnapshot.docs.map((doc) => doc['productId']));

        setState(() {
          listItem.forEach((post) {
            if (savedProductIds.contains(post['productId'])) {
              post['isSaved'] = true;
            } else {
              post['isSaved'] = false;
            }
          });
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.red,
        content: Text(
          'Error fetching saved posts',
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
    fetchSavedPosts();
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(
                  Icons.location_on,
                  color: Color(0xFF39b54a),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.only(
                      left: size.width / 30,
                      right: size.width / 30,
                    ),
                    height: size.height / 20,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Colors.grey[200],
                      border: Border.all(width: 1, color: Colors.black26),
                    ),
                    alignment: Alignment.center,
                    child: TextField(
                      controller: _locationController,
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: size.width / 30,
                        fontWeight: FontWeight.bold,
                      ),
                      keyboardType: TextInputType.emailAddress,
                      cursorColor: const Color(0xFF39b54a),
                      decoration: InputDecoration(
                        hintText: 'Location',
                        hintStyle: TextStyle(
                          color: Colors.black54,
                          fontSize: size.width / 30,
                          fontWeight: FontWeight.bold,
                        ),
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                MaterialButton(
                  minWidth: size.width / 20,
                  height: size.height / 20,
                  onPressed: () {},
                  color: const Color(0xFF39b54a),
                  child: Text(
                    'Go',
                    style: TextStyle(
                        fontSize: size.width / 22, color: Colors.white),
                  ),
                )
              ],
            ),
            const SizedBox(
              height: 15,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    Scaffold.of(context).openDrawer();
                  },
                  child: Row(
                    children: [
                      const Icon(
                        Icons.filter_alt,
                        color: Color(0xFF39b54a),
                      ),
                      Text(
                        'Filter',
                        style: TextStyle(fontSize: size.width / 24),
                      )
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 15,
            ),
            Expanded(
              child: RefreshIndicator(
                color: const Color(0xFF39b54a),
                onRefresh: _handleRefresh,
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2),
                  itemCount: listItem.length,
                  itemBuilder: (context, index) {
                    Map<String, dynamic> currentItem = listItem[index];

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
                        elevation: 0,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: size.height / 6.5,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    width: 2, color: const Color(0xFF39b54a)),
                                image: DecorationImage(
                                  image: NetworkImage(currentItem["image"]),
                                  fit: BoxFit.cover,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: MaterialButton(
                                      onPressed: () {
                                        setState(() {
                                          currentItem["isSaved"] =
                                              !currentItem["isSaved"];
                                        });
                                        savePost(currentItem);
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
                                            ? Icons.bookmark
                                            : Icons.bookmark_border,
                                        size: size.height * 0.03,
                                        color: currentItem["isSaved"]
                                            ? const Color(0xFF39b54a)
                                            : Colors.black,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  color: const Color(0xFF39b54a),
                                  size: size.width * 0.035,
                                ),
                                Text(
                                  currentItem["subtitle"],
                                  style: TextStyle(
                                    fontSize: size.width * 0.035,
                                    color: Colors.black,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                            Expanded(
                              child: Text(
                                currentItem["title"],
                                style: TextStyle(
                                    fontSize: size.width * 0.045,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                    height: 1),
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
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, "/addPostScreen");
        },
        backgroundColor: const Color(0xFF39b54a),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}
