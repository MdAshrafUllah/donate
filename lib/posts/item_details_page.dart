import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:utsargo/widget/initialize_current_user.dart';

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

  bool sentRequest = false;
  bool sentDeliveryRequest = false;

  @override
  void initState() {
    super.initState();
    fetchPosts();
    fetchSavedPosts();
    fetchPostOwnersReceiverList();
    fetchPostOwnersDeliveryList();
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
          'email': doc['email']
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

  Future<void> fetchPostOwnersReceiverList() async {
    try {
      final postId = productlistItem.isNotEmpty
          ? productlistItem[0]['productId'] ?? ''
          : '';

      if (postId.isNotEmpty && FirebaseAuth.instance.currentUser != null) {
        final currentUserId = FirebaseAuth.instance.currentUser!.uid;

        QuerySnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: productlistItem[0]['email'])
            .get();

        if (userSnapshot.docs.isNotEmpty) {
          String userId = userSnapshot.docs[0].id;

          QuerySnapshot receiverSnapshot = await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .collection('receiver')
              .where('postId', isEqualTo: postId)
              .get();

          if (receiverSnapshot.docs.isNotEmpty) {
            receiverSnapshot.docs.forEach((doc) {
              if (doc['senderId'] == currentUserId) {
                setState(() {
                  sentRequest = true;
                });
              }
            });
          }
        }
      }
    } catch (e) {
      print('Error fetching post owner\'s receiver list: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
          content: Text(
            'Error fetching receiver list',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Roboto',
            ),
          ),
        ),
      );
    }
  }

  Future<void> fetchPostOwnersDeliveryList() async {
    try {
      final postId = productlistItem.isNotEmpty
          ? productlistItem[0]['productId'] ?? ''
          : '';

      if (postId.isNotEmpty && FirebaseAuth.instance.currentUser != null) {
        final currentUserId = FirebaseAuth.instance.currentUser!.uid;

        QuerySnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: productlistItem[0]['email'])
            .get();

        if (userSnapshot.docs.isNotEmpty) {
          String userId = userSnapshot.docs[0].id;

          QuerySnapshot deliverSnapshot = await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .collection('Deliver')
              .where('postId', isEqualTo: postId)
              .get();

          if (deliverSnapshot.docs.isNotEmpty) {
            deliverSnapshot.docs.forEach((doc) {
              if (doc['senderId'] == currentUserId) {
                setState(() {
                  sentDeliveryRequest = true;
                  print("<>|<>$sentDeliveryRequest<>|<>");
                });
              }
            });
          }
        }
      }
    } catch (e) {
      print('Error fetching post owner\'s receiver list: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
          content: Text(
            'Error fetching receiver list',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Roboto',
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    List<String> foodImages = productlistItem.isNotEmpty
        ? List<String>.from(productlistItem[0]['images'])
        : [];

    if (productlistItem.isEmpty) {
      return SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Item Details'),
          ),
          body: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }
    fetchSavedPosts();
    fetchPostOwnersReceiverList();
    fetchPostOwnersDeliveryList();

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

    final currentUserEmail = FirebaseAuth.instance.currentUser?.email ?? '';
    final bool isCurrentUserOwner = productlistItem.isNotEmpty &&
        productlistItem[0]['email'] == currentUserEmail;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Item Details'),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Stack(
                children: [
                  InkWell(
                    onTap: () {
                      print(currentIndex);
                    },
                    child: CarouselSlider(
                      items: foodImages.map((item) {
                        return Builder(
                          builder: (BuildContext context) {
                            return Image.network(
                              item,
                              fit: BoxFit.contain,
                              width: double.infinity,
                            );
                          },
                        );
                      }).toList(),
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
                    child: Container(
                      height: 20,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: foodImages.asMap().entries.map((entry) {
                          return GestureDetector(
                            onTap: () =>
                                carouselController.animateToPage(entry.key),
                            child: Container(
                              width: currentIndex == entry.key ? 10 : 10,
                              height: 10.0,
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 3.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: currentIndex == entry.key
                                    ? Color(0xFF39b54a)
                                    : Colors.grey,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: size.width * 0.05,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: Color(0xFF39b54a),
                        ),
                        Text(
                          subtitle,
                          style: TextStyle(fontSize: size.width * 0.04),
                        ),
                      ],
                    ),
                    Text(
                      'Description: $description',
                      style: TextStyle(fontSize: size.width * 0.04),
                    ),
                    Text(
                      'FoodType: $foodType',
                      style: TextStyle(fontSize: size.width * 0.04),
                    ),
                    Text(
                      'Quantity: $quantity',
                      style: TextStyle(fontSize: size.width * 0.04),
                    ),
                    Text(
                      'Mobile: $mobile',
                      style: TextStyle(fontSize: size.width * 0.04),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: size.height * 0.05,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    MaterialButton(
                      onPressed: () {
                        setState(() {
                          productlistItem[0]['isSaved'] =
                              !productlistItem[0]['isSaved'];
                        });
                        savePost(productlistItem[0]);
                      },
                      color: Colors.white,
                      minWidth: size.width * 0.001,
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
                    if (!isCurrentUserOwner)
                      sentRequest
                          ? OutlinedButton(
                              onPressed: () {},
                              child: const Text("Requested"),
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                            )
                          : ElevatedButton(
                              onPressed: () async {
                                sendRequest();
                              },
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                              child: Text(
                                'Want to Received',
                                style: TextStyle(fontSize: size.width * 0.035),
                              ),
                            ),
                    if (!isCurrentUserOwner)
                      sentDeliveryRequest
                          ? OutlinedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  side: BorderSide(
                                    color: Colors.amber,
                                  ),
                                ),
                              ),
                              child: const Text(
                                "Requested",
                                style: TextStyle(
                                  color: Colors.amber,
                                ),
                              ),
                            )
                          : ElevatedButton(
                              onPressed: () {
                                wantDeliver();
                              },
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                backgroundColor: Colors.amber,
                                foregroundColor: Colors.black,
                              ),
                              child: Text(
                                'Want to Deliver',
                                style: TextStyle(fontSize: size.width * 0.035),
                              ),
                            ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void sendRequest() async {
    try {
      final email =
          productlistItem.isNotEmpty ? productlistItem[0]['email'] ?? '' : '';
      final postId = productlistItem.isNotEmpty
          ? productlistItem[0]['productId'] ?? ''
          : '';

      if (email != null &&
          email.isNotEmpty &&
          FirebaseAuth.instance.currentUser != null) {
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where("email", isEqualTo: email)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          String receiverUserId = querySnapshot.docs[0].id;

          await FirebaseFirestore.instance
              .collection('users')
              .doc(receiverUserId)
              .collection('receiver')
              .add({
            'postId': postId,
            'senderId': FirebaseAuth.instance.currentUser!.uid,
            'timestamp': DateTime.now(),
            // Add other relevant data for the request
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.green,
              content: Text(
                'Request sent successfully!',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Roboto',
                ),
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.red,
              content: Text(
                'No user found with the specified email',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Roboto',
                ),
              ),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
            content: Text(
              'Email is null, empty, or user is not logged in',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Roboto',
              ),
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
          content: Text(
            'Error saving request: $e',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Roboto',
            ),
          ),
        ),
      );
    }
  }

  void wantDeliver() async {
    try {
      final email =
          productlistItem.isNotEmpty ? productlistItem[0]['email'] ?? '' : '';
      final postId = productlistItem.isNotEmpty
          ? productlistItem[0]['productId'] ?? ''
          : '';

      if (email != null &&
          email.isNotEmpty &&
          FirebaseAuth.instance.currentUser != null) {
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where("email", isEqualTo: email)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          String deliveryUserId = querySnapshot.docs[0].id;

          await FirebaseFirestore.instance
              .collection('users')
              .doc(deliveryUserId)
              .collection('Deliver')
              .add({
            'postId': postId,
            'senderId': FirebaseAuth.instance.currentUser!.uid,
            'timestamp': DateTime.now(),
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.green,
              content: Text(
                'Request sent successfully!',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Roboto',
                ),
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.red,
              content: Text(
                'No user found with the specified email',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Roboto',
                ),
              ),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
            content: Text(
              'Email is null, empty, or user is not logged in',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Roboto',
              ),
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
          content: Text(
            'Error saving request: $e',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Roboto',
            ),
          ),
        ),
      );
    }
  }
}
