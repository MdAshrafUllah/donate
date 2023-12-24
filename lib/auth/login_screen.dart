import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:utsargo/auth/forget_password_screen.dart';

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

  bool showSpinner = false;
  bool _passwordVisible = true;

  FirebaseAuth auth = FirebaseAuth.instance;
  User? user;
  SharedPreferences? _prefs;
  final String _cacheKey = 'loggedIn';

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  void checkLoginStatus() async {
    _prefs ??= await SharedPreferences.getInstance();
    final bool isLoggedIn = _prefs!.getBool(_cacheKey) ?? false;
    if (isLoggedIn) {
      try {
        User? currentUser = auth.currentUser;
        if (currentUser != null) {
          setState(() {
            showSpinner = true;
          });
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => const NavigationScreen()),
          );
        }
      } finally {
        setState(() {
          showSpinner = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return SafeArea(
      child: ModalProgressHUD(
        inAsyncCall: showSpinner,
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
                      color: Colors.black,
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
                      color: Colors.black,
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
                  child: TextButton(
                    onPressed: (){
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) =>
                            const ForgetPasswordScreen()),
                      );
                    },
                    child: Text(
                      'Forget your password?',
                      style: TextStyle(
                          color: Color(0xFF39b54a),
                          fontSize: size.width / 22,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
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
                  onTap: () async{
                    if (_emailController.text.length > 5 &&
                        _emailController.text.contains('@') &&
                        _emailController.text.endsWith('.com')) {
                      if (_emailController.text != "" &&
                          _passwordController.text != "") {
                        try {
                          setState(() {
                            showSpinner = true;
                          });
                          UserCredential userCredential =
                              await auth.signInWithEmailAndPassword(
                            email: _emailController.text,
                            password: _passwordController.text,
                          );
                          user = userCredential.user;
                          if (user != null) {
                            _prefs ??= await SharedPreferences.getInstance();
                            _prefs!.setBool(_cacheKey, true);

                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                  const NavigationScreen()),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    duration: const Duration(
                                        seconds: 1, milliseconds: 500),
                                    behavior: SnackBarBehavior.floating,
                                    backgroundColor: Colors.green,
                                    content: Text(
                                      '${user!.displayName} Welcome Back.',
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
                          if (e.code == 'user-not-found') {
                            setState(() {
                              showSpinner = false;
                            });
                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: Colors.redAccent,
                                content: Text(
                                  'User Not Found',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Roboto',
                                  ),
                                )));
                          } else if (e.code == 'wrong-password') {
                            setState(() {
                              showSpinner = false;
                            });
                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: Colors.redAccent,
                                content: Text(
                                  'Wrong Password',
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
                    } else if(_emailController.text == "" &&
                        _passwordController.text == ""){
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
                        ),
                      ));
                    }else{
                      ScaffoldMessenger.of(context)
                          .showSnackBar(const SnackBar(
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
      ),
    );
  }
}
