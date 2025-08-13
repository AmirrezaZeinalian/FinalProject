import 'package:amiran/HOME.dart';
import 'package:amiran/login.dart';
import 'package:amiran/signup.dart';
import 'package:amiran/subscription_controller.dart';
import 'package:amiran/userController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'AuthController.dart';
import 'Profile_tab.dart';
import 'ThemeController2.dart';
import 'contact.dart';
import 'introAnimation.dart';
import 'introwalk.dart';
import 'package:amiran/WalletController2.dart';

void main() {
  Get.put(AuthController());
  Get.put(ThemeController()); // Inject ThemeController once here
  Get.put(UserController());
  Get.put(SubscriptionController());
  Get.put(WalletController2());
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  final ThemeController themeController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Obx(() => GetMaterialApp(
      title: 'Registration App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      themeMode: themeController.theme, // reactive theme mode
      initialRoute: '/splash',
      // getPages: [
      //   GetPage(name: '/splash', page: () => const SplashScreen()),
      //   GetPage(name: '/home', page: () => OnboardingPage()),
      // ],
      home: MusicHomePage(),
    ));
  }
}
