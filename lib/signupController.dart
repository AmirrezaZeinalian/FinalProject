import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import 'ProfileComplementPage.dart'; // No longer needed directly for this flow
import 'ProfileComplementPage2.dart'; // Corrected import for the target page

class SignupController extends GetxController {
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final obscurePassword = true.obs;
  final obscureConfirmPassword = true.obs;
  final isLoading = false.obs; // This will now control loading for the *first* signup step

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  void toggleConfirmPasswordVisibility() {
    obscureConfirmPassword.value = !obscureConfirmPassword.value;
  }

  //validate username
  String? validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) return 'Username is required';
    if (value.length < 4) return 'Username must be at least 4 characters';
    // Note: Username availability check should ideally be done async with backend
    // For now, this is a client-side placeholder check.
    if (['user1', 'admin', 'test'].contains(value.toLowerCase())) return 'This username is already taken (example)';
    return null;
  }

  //validate email
  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) return 'Enter a valid email';
    return null;
  }

  //validate password
  String? validatePassword(String? value, String username) {
    if (value == null || value.trim().isEmpty) return 'Password is required';
    final hasUpper = value.contains(RegExp(r'[A-Z]'));
    final hasLower = value.contains(RegExp(r'[a-z]'));
    final hasDigit = value.contains(RegExp(r'\d'));
    final hasSpecial = value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    final notContainUsername = !value.toLowerCase().contains(username.toLowerCase());

    if (value.length < 8 || !hasUpper || !hasLower || !hasDigit || !hasSpecial || !notContainUsername) {
      return 'Password must:\n- Be 8+ characters\n- Contain upper & lower case letters\n- Include a number & special character\n- Not include the username';
    }

    return null;
  }

  String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.trim().isEmpty) return 'Confirm your password';
    if (value != password) return 'Passwords do not match';
    return null;
  }

  void register(GlobalKey<FormState> formKey) async {
    // Before navigating, validate the first set of fields
    if (formKey.currentState!.validate()) {
      // No need for a delay here, as the actual signup will happen on the next page
      // and that page will handle its own loading.

      Get.to(
            () => ProfileCompletionPage2(
          username: usernameController.text,
          email: emailController.text,
          password: passwordController.text,
        ),
        transition: Transition.rightToLeft, // Use a transition for a smoother UX
        duration: const Duration(milliseconds: 500),
      );
    }
  }

  @override
  void onClose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}