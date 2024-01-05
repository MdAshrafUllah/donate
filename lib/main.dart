import 'package:device_preview/device_preview.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'posts/add_post_screen.dart';
import 'Navigation/navigation_screen.dart';
import 'auth/forget_password_screen.dart';
import 'auth/login_screen.dart';
import 'auth/signup_screen.dart';
import 'onboarding/onboarding_screen.dart';
import 'splash_screen.dart';
import 'user/food_deliver.dart';
import 'user/food_receiver.dart';
import 'user/posts_manager.dart';
import 'user/save.dart';
import 'user/setting_screen.dart';
import 'widget/initialize_current_user.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyA8n1FMUIx_fb4a0lR7TM42E1ISH1SykAM",
      appId: "1:113399147735:android:eedc5e5a02b43813c8d492",
      messagingSenderId: "113399147735",
      projectId: "utsargo-official",
      storageBucket: "utsargo-official.appspot.com",
    ),
  );
  await AuthService.initializeCurrentUser();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isFirstTime = prefs.getBool('isFirstTime') ?? true;
  runApp(DevicePreview(
      enabled: true,
      builder: (BuildContext context) => MyApp(isFirstTime: isFirstTime)));
}

class MyApp extends StatelessWidget {
  final bool isFirstTime;

  const MyApp({super.key, required this.isFirstTime});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        useInheritedMediaQuery: true,
        locale: DevicePreview.locale(context),
        builder: DevicePreview.appBuilder,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Color(0xFF39b54a),
              brightness: Brightness.light,
              background: Colors.white,
            ),
            appBarTheme: AppBarTheme(
              centerTitle: true,
              foregroundColor: Colors.white,
              backgroundColor: Color(0xFF39b54a),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF39b54a),
              foregroundColor: Colors.white,
            ))),
        title: 'Utsargo',
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/onBoardingScreen': (context) => OnboardingScreen(),
          '/loginScreen': (context) => const LoginScreen(),
          '/signupScreen': (context) => const SignupScreen(),
          '/navigationScreen': (context) => const NavigationScreen(),
          '/manageProfile': (context) => const SettingScreen(),
          '/forgetPasswordScreen': (context) => const ForgetPasswordScreen(),
          '/settingScreen': (context) => const SettingScreen(),
          '/saveItemsScreen': (context) => const SaveItemsScreen(),
          '/addPostScreen': (context) => const AddPostScreen(),
          '/foodReceiver': (context) => const FoodReceiver(),
          '/foodDeliver': (context) => const FoodDeliver(),
          '/postsManager': (context) => const PostsMabagerScreen(),
        });
  }
}
