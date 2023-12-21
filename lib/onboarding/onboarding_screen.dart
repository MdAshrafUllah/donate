import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../auth/login_screen.dart';
import 'onboard_page_mathod.dart';

class OnboardingScreen extends StatefulWidget {
  OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final controller = PageController();
  bool isLastPage = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        body: Container(
          padding: EdgeInsets.only(top: size.height * 0.1),
          child: PageView(
            controller: controller,
            onPageChanged: (index) {
              setState(() => isLastPage = index == 2);
            },
            children: [
              buildPage(
                color: Colors.white,
                urlImage: 'assets/onboard1.png',
                title: 'Collect Food',
                subtitle:
                    'If you need food then you can find food for you or your family form here.',
              ),
              buildPage(
                color: Colors.white,
                urlImage: 'assets/onboard2.png',
                title: 'Save Food',
                subtitle:
                    'You can save the Food by using our application. By doing that, you help the world in reduce food waste',
              ),
              buildPage(
                color: Colors.white,
                urlImage: 'assets/onboard3.png',
                title: 'Donate Food',
                subtitle: 'You can halp other people by donating the food',
              ),
            ],
          ),
        ),
        bottomSheet: isLastPage
            ? Container(
                color: Colors.white,
                child: Padding(
                  padding: EdgeInsets.all(size.width * 0.05),
                  child: TextButton(
                      style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          backgroundColor: Color(0xFF39b54a),
                          minimumSize: Size.fromHeight(size.height * 0.08)),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => LoginScreen()),
                        );
                      },
                      child: Text(
                        'Get Started',
                        style: TextStyle(fontSize: size.width * 0.05),
                      )),
                ),
              )
            : Container(
                color: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
                height: size.height / 8,
                width: size.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                        onPressed: () => controller.jumpToPage(2),
                        child: Text('Skip',
                            style: TextStyle(
                                fontSize: size.width / 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF39b54a)))),
                    Center(
                      child: SmoothPageIndicator(
                        controller: controller,
                        count: 3,
                        effect: const WormEffect(
                          spacing: 16,
                          dotColor: Colors.grey,
                          activeDotColor: Color(0xFF39b54a),
                        ),
                        onDotClicked: (index) => controller.animateToPage(index,
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeIn),
                      ),
                    ),
                    TextButton(
                        onPressed: () => controller.nextPage(
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOut),
                        child: Text(
                          'Next',
                          style: TextStyle(
                              color: Color(0xFF39b54a),
                              fontSize: size.width / 24,
                              fontWeight: FontWeight.bold),
                        ))
                  ],
                ),
              ),
      ),
    );
  }
}
