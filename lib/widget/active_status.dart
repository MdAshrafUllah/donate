import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'initialize_current_user.dart';

String userID = '';
void statusOffline() {
  if (AuthService.currentUser != null) {
    FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: AuthService.currentUser!.email)
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        String documentId = doc.id;
        userID = documentId;
        setStatus("offline");
      }
    });
  }
}

void statusOnline() {
  if (AuthService.currentUser != null) {
    FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: AuthService.currentUser!.email)
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        String documentId = doc.id;
        userID = documentId;
        setStatus("Online");
      }
    });
  }
}

void setStatus(String status) async {
  if (AuthService.currentUser != null) {
    await FirebaseFirestore.instance.collection('users').doc(userID).update({
      "status": status,
    });
  }
}

void didChangeAppLifecycleState(AppLifecycleState state) {
  if (state == AppLifecycleState.resumed) {
    // online
    setStatus("Online");
  } else {
    setStatus("Offline");
  }
}
