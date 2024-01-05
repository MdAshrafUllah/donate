// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PostService {
  static showConfirmationDialog({
    required BuildContext context,
    required String title,
    required String content,
    required VoidCallback deletePostList,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            "Do you want to Delete this post?",
            style: TextStyle(color: Colors.black, fontSize: 18),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                await deletePost(content, context);
                Navigator.pop(context);
                deletePostList();
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  static Future<void> deletePost(String postId, BuildContext context) async {
    final CollectionReference postsCollection =
        FirebaseFirestore.instance.collection('posts');
    DocumentSnapshot postSnapshot = await postsCollection.doc(postId).get();
    if (postSnapshot.exists) {
      await postsCollection.doc(postId).delete();

      CollectionReference commentsCollection =
          postsCollection.doc(postId).collection('comments');
      QuerySnapshot commentsSnapshot = await commentsCollection.get();
      for (var commentDoc in commentsSnapshot.docs) {
        commentDoc.reference.delete();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.redAccent,
          content: Text(
            'You deleted a Post',
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
