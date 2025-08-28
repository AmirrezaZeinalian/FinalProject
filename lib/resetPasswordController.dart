import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'dart:convert';

class ResetPasswordController extends GetxController {
  final cityController = TextEditingController();
  final dayController = TextEditingController();
  final monthController = TextEditingController();
  final yearController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmNewPasswordController = TextEditingController();

  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final isVerified = false.obs; // To control UI visibility: show new password fields
  final obscureNewPassword = true.obs;
  final obscureConfirmNewPassword = true.obs;

  // Backend server details
  static const String _serverIp = '10.183.186.35';
  static const int _serverPort = 12347; // The new port for reset password

  void toggleNewPasswordVisibility() {
    obscureNewPassword.value = !obscureNewPassword.value;
  }

  void toggleConfirmNewPasswordVisibility() {
    obscureConfirmNewPassword.value = !obscureConfirmNewPassword.value;
  }

  String? validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) return 'Password is required';
    final hasUpper = value.contains(RegExp(r'[A-Z]'));
    final hasLower = value.contains(RegExp(r'[a-z]'));
    final hasDigit = value.contains(RegExp(r'\d'));
    final hasSpecial = value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

    if (value.length < 8 || !hasUpper || !hasLower || !hasDigit || !hasSpecial) {
      return 'Password must:\n- Be 8+ characters\n- Contain upper & lower case letters\n- Include a number & special character';
    }
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.trim().isEmpty) return 'Confirm your password';
    if (value != newPasswordController.text) return 'Passwords do not match';
    return null;
  }


  Future<void> verifyDetails() async {
    errorMessage.value = '';
    isLoading.value = true;

    if (cityController.text.isEmpty ||
        dayController.text.isEmpty ||
        monthController.text.isEmpty ||
        yearController.text.isEmpty) {
      errorMessage.value = 'Please fill all details fields.';
      isLoading.value = false;
      return;
    }

    try {
      final Socket socket = await Socket.connect(_serverIp, _serverPort, timeout: Duration(seconds: 5));
      print('Connected to Reset Password Backend for verification!');

      final Map<String, dynamic> verifyData = {
        'type': 'verify',
        'city': cityController.text,
        'birthDay': int.parse(dayController.text),
        'birthMonth': int.parse(monthController.text),
        'birthYear': int.parse(yearController.text),
      };
      final String jsonString = jsonEncode(verifyData);

      socket.write(jsonString + '\n');
      await socket.flush();
      print('Sent verification JSON: $jsonString');

      String responseString = '';
      await for (var data in socket) {
        responseString += utf8.decode(data);
        if (responseString.contains('\n')) {
          responseString = responseString.trim();
          break;
        }
      }
      await socket.close();
      print('Received verification response: $responseString');

      final Map<String, dynamic> responseJson = jsonDecode(responseString);
      String status = responseJson['status'];
      String message = responseJson['message'];

      if (status == 'ok') { // Backend sends "ok" for successful verification
        isVerified.value = true; // Show password fields
        Get.snackbar(
          'Verification Successful',
          message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.1),
          colorText: Colors.green,
        );
      } else {
        errorMessage.value = message;
        Get.snackbar(
          'Verification Failed',
          message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.red,
        );
      }
    } on SocketException catch (e) {
      print('Socket Error during verification: $e');
      errorMessage.value = 'Network error: Could not connect to server.';
      Get.snackbar(
        'Network Error',
        'Could not connect to the reset password server. Please ensure the server is running. (${e.message})',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
        duration: const Duration(seconds: 7),
      );
    } on FormatException catch (e) {
      print('JSON Decoding Error: $e');
      errorMessage.value = 'Received invalid data from server.';
      Get.snackbar(
        'Data Error',
        'Received unexpected response during verification. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.withOpacity(0.1),
        colorText: Colors.orange,
      );
    } catch (e) {
      print('An unexpected error occurred during verification: $e');
      errorMessage.value = 'An unexpected error occurred. Please try again.';
      Get.snackbar(
        'Error',
        'An unexpected error occurred. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    } finally {
      isLoading.value = false;
    }
  }


  Future<void> resetPassword() async {
    errorMessage.value = '';
    isLoading.value = true;

    if (validatePassword(newPasswordController.text) != null ||
        validateConfirmPassword(confirmNewPasswordController.text) != null) {
      errorMessage.value = 'Please fix password errors.';
      isLoading.value = false;
      return;
    }

    try {
      final Socket socket = await Socket.connect(_serverIp, _serverPort, timeout: Duration(seconds: 5));
      print('Connected to Reset Password Backend for update!');

      final Map<String, dynamic> updateData = {
        'type': 'update',
        'city': cityController.text,
        'birthDay': int.parse(dayController.text),
        'birthMonth': int.parse(monthController.text),
        'birthYear': int.parse(yearController.text),
        'newPassword': newPasswordController.text, // New password
      };
      final String jsonString = jsonEncode(updateData);

      socket.write(jsonString + '\n');
      await socket.flush();
      print('Sent update JSON: $jsonString');

      String responseString = '';
      await for (var data in socket) {
        responseString += utf8.decode(data);
        if (responseString.contains('\n')) {
          responseString = responseString.trim();
          break;
        }
      }
      await socket.close();
      print('Received update response: $responseString');

      final Map<String, dynamic> responseJson = jsonDecode(responseString);
      String status = responseJson['status'];
      String message = responseJson['message'];

      if (status == 'success') {
        Get.snackbar(
          'Password Reset Successful',
          message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.1),
          colorText: Colors.green,
        );
        // Navigate back to login page
        Get.offAllNamed('/login'); // Assuming you have a named route for login
      } else {
        errorMessage.value = message;
        Get.snackbar(
          'Password Reset Failed',
          message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.red,
        );
      }
    } on SocketException catch (e) {
      print('Socket Error during update: $e');
      errorMessage.value = 'Network error: Could not connect to server.';
      Get.snackbar(
        'Network Error',
        'Could not connect to the reset password server. Please ensure the server is running. (${e.message})',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
        duration: const Duration(seconds: 7),
      );
    } on FormatException catch (e) {
      print('JSON Decoding Error: $e');
      errorMessage.value = 'Received invalid data from server.';
      Get.snackbar(
        'Data Error',
        'Received unexpected response during password update. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.withOpacity(0.1),
        colorText: Colors.orange,
      );
    } catch (e) {
      Get.to('/login');
      print('An unexpected error occurred during update: $e');
      errorMessage.value = 'An unexpected error occurred. Please try again.';
      Get.snackbar(
        'Error',
        'An unexpected error occurred. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    cityController.dispose();
    dayController.dispose();
    monthController.dispose();
    yearController.dispose();
    newPasswordController.dispose();
    confirmNewPasswordController.dispose();
    super.onClose();
  }
}