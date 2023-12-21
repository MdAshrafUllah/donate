import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../navigation/navigation_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _passwordVisible = true;

  Future<void> signIn() async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
              email: _emailController.text, password: _passwordController.text);

      if (userCredential.user != null) {
        // Login successful
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => NavigationScreen()));
      }
    } catch (e) {
      print('Login error: $e');
      // Handle login errors
      // Show an error dialog or message to the user
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
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
                child: Text(
                  'Login',
                  style: TextStyle(
                    fontSize: size.width / 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                ),
                alignment: Alignment.topLeft,
                padding: EdgeInsets.only(left: size.width / 20),
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
                ),
                alignment: Alignment.center,
                child: TextField(
                  controller: _emailController,
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: size.width / 19,
                    fontWeight: FontWeight.bold,
                  ),
                  keyboardType: TextInputType.emailAddress,
                  cursorColor: Color(0xFF39b54a),
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
                  // onChanged: (value){
                  //   setState(() {
                  //     email = value;
                  //   });
                  // },
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
                    border: Border.all(width: 2, color: Colors.black54)),
                alignment: Alignment.center,
                child: TextField(
                  controller: _passwordController,
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: size.width / 19,
                    fontWeight: FontWeight.bold,
                  ),
                  keyboardType: TextInputType.text,
                  cursorColor: Color(0xFF39b54a),
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
                          color: Color(0xFF39b54a)),
                      onPressed: () {
                        setState(() {
                          _passwordVisible = !_passwordVisible;
                        });
                      },
                    ),
                  ),
                  // onChanged: (value){
                  //   setState(() {
                  //     password = value;
                  //   });
                  // }
                ),
              ),
              Container(
                padding: EdgeInsets.only(
                    left: size.width / 20, top: size.height / 40),
                alignment: Alignment.topLeft,
                child: Text(
                  'Forget your password?',
                  style: TextStyle(
                      color: Color(0xFF39b54a),
                      fontSize: size.width / 22,
                      fontWeight: FontWeight.w500),
                ),
              ),
              InkWell(
                child: Container(
                  height: size.height / 8.5,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Color(0xFF39b54a),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFF39b54a).withOpacity(0.3),
                        blurRadius: 7,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        height: size.height / 50,
                        width: double.infinity,
                        decoration: BoxDecoration(
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
                          'Login',
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
                onTap: () {
                  // signUser();
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (Context) => NavigationScreen()));
                },
              ),
              Container(
                margin: EdgeInsets.only(top: size.height / 25),
                child: RichText(
                  text: TextSpan(children: <TextSpan>[
                    TextSpan(
                      text: "Don't have an account?",
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: size.width / 22,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    TextSpan(
                      text: " Sign Up",
                      style: TextStyle(
                        color: Color(0xFF39b54a),
                        fontSize: size.width / 22,
                        fontWeight: FontWeight.w500,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (Context) => SignupScreen()));
                        },
                    ),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
