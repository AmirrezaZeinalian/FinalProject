import 'package:flutter/material.dart';
import 'package:get/get.dart'; // Import Get for snackbar and GetUtils

class EditProfilePage extends StatefulWidget {
  final String initialUsername;
  final String initialEmail;

  const EditProfilePage({
    super.key,
    required this.initialUsername,
    required this.initialEmail,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _newUsernameController;
  late TextEditingController _newEmailController;
  late TextEditingController _newPasswordController; // NEW: For new password
  late TextEditingController _confirmNewPasswordController; // NEW: For confirming new password
  late TextEditingController _currentPasswordController; // Crucial for backend verification

  @override
  void initState() {
    super.initState();
    _newUsernameController = TextEditingController(text: widget.initialUsername);
    _newEmailController = TextEditingController(text: widget.initialEmail);
    _newPasswordController = TextEditingController(); // Initialize empty
    _confirmNewPasswordController = TextEditingController(); // Initialize empty
    _currentPasswordController = TextEditingController(); // Initialize empty for user input
  }

  @override
  void dispose() {
    _newUsernameController.dispose();
    _newEmailController.dispose();
    _newPasswordController.dispose(); // Dispose new controllers
    _confirmNewPasswordController.dispose(); // Dispose new controllers
    _currentPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.deepPurple, Colors.black87],
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView( // Use SingleChildScrollView to prevent overflow on smaller screens
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _newUsernameController,
                decoration: InputDecoration(
                  labelText: 'New Username',
                  labelStyle: const TextStyle(color: Colors.white70),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.deepPurpleAccent),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.white),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                ),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _newEmailController,
                decoration: InputDecoration(
                  labelText: 'New Email',
                  labelStyle: const TextStyle(color: Colors.white70),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.deepPurpleAccent),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.white),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                ),
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 15),

              // NEW PASSWORD FIELDS
              TextField(
                controller: _newPasswordController,
                decoration: InputDecoration(
                  labelText: 'New Password (optional)',
                  labelStyle: const TextStyle(color: Colors.white70),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.deepPurpleAccent),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.white),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                ),
                style: const TextStyle(color: Colors.white),
                obscureText: true, // Hide password
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _confirmNewPasswordController,
                decoration: InputDecoration(
                  labelText: 'Confirm New Password',
                  labelStyle: const TextStyle(color: Colors.white70),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.deepPurpleAccent),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.white),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                ),
                style: const TextStyle(color: Colors.white),
                obscureText: true, // Hide password
              ),
              const SizedBox(height: 15),
              // END NEW PASSWORD FIELDS

              TextField(
                controller: _currentPasswordController,
                decoration: InputDecoration(
                  labelText: 'Current Password (for verification)',
                  labelStyle: const TextStyle(color: Colors.white70),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.deepPurpleAccent),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.white),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                ),
                style: const TextStyle(color: Colors.white),
                obscureText: true, // Hide password
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  // Client-side validation before sending to backend
                  String newUsername = _newUsernameController.text.trim();
                  String newEmail = _newEmailController.text.trim();
                  String newPassword = _newPasswordController.text; // Get new password
                  String confirmNewPassword = _confirmNewPasswordController.text; // Get confirm password
                  String currentPassword = _currentPasswordController.text;

                  if (newUsername.isEmpty || newEmail.isEmpty || currentPassword.isEmpty) {
                    Get.snackbar("Error", "Username, Email, and Current Password cannot be empty.", snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
                    return;
                  }
                  if (!GetUtils.isEmail(newEmail)) {
                    Get.snackbar("Error", "Invalid email format.", snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
                    return;
                  }
                  if (currentPassword.length < 8) { // Basic password length check for current password
                    Get.snackbar("Error", "Current password must be at least 8 characters.", snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
                    return;
                  }

                  // Validation for new password fields (if provided)
                  if (newPassword.isNotEmpty || confirmNewPassword.isNotEmpty) {
                    if (newPassword.length < 8) {
                      Get.snackbar("Error", "New password must be at least 8 characters.", snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
                      return;
                    }
                    if (newPassword != confirmNewPassword) {
                      Get.snackbar("Error", "New password and confirmation do not match.", snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
                      return;
                    }
                  }


                  // If validation passes, pop with the data
                  // The Map includes all required data for the backend's `Edit` handler
                  Navigator.pop(context, {
                    'newUsername': newUsername,
                    'newEmail': newEmail,
                    'newPassword': newPassword, // Send new password (can be empty string if not changed)
                    'confirmNewPassword': confirmNewPassword, // Send confirm new password (can be empty)
                    'previousEmail': widget.initialEmail, // Send the original email to identify the user
                    'password': currentPassword, // This is 'currentPassword' as required by your backend
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurpleAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Save Changes',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}