// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:utsargo/auth/login_screen.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool showSpinner = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future passwordReset() async {
    if (_emailController.text.length > 5 &&
        _emailController.text.contains('@') &&
        _emailController.text.endsWith('.com')) {
      try {
        setState(() {
          showSpinner = true;
        });

        await FirebaseAuth.instance
            .sendPasswordResetEmail(email: _emailController.text.trim());
        setState(() {
          showSpinner = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.green,
          content: Text(
            'Password reset link sent successfully!',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Roboto',
            ),
          ),
        ));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => const LoginScreen(),
          ),
        );
      } catch (e) {
        setState(() {
          showSpinner = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.redAccent,
          content: Text(
            'User Not Found',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Roboto',
            ),
          ),
        ));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.redAccent,
        content: Text(
          'Enter a Valid Email',
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
    return ModalProgressHUD(
      inAsyncCall: showSpinner,
      child: Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              height: 15,
            ),
            Center(
              child: Container(
                margin: EdgeInsets.only(top: size.height / 17),
                child: Image.asset(
                  'assets/utsargo_App_Logo_green.png',
                  width: size.width / 3,
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            const Center(
              child: Text(
                "Reset Password",
                style: TextStyle(
                  fontFamily: 'Roboto',
                  color: Color.fromRGBO(162, 158, 158, 1),
                  fontSize: 25,
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 60),
              alignment: Alignment.topLeft,
              padding: const EdgeInsets.only(left: 30),
              child: const Text(
                'Enter Your Email Address',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  color: Color.fromRGBO(162, 158, 158, 1),
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(
              height: 25,
            ),
            Container(
              margin: const EdgeInsets.only(left: 20, right: 20),
              padding: const EdgeInsets.only(left: 20, right: 20),
              height: 70,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  width: 2,
                  color: const Color.fromRGBO(162, 158, 158, 1),
                ),
              ),
              alignment: Alignment.center,
              child: TextField(
                controller: _emailController,
                style: TextStyle(
                  fontFamily: 'Roboto',
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                keyboardType: TextInputType.emailAddress,
                cursorColor: const Color.fromRGBO(58, 150, 255, 1),
                decoration: const InputDecoration(
                  hintText: 'Email',
                  hintStyle: TextStyle(
                    fontFamily: 'Roboto',
                    color: Color.fromRGBO(162, 158, 158, 1),
                    fontSize: 18,
                  ),
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(
              height: 25,
            ),
            InkWell(
              child: Container(
                height: size.height / 8.5,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF39b54a),
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
                        'Reset',
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
              onTap: () async{
              },
            ),
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    color: Colors.redAccent,
                    fontSize: 18,
                  ),
                ))
          ],
        ),
      ),
    );
  }
}