import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  static User? currentUser;

  static Future<void> initializeCurrentUser() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;

    if (user != null) {
      currentUser = user;
    }
  }
}
