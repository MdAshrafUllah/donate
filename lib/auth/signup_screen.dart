import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _passwordVisible = true;
  bool isChecked = true;
  bool showSpinner = false;

  FirebaseAuth auth = FirebaseAuth.instance;
  User? user;

  Future userData(String name, String email) async {
    await FirebaseFirestore.instance.collection("users").add({
      'name': name,
      'email': email,
      'status': 'Unavailable',
      'uid': auth.currentUser?.uid,
      'profileImage': 'https://i.stack.imgur.com/YaL3s.jpg',
      'bio': '',
      'city': ''
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: ModalProgressHUD(
          inAsyncCall: showSpinner,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.only(top: size.height / 17),
                  child: Image.asset(
                    'assets/utsargo_App_Logo_green.png',
                    width: size.width / 3,
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: size.height / 45),
                  alignment: Alignment.topLeft,
                  padding: EdgeInsets.only(left: size.width / 20),
                  child: Text(
                    'Sign Up',
                    style: TextStyle(
                      fontSize: size.width / 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(
                      left: size.width / 25,
                      right: size.width / 25,
                      top: size.height / 40),
                  padding: EdgeInsets.only(
                      left: size.width / 25, right: size.width / 25),
                  height: size.height / 11,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.grey[200],
                    border: Border.all(width: 2, color: Colors.black54),
                    boxShadow: const [
                      BoxShadow(
                          offset: Offset(0, 10),
                          blurRadius: 50,
                          color: Color(0xFFEEEEEE))
                    ],
                  ),
                  alignment: Alignment.center,
                  child: TextField(
                    controller: _nameController,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: size.width / 19,
                      fontWeight: FontWeight.bold,
                    ),
                    keyboardType: TextInputType.emailAddress,
                    cursorColor: const Color(0xFF39b54a),
                    decoration: InputDecoration(
                      hintText: 'Full Name',
                      hintStyle: TextStyle(
                        color: Colors.black54,
                        fontSize: size.width / 19,
                        fontWeight: FontWeight.bold,
                      ),
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(
                      left: size.width / 25,
                      right: size.width / 25,
                      top: size.height / 40),
                  padding: EdgeInsets.only(
                      left: size.width / 25, right: size.width / 25),
                  height: size.height / 11,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.grey[200],
                    border: Border.all(width: 2, color: Colors.black54),
                    boxShadow: const [
                      BoxShadow(
                          offset: Offset(0, 10),
                          blurRadius: 50,
                          color: Color(0xFFEEEEEE))
                    ],
                  ),
                  alignment: Alignment.center,
                  child: TextField(
                    controller: _emailController,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: size.width / 19,
                      fontWeight: FontWeight.bold,
                    ),
                    keyboardType: TextInputType.emailAddress,
                    cursorColor: const Color(0xFF39b54a),
                    decoration: InputDecoration(
                      hintText: 'Email',
                      hintStyle: TextStyle(
                        color: Colors.black54,
                        fontSize: size.width / 19,
                        fontWeight: FontWeight.bold,
                      ),
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(
                      left: size.width / 25,
                      right: size.width / 25,
                      top: size.height / 40),
                  padding: EdgeInsets.only(
                      left: size.width / 25, right: size.width / 25),
                  height: size.height / 11,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.grey[200],
                    border: Border.all(width: 2, color: Colors.black54),
                    boxShadow: const [
                      BoxShadow(
                          offset: Offset(0, 10),
                          blurRadius: 50,
                          color: Color(0xFFEEEEEE))
                    ],
                  ),
                  alignment: Alignment.center,
                  child: TextField(
                    controller: _passwordController,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: size.width / 19,
                      fontWeight: FontWeight.bold,
                    ),
                    keyboardType: TextInputType.text,
                    cursorColor: const Color(0xFF39b54a),
                    obscureText: _passwordVisible,
                    decoration: InputDecoration(
                      hintText: 'Password',
                      hintStyle: TextStyle(
                        color: Colors.black54,
                        fontSize: size.width / 19,
                        fontWeight: FontWeight.bold,
                      ),
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _passwordVisible
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: const Color(0xFF39b54a),
                        ),
                        onPressed: () {
                          setState(() {
                            _passwordVisible = !_passwordVisible;
                          });
                        },
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(
                      left: size.width / 25, top: size.height / 50),
                  alignment: Alignment.topLeft,
                  child: Row(
                    children: [
                      Checkbox(
                          activeColor: const Color(0xFF39b54a),
                          value: isChecked,
                          onChanged: (bool? value) {
                            setState(() {
                              isChecked = value!;
                            });
                          }),
                      Container(
                        padding: EdgeInsets.only(
                            top: size.width / 50, bottom: size.height / 200),
                        width: size.width / 1.2,
                        child: RichText(
                          text: TextSpan(children: <TextSpan>[
                            TextSpan(
                              text: "By creating an account you agree to the ",
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: size.width / 24,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            TextSpan(
                                text: " terms of use",
                                style: TextStyle(
                                  color: const Color(0xFF39b54a),
                                  fontSize: size.width / 24,
                                  fontWeight: FontWeight.w500,
                                )),
                            TextSpan(
                                text: " and our",
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: size.width / 24,
                                  fontWeight: FontWeight.w500,
                                )),
                            TextSpan(
                                text: " privacy policy",
                                style: TextStyle(
                                  color: const Color(0xFF39b54a),
                                  fontSize: size.width / 24,
                                  fontWeight: FontWeight.w500,
                                )),
                          ]),
                        ),
                      ),
                    ],
                  ),
                ),
                InkWell(
                  child: Container(
                    height: size.height / 8.5,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFF39b54a),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          blurRadius: 7,
                          offset: const Offset(0, 7),
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Container(
                            height: size.height / 50,
                            width: double.infinity,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(20),
                                bottomRight: Radius.circular(20),
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: size.height / 35),
                            child: Text(
                              'Sign Up',
                              style: TextStyle(
                                fontSize: size.width / 19,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  onTap: () async {
                    if (isChecked == false) {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(const SnackBar(
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: Colors.redAccent,
                          content: Text(
                            'Agree With Our terms and conditions',
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Roboto',
                            ),
                          )));
                    } else if (_nameController.text != "" &&
                        _emailController.text != "" &&
                        _passwordController.text != "") {
                      setState(() {
                        showSpinner = true;
                      });
                      try {
                        UserCredential userCredential = await FirebaseAuth
                            .instance
                            .createUserWithEmailAndPassword(
                          email: _emailController.text,
                          password: _passwordController.text,
                        );
                        userData(
                          _nameController.text.trim(),
                          _emailController.text.trim(),
                        );
                        user = userCredential.user;
                        await user!.updateDisplayName(_nameController.text);
                        await user!.reload();
                        user = auth.currentUser;
          
                        if (user != null) {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (Context) =>
                                  const LoginScreen()));
                          ScaffoldMessenger.of(context)
                              .showSnackBar(SnackBar(
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: Colors.green,
                              content: Text(
                                '${user!.displayName} Welcome To Utsargo',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Roboto',
                                ),
                              )));
                        }
                        setState(() {
                          showSpinner = false;
                        });
                      } on FirebaseAuthException catch (e) {
                        if (e.code == 'weak-password') {
                          setState(() {
                            showSpinner = false;
                          });
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: Colors.redAccent,
                              content: Text(
                                'The password provided is too weak.',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Roboto',
                                ),
                              )));
                        } else if (e.code == 'email-already-in-use') {
                          setState(() {
                            showSpinner = false;
                          });
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: Colors.redAccent,
                              content: Text(
                                'The email already used by another user.',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Roboto',
                                ),
                              )));
                        }
                      }
                    } else {
                      setState(() {
                        showSpinner = false;
                      });
                      ScaffoldMessenger.of(context)
                          .showSnackBar(const SnackBar(
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: Colors.redAccent,
                          content: Text(
                            'All field required',
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Roboto',
                            ),
                          )));
                    }
                  },
                ),
                Container(
                  margin: EdgeInsets.only(top: size.height / 25),
                  child: RichText(
                    text: TextSpan(children: <TextSpan>[
                      TextSpan(
                        text: "Already have an account?",
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: size.width / 22,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      TextSpan(
                          text: " Login",
                          style: TextStyle(
                            color: const Color(0xFF39b54a),
                            fontSize: size.width / 22,
                            fontWeight: FontWeight.w500,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (Context) => const LoginScreen()));
                            }),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
