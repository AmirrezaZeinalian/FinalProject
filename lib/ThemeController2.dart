import 'package:get/get.dart';
import 'package:flutter/material.dart';

class ThemeController extends GetxController {
  var isDarkMode = false.obs;

  // Getter to provide the current ThemeMode based on isDarkMode
  ThemeMode get theme => isDarkMode.value ? ThemeMode.dark : ThemeMode.light;

  // Toggles the theme state and applies the change globally
  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
    Get.changeThemeMode(theme);
  }

  // Sets the theme state directly, used when syncing with backend preference
  void setDarkTheme(bool value) { // Changed parameter name for clarity
    if (isDarkMode.value != value) { // Only update if there's a change
      isDarkMode.value = value;
      Get.changeThemeMode(theme); // Apply the new theme mode
    }
  }

  // You might want to initialize the theme when the controller is created
  // For example, by loading from local storage (not implemented here, but a common pattern)
  @override
  void onInit() {
    super.onInit();
    // This part is crucial for making Get.changeThemeMode work effectively globally
    // Ensure you have GetMaterialApp in your main.dart and set initial themeMode:
    // GetMaterialApp(
    //   themeMode: ThemeMode.system, // Or ThemeMode.light/ThemeMode.dark
    //   theme: ThemeData.light(),
    //   darkTheme: ThemeData.dark(),
    //   home: ...
    // );
    // And ensure ThemeController is put (e.g., Get.put(ThemeController());)
    // before any widgets that use it are built.
  }
}