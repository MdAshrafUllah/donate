import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carousel_slider/carousel_slider.dart';

class ItemDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> listItem;

  ItemDetailsScreen({required this.listItem});

  @override
  State<ItemDetailsScreen> createState() => _ItemDetailsScreenState();
}

class _ItemDetailsScreenState extends State<ItemDetailsScreen> {
  List<Map<String, dynamic>> productlistItem = [];
  final CarouselController carouselController = CarouselController();
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    fetchPosts();
    fetchSavedPosts();
  }

  Future<void> fetchPosts() async {
    try {
      QuerySnapshot posts = await FirebaseFirestore.instance
          .collection('posts')
          .where('productId', isEqualTo: widget.listItem['productId'])
          .get();

      List<Map<String, dynamic>> postList = posts.docs.map((doc) {
        List<dynamic> foodImages = doc['foodImages'];

        return {
          'images': foodImages,
          'subtitle': doc['district'],
          'title': doc['title'],
          'isSaved': false,
          'productId': doc['productId'],
          'description': doc['description'],
          'foodType': doc['foodType'],
          'quantity': doc['quantity'],
          'mobile': doc['mobile'],
        };
      }).toList();

      setState(() {
        productlistItem = postList;
      });
    } catch (e) {
      print("Error fetching posts: $e");
    }
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
          await savedPostsRef.add({
            ...post,
            'isSaved': true, // Include 'isSaved' field when saving to Firestore
          });

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

        setState(() {
          for (int i = 0; i < productlistItem.length; i++) {
            if (productlistItem[i]['productId'] == post['productId']) {
              productlistItem[i]['isSaved'] = !querySnapshot.docs.isNotEmpty;
              break;
            }
          }
        });
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
          productlistItem.forEach((post) {
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

  Future<void> _handleRefresh() async {
    await fetchPosts();
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    List<String> foodImages = productlistItem.isNotEmpty
        ? List<String>.from(productlistItem[0]['images'])
        : [];
    if (productlistItem.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Item Details'),
        ),
        body: Center(
          child:
              CircularProgressIndicator(), // Display a loading indicator if data is being fetched
        ),
      );
    }
    fetchSavedPosts();

    String title =
        productlistItem.isNotEmpty ? productlistItem[0]['title'] ?? '' : '';
    String subtitle =
        productlistItem.isNotEmpty ? productlistItem[0]['subtitle'] ?? '' : '';
    String description = productlistItem.isNotEmpty
        ? productlistItem[0]['description'] ?? ''
        : '';
    String foodType =
        productlistItem.isNotEmpty ? productlistItem[0]['foodType'] ?? '' : '';
    String quantity =
        productlistItem.isNotEmpty ? productlistItem[0]['quantity'] ?? '' : '';
    String mobile =
        productlistItem.isNotEmpty ? productlistItem[0]['mobile'] ?? '' : '';

    return Scaffold(
      appBar: AppBar(
        title: Text('Item Details'),
      ),
      body: RefreshIndicator(
        color: const Color(0xFF39b54a),
        onRefresh: _handleRefresh,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      InkWell(
                        onTap: () {
                          print(currentIndex);
                        },
                        child: CarouselSlider(
                          items: foodImages
                              .map(
                                (item) => Image.network(
                                  item,
                                  fit: BoxFit.contain,
                                  width: double.infinity,
                                ),
                              )
                              .toList(),
                          carouselController: carouselController,
                          options: CarouselOptions(
                            scrollPhysics: const BouncingScrollPhysics(),
                            autoPlay: false,
                            aspectRatio: 1,
                            viewportFraction: 1,
                            onPageChanged: (index, reason) {
                              setState(() {
                                currentIndex = index;
                              });
                            },
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 10,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: foodImages.asMap().entries.map((entry) {
                            return GestureDetector(
                              onTap: () =>
                                  carouselController.animateToPage(entry.key),
                              child: Container(
                                width: currentIndex == entry.key ? 10 : 10,
                                height: 10.0,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 3.0,
                                ),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: currentIndex == entry.key
                                        ? Color(0xFF39b54a)
                                        : Colors.grey),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    title, // Accessing title of first item
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                    subtitle, // Accessing subtitle of first item
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Description: $description', // Accessing description of first item
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'FoodType: $foodType', // Accessing foodType of first item
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Quantity: $quantity', // Accessing quantity of first item
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Mobile: $mobile', // Accessing mobile of first item
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: MaterialButton(
                    onPressed: () {
                      setState(() {
                        productlistItem[0]['isSaved'] =
                            !productlistItem[0]['isSaved'];
                      });
                      savePost(productlistItem[0]);
                    },
                    color: Colors.white,
                    height: size.height * 0.04,
                    minWidth: size.width * 0.085,
                    padding: const EdgeInsets.all(0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      productlistItem[0]['isSaved']
                          ? Icons.bookmark
                          : Icons.bookmark_border,
                      size: size.height * 0.03,
                      color: productlistItem[0]['isSaved']
                          ? const Color(0xFF39b54a)
                          : Colors.black,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  child: Text('Want to Received'),
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.black),
                  child: Text('Want to Deliver'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
