import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../widget/initialize_current_user.dart';

class FirestoreManager {
  static Future<List<QueryDocumentSnapshot>> fetchCompleteList(
      String collectionPath) async {
    List<QueryDocumentSnapshot> completeList = [];

    try {
      if (AuthService.currentUser != null) {
        final currentUserId = AuthService.currentUser!.uid;

        QuerySnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUserId)
            .collection(collectionPath)
            .get();

        completeList = userSnapshot.docs;
      }
    } catch (e) {
      debugPrint('Error fetching complete list: $e');
    }

    return completeList;
  }
}
