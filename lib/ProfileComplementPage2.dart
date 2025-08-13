import 'package:amiran/userController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io'; // Required for Socket communication
import 'dart:convert'; // Required for JSON encoding/decoding
import 'AuthController.dart';
import 'HOME.dart';

class ProfileCompletionPage2 extends StatefulWidget {
  final String username;
  final String email;
  final String password;

  const ProfileCompletionPage2({
    Key? key,
    required this.username,
    required this.email,
    required this.password,
  }) : super(key: key);

  @override
  State<ProfileCompletionPage2> createState() => _ProfileCompletionPage2State();
}

class _ProfileCompletionPage2State extends State<ProfileCompletionPage2> {
  final _formKey = GlobalKey<FormState>();
  final dayController = TextEditingController();
  final monthController = TextEditingController();
  final yearController = TextEditingController();
  final cityController = TextEditingController();

  final RxBool _isLoading = false.obs; // Local loading indicator for this page

  // Define your backend server IP and port
  static const String _serverIp = '192.168.100.3'; // Your backend server IP
  static const int _serverPort = 12345; // Your backend server port

  InputDecoration inputDecoration(String label, IconData icon, {String? hintText}) {
    return InputDecoration(
      labelText: label,
      hintText: hintText,
      prefixIcon: Icon(icon, color: Colors.deepPurple),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      labelStyle: const TextStyle(color: Colors.deepPurple),
      hintStyle: const TextStyle(color: Colors.grey),
    );
  }

  void submitProfile() async {
    if (_formKey.currentState!.validate()) {
      _isLoading.value = true; // Start loading

      try {
        // 1. Establish Socket Connection
        final Socket socket = await Socket.connect(_serverIp, _serverPort, timeout: const Duration(seconds: 5));
        print('Connected to Java backend!');

        // 2. Prepare the complete JSON data
        final Map<String, dynamic> userData = {
          'username': widget.username, // From previous page
          'email': widget.email,       // From previous page
          'password': widget.password, // From previous page
          'birthDay': int.parse(dayController.text),
          'birthMonth': int.parse(monthController.text),
          'birthYear': int.parse(yearController.text),
          'city': cityController.text,
        };
        final String jsonString = jsonEncode(userData);

        // 3. Send the JSON string to the backend
        socket.write(jsonString + '\n'); // Add newline as backend reads line by line
        await socket.flush(); // Ensure data is sent immediately
        print('Sent JSON to backend: $jsonString');

        // 4. Listen for the server's response
        String responseString = '';
        await for (var data in socket) {
          responseString += utf8.decode(data);
          if (responseString.contains('\n')) { // Assuming backend sends a newline
            responseString = responseString.trim(); // Remove trailing newline
            break;
          }
        }
        print('Received response from backend: $responseString');

        // Close the socket
        await socket.close();

        // 5. Parse the JSON response
        final Map<String, dynamic> responseJson = jsonDecode(responseString);
        String status = responseJson['status'];
        String message = responseJson['message'];

        if (status == 'success') {
          Get.snackbar(
            'Success',
            message,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.withOpacity(0.1),
            colorText: Colors.green,
            duration: const Duration(seconds: 3),
          );

          // Get the user data from the response and set it in UserController
          final Map<String, dynamic> newUser = responseJson['user'];
          Get.find<UserController>().setUser(newUser);
          Get.find<AuthController>().setLoggedIn(true);

          // Navigate to success page or directly to home
          Get.offAll(
                () => MusicHomePage(), // Assuming MusicHomePage is your main app home
            transition: Transition.fadeIn,
            duration: const Duration(milliseconds: 500),
          );
        } else {
          Get.snackbar(
            'Signup Failed',
            message,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.withOpacity(0.1),
            colorText: Colors.red,
            duration: const Duration(seconds: 5),
          );
        }

      } on SocketException catch (e) {
        print('Socket Error: $e');
        Get.snackbar(
          'Network Error',
          'Could not connect to the server. Please check your internet connection and ensure the server is running. (${e.message})',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.red,
          duration: const Duration(seconds: 7),
          isDismissible: true,
        );
      } on FormatException catch (e) {
        print('JSON Decoding Error: $e');
        Get.snackbar(
          'Data Error',
          'Received invalid data from server. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange.withOpacity(0.1),
          colorText: Colors.orange,
          duration: const Duration(seconds: 5),
        );
      } catch (e) {
        print('An unexpected error occurred: $e');
        Get.snackbar(
          'Error',
          'An unexpected error occurred during signup. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.red,
          duration: const Duration(seconds: 5),
        );
      } finally {
        _isLoading.value = false; // Stop loading
      }
    }
  }

  @override
  void dispose() {
    dayController.dispose();
    monthController.dispose();
    yearController.dispose();
    cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Complete Your Profile'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.deepPurple,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
      ),
      body: Obx(() { // Use Obx to react to _isLoading changes
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      const Text(
                        'Almost there!',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Complete your profile to get started',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.deepPurple,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // Birthdate section
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.cake, color: Colors.deepPurple),
                            SizedBox(width: 8),
                            Text(
                              'Birthdate(day,month,year)',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: dayController,
                                decoration: inputDecoration('Day', Icons.calendar_today, hintText: 'DD'),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  final day = int.tryParse(value ?? '');
                                  if (day == null || day < 1 || day > 31) {
                                    return 'Invalid day';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: monthController,
                                decoration: inputDecoration('Month', Icons.calendar_today, hintText: 'MM'),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  final month = int.tryParse(value ?? '');
                                  if (month == null || month < 1 || month > 12) {
                                    return 'Invalid month';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: yearController,
                                decoration: inputDecoration('Year', Icons.calendar_today, hintText: 'YYYY'),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  final year = int.tryParse(value ?? '');
                                  if (year == null || year < 1900 || year > DateTime.now().year) {
                                    return 'Invalid year';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // City field
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.location_city, color: Colors.deepPurple),
                            SizedBox(width: 8),
                            Text(
                              'Your City',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: cityController,
                          decoration: inputDecoration('Enter your city', Icons.location_on, hintText: 'e.g. New York'),
                          validator: (value) =>
                          (value == null || value.isEmpty) ? 'Please enter your city' : null,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Submit button with gradient and loading indicator
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: const LinearGradient(
                      colors: [Colors.deepPurple, Colors.purpleAccent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.deepPurple.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _isLoading.value ? null : submitProfile, // Disable when loading
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Center(
                      child: _isLoading.value
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                        'COMPLETE PROFILE',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      ),
    );
  }
}

// Keep your SuccessPage as is, or modify it to receive all user details if needed.
class SuccessPage extends StatelessWidget {
  final String birthDate;
  final String city;

  const SuccessPage({Key? key, required this.birthDate, required this.city}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 100,
            ),
            const SizedBox(height: 24),
            const Text(
              'Profile Completed!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Birthdate: $birthDate',
              style: const TextStyle(
                fontSize: 18,
                color: Colors.deepPurple,
              ),
            ),
            Text(
              'City: $city',
              style: const TextStyle(
                fontSize: 18,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Get.offAll(
                      () => MusicHomePage(),
                  transition: Transition.fadeIn,
                  duration: const Duration(milliseconds: 500),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                backgroundColor: Colors.deepPurple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'VIEW PROFILE',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}