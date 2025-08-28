import 'package:amiran/userController.dart';
import 'package:get/get.dart';
import 'AuthController.dart';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'HOME.dart';

class LoginController extends GetxController {
  final email = ''.obs;
  final password = ''.obs;
  final errorMessage = ''.obs;
  final isLoading = false.obs;
  final passwordVisible = false.obs;

  static const String _serverIp = '10.183.186.120';
  static const int _serverPort = 12346;

  void togglePasswordVisibility() => passwordVisible.toggle();

  Future<void> login() async {
    try {
      isLoading(true);
      errorMessage('');

      if (email.value.isEmpty || password.value.isEmpty) {
        errorMessage('Please fill all fields');
        isLoading(false);
        return;
      }

      final Socket socket = await Socket.connect(_serverIp, _serverPort, timeout: const Duration(seconds: 5));
      print('Connected to Java Login Backend!');

      final Map<String, dynamic> loginData = {
        'email': email.value,
        'password': password.value,
      };
      final String jsonString = jsonEncode(loginData);

      socket.write(jsonString + '\n');
      await socket.flush();
      print('Sent Login JSON to backend: $jsonString');

      // --- CRITICAL CHANGE HERE ---
      // Read all data until the socket is closed by the server.
      // This ensures you get the complete response, even if it's chunked.
      List<int> responseBytes = [];
      await for (var data in socket) {
        responseBytes.addAll(data);
      }
      await socket.close(); // Ensure the socket is closed after reading all data

      final String responseString = utf8.decode(responseBytes).trim(); // Trim to remove any potential leading/trailing whitespace including newline
      print('Received response from backend: $responseString');

      final Map<String, dynamic> responseJson = jsonDecode(responseString);
      String status = responseJson['status'];
      String message = responseJson['message'];

      if (status == 'success') {
        Get.snackbar(
          'Login Successful',
          message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.1),
          colorText: Colors.green,
          duration: const Duration(seconds: 3),
        );

        final Map<String, dynamic> loggedInUser = responseJson['user'];
        Get.find<UserController>().setUser(loggedInUser);
        Get.find<AuthController>().setLoggedIn(true);
        Get.offAll(() => MusicHomePage());
      } else {
        errorMessage(message);
        Get.snackbar(
          'Login Failed',
          message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.red,
          duration: const Duration(seconds: 5),
        );
      }
    } on SocketException catch (e) {
      print('Socket Error during login: $e');
      errorMessage('Could not connect to the server. Please check network and server status. (${e.message})');
      Get.snackbar(
        'Network Error',
        'Could not connect to the login server. Please ensure the server is running and accessible. (${e.message})',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
        duration: const Duration(seconds: 7),
        isDismissible: true,
      );
    } on FormatException catch (e) {
      print('JSON Decoding Error during login: $e');
      errorMessage('Received invalid data from server. Please try again.');
      Get.snackbar(
        'Data Error',
        'Received unexpected response from server. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.withOpacity(0.1),
        colorText: Colors.orange,
        duration: const Duration(seconds: 5),
      );
    } catch (e) {
      print('An unexpected error occurred during login: $e');
      errorMessage('An unexpected error occurred. Please try again.');
      Get.snackbar(
        'Error',
        'An unexpected error occurred during login. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
        duration: const Duration(seconds: 5),
      );
    } finally {
      isLoading(false);
    }
  }
}