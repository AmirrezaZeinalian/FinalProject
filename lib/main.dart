import 'package:amiran/subscription_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'AuthController.dart';
import 'ThemeController2.dart';
import 'introAnimation.dart';
import 'introwalk.dart';


void main() {
  Get.put(AuthController());
  Get.put(ThemeController()); // Inject ThemeController once here
  Get.put(SubscriptionController());
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
      getPages: [
        GetPage(name: '/splash', page: () => const SplashScreen()),
        GetPage(name: '/home', page: () => OnboardingPage()),
      ],


    ));
  }
}



