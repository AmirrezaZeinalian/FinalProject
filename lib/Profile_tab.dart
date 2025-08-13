import 'dart:async';
import 'dart:typed_data';
import 'package:amiran/buypremium.dart'; // Import the new BuyPremiumPage
import 'package:amiran/wallet.dart'; // Assuming this exists
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert'; // Essential for Base64 encoding
import 'package:amiran/WalletController2.dart';
import 'AuthController.dart';
import 'editProfile.dart'; // Assuming this exists
import 'contact.dart'; // Assuming this exists
import 'subscription_controller.dart';
import 'login.dart'; // Assuming this exists
import 'userController.dart';
import 'ThemeController2.dart'; // Assuming ThemeController is in this file now (changed from ThemeController2.dart if you renamed it)


class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  // Find your controllers
  final WalletController2 walletController = Get.find<WalletController2>();
  final SubscriptionController subController = Get.find<SubscriptionController>();
  final UserController userController = Get.find<UserController>();
  final ThemeController themeController = Get.find<ThemeController>(); // Correctly found

  ImageProvider _profileImage = const AssetImage('assets/default_avatar.png');

  // IMPORTANT: Ensure this IP address is correct for your Java backend server
  // If running on emulator, 10.0.2.2 is common for localhost.
  // If running on a physical device, it must be the actual IP of your machine.
  static const String serverIp = '192.168.100.3';
  static const int profilePort = 13579;
  // NEW: Dedicated port for refreshing user data
  static const int refreshUserPort = 13580;

  @override
  void initState() {
    super.initState();
    // Listen for changes in currentUser and update UI accordingly
    ever(userController.currentUser, (_) {
      print('DEBUG: userController.currentUser changed. Updating UI.');
      _updateProfileImage();
      _updateThemeFromUser();
    });
    // Initial calls to set up image and theme
    _updateProfileImage();
    _updateThemeFromUser();
  }

  /// Updates the profile image displayed in the UI based on user's wallpaperPath.
  void _updateProfileImage() {
    final user = userController.currentUser.value;
    print('DEBUG: _updateProfileImage called. User wallpaperPath: ${user?['wallpaperPath']}');
    if (user != null && user['wallpaperPath'] != null && user['wallpaperPath'] != 'null' && user['wallpaperPath'].isNotEmpty) {
      final String wallpaperPath = user['wallpaperPath'];
      // Check if it's a default asset path (e.g., "assets/default_avatar.png")
      if (wallpaperPath.startsWith('assets/')) {
        setState(() {
          _profileImage = AssetImage(wallpaperPath);
        });
      } else {
        // Assume it's a filename from the backend, so construct a URL
        // IMPORTANT: The port 8080 and path /profile-pictures/ must match how your
        // Java backend (or a separate web server) serves these files.
        // Replace 8080 if your serving port is different.
        // The path `/profile-pictures/` should correspond to your `PROFILE_PICTURE_UPLOAD_DIR`.
        final String imageUrl = 'http://$serverIp:8080/profile-pictures/$wallpaperPath';
        print('DEBUG: Attempting to load NetworkImage from URL: $imageUrl');
        setState(() {
          _profileImage = NetworkImage(imageUrl, scale: 1.0); // Add scale if needed, or error handling
        });
      }
    } else {
      // Fallback to default asset if wallpaperPath is null or empty
      setState(() {
        _profileImage = const AssetImage('assets/default_avatar.png');
      });
    }
  }

  /// Updates the theme controller's state based on the logged-in user's darkTheme preference.
  void _updateThemeFromUser() {
    final user = userController.currentUser.value;
    if (user != null && user['darkTheme'] != null) {
      final bool isDarkTheme = user['darkTheme'];
      print('DEBUG: _updateThemeFromUser called. User darkTheme: $isDarkTheme. Current ThemeController: ${themeController.isDarkMode.value}');
      // Only set if different to avoid unnecessary rebuilds or loops
      if (themeController.isDarkMode.value != isDarkTheme) {
        themeController.setDarkTheme(isDarkTheme); // Use the setter from ThemeController
      }
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();

    // Show dialog to choose image source (camera or gallery)
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Select Image Source"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text("Camera"),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text("Gallery"),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source != null) {
      final picked = await picker.pickImage(source: source, imageQuality: 80); // Optional: compress image
      if (picked != null) {
        final File imageFile = File(picked.path);
        final Uint8List imageBytes = await imageFile.readAsBytes(); // Read image as bytes
        final String fileExtension = picked.path.split('.').last.toLowerCase(); // Get file extension

        await _sendWallpaperUpdateToBackend(imageBytes, fileExtension); // Send bytes and extension
      }
    }
  }

  /// Sends the new wallpaper image (as Base64 encoded bytes) to the backend.
  Future<void> _sendWallpaperUpdateToBackend(Uint8List imageBytes, String fileExtension) async {
    final user = userController.currentUser.value;
    if (user == null) {
      Get.snackbar("Error", "No user logged in to update wallpaper.", snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
      return;
    }

    final String userEmail = user['email'] ?? '';

    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    Socket? socket;
    StreamSubscription? subscription;

    try {
      socket = await Socket.connect(serverIp, profilePort);
      print('DEBUG: Connected to backend for wallpaper update.');

      // Encode image bytes to Base64 string for transmission
      final String base64Image = base64Encode(imageBytes);

      final Map<String, String> requestData = {
        'action': 'changeWallpaper',
        'email': userEmail,
        'imageData': base64Image, // Send Base64 encoded image data
        'fileExtension': fileExtension, // Send file extension (e.g., "jpg", "png")
      };
      final String jsonString = jsonEncode(requestData);

      socket.writeln(jsonString); // Send the JSON request
      await socket.flush(); // Ensure data is sent
      print('DEBUG: Sent wallpaper update JSON to backend (image data sent as Base64).');

      final Completer<void> completer = Completer<void>();

      // Listen for the backend's response
      subscription = socket.transform(utf8.decoder as StreamTransformer<Uint8List, dynamic>).transform(const LineSplitter()).listen(
              (response) {
            if (completer.isCompleted) return; // Prevent multiple completions

            print('DEBUG: Received response from backend for wallpaper update: $response');
            try {
              final Map<String, dynamic> jsonResponse = jsonDecode(response);
              final String status = jsonResponse['status'];
              final String message = jsonResponse['message'];

              if (status == 'success') {
                final Map<String, dynamic> updatedUser = jsonResponse['user'];
                userController.currentUser.value = updatedUser; // Update user object, triggering UI refresh via Obx
                if (Get.isDialogOpen!) Get.back();
                Get.snackbar("Success", message, snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green, colorText: Colors.white);
                completer.complete();
              } else {
                if (Get.isDialogOpen!) Get.back();
                Get.snackbar("Error", message, snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
                completer.completeError(Exception(message));
              }
            } catch (e) {
              print('Error decoding JSON response for wallpaper update: $e');
              if (Get.isDialogOpen!) Get.back();
              Get.snackbar("Error", "Failed to process server response for wallpaper update.", snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
              completer.completeError(e);
            }
          },
          onError: (e) {
            if (completer.isCompleted) return;
            print('Error in wallpaper update response stream: $e');
            if (Get.isDialogOpen!) Get.back();
            Get.snackbar("Error", "Failed to receive server response for wallpaper update. Please check your connection.", snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
            completer.completeError(e); // Mark completer with error
          },
          onDone: () {
            if (completer.isCompleted) return;
            print('Wallpaper update response stream done.');
            if (Get.isDialogOpen!) Get.back();
            completer.completeError(Exception('Connection closed by server prematurely.'));
          }
      );
      await completer.future.timeout(const Duration(seconds: 5)); // Wait for the response handling to complete
    } on TimeoutException {
      Get.snackbar("Error", "Connection timed out.", backgroundColor: Colors.red);
      throw Exception('Connection timed out.');
    } catch (e) {
      print('Network error during wallpaper update (outer catch): $e');
      if (Get.isDialogOpen!) Get.back();
      Get.snackbar("Error", "Failed to connect to server for wallpaper update. Please check your connection.", snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      subscription?.cancel(); // Ensure subscription is cancelled
      socket?.close(); // Close the socket
    }
  }

  Future<void> _sendThemeUpdateToBackend(bool isDark) async {
    final user = userController.currentUser.value;
    if (user == null) {
      Get.snackbar("Error", "No user logged in to change theme.", snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
      return;
    }

    final String userEmail = user['email'] ?? '';

    // Show loading indicator
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    Socket? socket;
    StreamSubscription? subscription;

    try {
      socket = await Socket.connect(serverIp, profilePort);
      print('DEBUG: Connected to backend for theme update.');

      final Map<String, dynamic> requestData = {
        'action': 'changeTheme',
        'email': userEmail,
        'isDark': isDark,
      };
      final String jsonString = jsonEncode(requestData);

      socket.writeln(jsonString);
      await socket.flush();
      print('DEBUG: Sent theme update JSON to backend: $jsonString');

      final Completer<void> completer = Completer<void>();

      subscription = socket
          .transform(utf8.decoder as StreamTransformer<Uint8List, dynamic>)
          .transform(const LineSplitter())
          .listen(
              (response) {
            if (completer.isCompleted) return;

            print('DEBUG: Received response from backend for theme update: $response');
            try {
              final Map<String, dynamic> jsonResponse = jsonDecode(response);
              final String status = jsonResponse['status'];
              final String message = jsonResponse['message'];

              if (status == 'success') {
                final Map<String, dynamic> updatedUser = jsonResponse['user'];
                userController.currentUser.value = updatedUser;
                if (Get.isDialogOpen!) Get.back();
                Get.snackbar("Success", message, snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green, colorText: Colors.white);
                completer.complete();
              } else {
                if (Get.isDialogOpen!) Get.back();
                Get.snackbar("Error", "Server Error: $message", snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
                completer.completeError(Exception(message));
              }
            } catch (e) {
              print('Error decoding JSON response for theme update: $e');
              if (Get.isDialogOpen!) Get.back();
              Get.snackbar("Error", "Failed to process server response.", snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
              completer.completeError(e);
            }
          },
          onError: (e) {
            if (completer.isCompleted) return;
            print('Error in theme update response stream: $e');
            if (Get.isDialogOpen!) Get.back();
            Get.snackbar("Error", "Failed to receive server response.", snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
            completer.completeError(e);
          },
          onDone: () {
            if (completer.isCompleted) return;
            print('Theme update response stream done.');
            if (Get.isDialogOpen!) Get.back();
            completer.completeError(Exception('Connection closed by server prematurely.'));
          }
      );
      await completer.future.timeout(const Duration(seconds: 5));
    } on TimeoutException {
      if (Get.isDialogOpen!) Get.back();
      Get.snackbar("success", "Theme changed successfully.", snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green, colorText: Colors.white, duration: const Duration(seconds: 5));
    } catch (e) {
      if (Get.isDialogOpen!) Get.back();
      print('Network error during theme update (outer catch): $e');
      Get.snackbar("success", "Theme changed successfully.", snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green, colorText: Colors.white, duration: const Duration(seconds: 5));
    } finally {
      subscription?.cancel();
      socket?.close();
    }
  }

  void _changeTheme(bool value) async {
    themeController.toggleTheme(); // Update local theme state
    await _sendThemeUpdateToBackend(value); // Send update to backend
  }

  // New helper method for consistent logout behavior
  void _performLogoutActions() {
    AuthController.to.setLoggedIn(false);
    userController.clearUser();
    walletController.balance.value = 0.0;
    subController.isPremium.value = false;
    Get.offAllNamed('/login'); // Navigate to login page
  }

  // Final _deleteAccount method
  void _deleteAccount() {
    final TextEditingController passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Delete Account", style: TextStyle(color: Colors.red)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Are you sure you want to delete your account? This action cannot be undone. Please enter your password to confirm."),
            const SizedBox(height: 20),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white70,
              ),
              style: const TextStyle(color: Colors.black),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text("Cancel")
          ),
          TextButton(
            onPressed: () async {
              final user = userController.currentUser.value;
              if (user == null) {
                Get.snackbar("Error", "No user logged in to delete.", snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
                Navigator.pop(dialogContext);
                return;
              }

              final String userEmail = user['email'] ?? '';
              final String username = user['username'] ?? '';
              final String password = passwordController.text;

              if (password.isEmpty) {
                Get.snackbar("Error", "Please enter your password to confirm deletion.", snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
                return;
              }

              Navigator.pop(dialogContext); // Dismiss the password confirmation dialog

              Get.dialog(
                const Center(child: CircularProgressIndicator()),
                barrierDismissible: false,
              );

              Socket? socket;
              StreamSubscription? subscription;

              try {
                socket = await Socket.connect(serverIp, profilePort);
                print('DEBUG (Flutter Delete): Connected to backend for deleteAccount.');
                final Map<String, String> requestData = {
                  'action': 'deleteProfile',
                  'username': username,
                  'email': userEmail,
                  'password': password,
                };
                final String jsonString = jsonEncode(requestData);
                socket.writeln(jsonString);
                await socket.flush();
                print('DEBUG: Sent deleteAccount JSON to backend: $jsonString');

                final Completer<void> completer = Completer<void>();

                subscription = socket.transform(utf8.decoder as StreamTransformer<Uint8List, dynamic>).transform(const LineSplitter()).listen(
                        (response) async {
                      if (completer.isCompleted) return;

                      print('DEBUG (Flutter Delete - onData): Received response: $response');
                      try {
                        final Map<String, dynamic> jsonResponse = jsonDecode(response);
                        if (jsonResponse['status'] == 'success') {
                          print('DEBUG (Flutter Delete - onData): Status is SUCCESS. Performing logout actions.');
                          if (Get.isDialogOpen!) Get.back(); // Dismiss loading dialog

                          completer.complete();

                          await Get.snackbar(
                            "Account Deleted",
                            jsonResponse['message'],
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.green,
                            colorText: Colors.white,
                          ).future;

                          _performLogoutActions(); // Call the shared logout function

                        } else {
                          print('DEBUG (Flutter Delete - onData): Status is ERROR. Message: ${jsonResponse['message']}');
                          if (Get.isDialogOpen!) Get.back();
                          Get.snackbar(
                            "Error",
                            jsonResponse['message'],
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                          );
                          completer.completeError(Exception(jsonResponse['message']));
                        }
                      } catch (e) {
                        print('ERROR (Flutter Delete - onData): Decoding JSON response: $e');
                        if (Get.isDialogOpen!) Get.back();
                        Get.snackbar("Error", "Failed to process server response for account deletion.", snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
                        completer.completeError(e);
                      }
                    },
                    onError: (e) {
                      if (completer.isCompleted) return;

                      print('ERROR (Flutter Delete - onError): Stream error: $e');
                      if (Get.isDialogOpen!) Get.back();
                      Get.snackbar("Error", "Failed to receive server response for account deletion.", snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
                      completer.completeError(e);
                    },
                    onDone: () {
                      if (completer.isCompleted) return;

                      print('DEBUG (Flutter Delete - onDone): Stream done. No more data.');
                      if (Get.isDialogOpen!) Get.back();
                      completer.completeError(Exception('Connection closed by server prematurely.'));
                    }
                );
                await completer.future.timeout(const Duration(seconds: 5));
                print('DEBUG (Flutter Delete): Await completer.future finished.');
              } on TimeoutException {
                Get.snackbar("Error", "Connection timed out.", backgroundColor: Colors.red);
              } catch (e) {
                print('ERROR (Flutter Delete - outside catch): Network error during deleteAccount: $e');
                if (Get.isDialogOpen!) Get.back();
                Get.snackbar("Error", "Failed to connect to server for account deletion. Please check your connection.", snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);

              } finally {
                subscription?.cancel();
                socket?.close();
                print('DEBUG (Flutter Delete - finally): Delete operation finalized.');
              }
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _contactSupport() {
    final user = userController.currentUser.value;
    final String userEmail = user?['email'] ?? 'default@example.com';
    Get.to(() => SpotifySupportApp(userEmail: userEmail));
  }

  void _AboutUs() {
    Get.snackbar(
      "🎵 About Us",
      "This music player app was proudly created in the year 2025 by Mr. Amir Torab Eghdami and Mr. Amirreza Zeinalian as part of their Advanced Programming project at Shahid Beheshti University.\n\nBoth developers are passionate Computer Engineering students dedicated to crafting smooth, stylish, and functional user experiences. This project is a reflection of their creativity, collaboration, and coding excellence.\n\nEnjoy the music – powered by innovation and built with heart.",
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 20),
      backgroundColor: Colors.deepPurple.shade800.withOpacity(0.9),
      colorText: Colors.white,
      borderRadius: 20,
      margin: const EdgeInsets.all(15),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      animationDuration: const Duration(milliseconds: 500),
      boxShadows: [
        BoxShadow(
          color: Colors.deepPurple.withOpacity(0.5),
          blurRadius: 10,
          spreadRadius: 2,
          offset: const Offset(0, 3),
        ),
      ],
      icon: const Icon(Icons.music_note, color: Colors.amber, size: 28),
      shouldIconPulse: true,
      mainButton: TextButton(
        onPressed: () => Get.back(),
        child: const Text(
          '❤️',
          style: TextStyle(fontSize: 20),
        ),
      ),
      overlayBlur: 1.5,
      overlayColor: Colors.black.withOpacity(0.2),
      snackStyle: SnackStyle.FLOATING,
      forwardAnimationCurve: Curves.fastEaseInToSlowEaseOut,
      reverseAnimationCurve: Curves.fastLinearToSlowEaseIn,
      titleText: const Text(
        "🎵 About Us",
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.amber,
        ),
      ),
      messageText: const Text(
        "This music player app was proudly created in the year 2025 by Mr. Amir Torab Eghdami and Mr. Amirreza Zeinalian as part of their Advanced Programming project at Shahid Beheshti University.\n\nBoth developers are passionate Computer Engineering students dedicated to crafting smooth, stylish, and functional user experiences. This project is a reflection of their creativity, collaboration, and coding excellence.\n\nEnjoy the music – powered by innovation and built with heart.",
        style: TextStyle(
          fontSize: 14,
          color: Colors.white70,
          height: 1.4,
        ),
      ),
    );
  }

  void _buyPremium() {
    final user = userController.currentUser.value;
    final String userEmail = user?['email'] ?? 'default@example.com';
    final int currentWallet = user?['wallet'] ?? 0;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => BuyPremiumPage(
        userEmail: userEmail,
        currentWallet: currentWallet,
      ),
    );
  }


  void _editProfile() async {
    final user = userController.currentUser.value;
    if (user == null) {
      Get.snackbar("Error", "No user logged in to edit profile.", snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
      return;
    }

    final String previousEmail = user['email'] ?? '';
    final String initialUsername = user['username'] ?? "Guest";
    final String initialEmail = user['email'] ?? "guest@example.com";

    final Map<String, dynamic>? result = await Get.to<Map<String, dynamic>>(
          () => EditProfilePage(
        initialUsername: initialUsername,
        initialEmail: initialEmail,
      ),
    );

    if (result == null) {
      print('DEBUG: Edit profile cancelled or no data returned.');
      Get.snackbar("Info", "Profile edit cancelled or no changes saved.", snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.blueAccent, colorText: Colors.white);
      return;
    }

    print('DEBUG: Data received from EditProfilePage: $result');

    final String newUsername = result['newUsername'];
    final String newEmail = result['newEmail'];
    final String currentPassword = result['password'];

    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    Socket? socket;
    StreamSubscription? subscription;

    try {
      socket = await Socket.connect(serverIp, profilePort);
      print('DEBUG: Connected to backend for editProfile.');

      final Map<String, String> requestData = {
        'action': 'editProfile',
        'previousEmail': previousEmail,
        'password': currentPassword,
        'newUsername': newUsername,
        'newEmail': newEmail,
      };
      final String jsonString = jsonEncode(requestData);

      socket.writeln(jsonString);
      await socket.flush();
      print('DEBUG: Sent editProfile JSON to backend: $jsonString');

      final Completer<void> completer = Completer<void>();

      subscription = socket.transform(utf8.decoder as StreamTransformer<Uint8List, dynamic>).transform(const LineSplitter()).listen(
              (response) {
            if (completer.isCompleted) return;

            print('DEBUG: Received response from backend for editProfile: $response');
            try {
              final Map<String, dynamic> jsonResponse = jsonDecode(response);
              final String status = jsonResponse['status'];
              final String message = jsonResponse['message'];

              if (status == 'success') {
                final Map<String, dynamic> updatedUser = jsonResponse['user'];
                userController.currentUser.value = updatedUser;

                print('DEBUG: userController.currentUser.value after update: ${userController.currentUser.value}');
                print('DEBUG: Username from updated user: ${userController.currentUser.value?['username']}');
                print('DEBUG: Email from updated user: ${userController.currentUser.value?['email']}');

                if (Get.isDialogOpen!) Get.back();
                Get.snackbar(
                  'Success',
                  message,
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                );
                completer.complete();
              } else {
                if (Get.isDialogOpen!) Get.back();
                Get.snackbar(
                  'Error',
                  message,
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
                completer.completeError(Exception(message));
              }
            } catch (e) {
              print('Error decoding JSON response for editProfile: $e');
              if (Get.isDialogOpen!) Get.back();
              Get.snackbar(
                'Error',
                'Failed to process server response for profile update.',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.red,
                colorText: Colors.white,
              );
              completer.completeError(e);
            }
          },
          onError: (e) {
            if (completer.isCompleted) return;
            print('Network error during editProfile response stream: $e');
            if (Get.isDialogOpen!) Get.back();
            Get.snackbar(
              'Error',
              'Failed to receive server response for profile update.',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
            completer.completeError(e);
          },
          onDone: () {
            if (completer.isCompleted) return;
            print('Edit profile response stream done.');
            if (Get.isDialogOpen!) Get.back();
            completer.completeError(Exception('Connection closed by server prematurely.'));
          }
      );
      await completer.future.timeout(const Duration(seconds: 5));
    } on TimeoutException {
      Get.snackbar("Error", "Connection timed out.", backgroundColor: Colors.red);
      throw Exception('Connection timed out.');
    } catch (e) {
      if (Get.isDialogOpen!) Get.back();
      print('Network error during editProfile (outer catch): $e');
      Get.snackbar(
        'Error',
        'Failed to connect to server for profile update. Please check your connection.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      subscription?.cancel();
      socket?.close();
    }
  }


  @override
  Widget build(BuildContext context) {
    // Obx listens to AuthController.to.isLoggedIn.value
    return Obx(() {
      final bool isLoggedIn = AuthController.to.isLoggedIn.value;

      // If not logged in, show a login prompt
      if (!isLoggedIn) {
        return Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.deepPurple, Colors.black87],
                ),
              ),
            ),
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.lock_outline,
                      size: 80,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Access Denied',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      'Please log in to view your profile details.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.login, size: 24),
                      label: const Text(
                        'Login Now',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurpleAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 32,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: () => Get.to(() => LoginPage()),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }

      // If logged in, display the user profile
      final user = userController.currentUser.value;
      // Using getters from UserController for cleaner access, with fallback
      final currentUsername = userController.username ?? "Guest User";
      final currentEmail = userController.email ?? "guest@example.com";
      final currentWallet = userController.wallet ?? 0; // Directly use int from controller
      final currentHasSubscription = userController.hasSubscription ?? false;
      final bool currentDarkTheme = userController.darkTheme ?? false;


      // This block ensures the local state of wallet and subscription controllers
      // is always in sync with the user data from `userController.currentUser`.
      // It runs after the widget has been built to avoid errors during build.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Update wallet balance
        if (walletController.balance.value != (currentWallet as int).toDouble()) {
          walletController.balance.value = (currentWallet as int).toDouble();
        }
        // Update subscription status
        if (subController.isPremium.value != currentHasSubscription) {
          subController.isPremium.value = currentHasSubscription;
        }
        // Ensure ThemeController reflects the user's saved preference
        if (themeController.isDarkMode.value != currentDarkTheme) {
          themeController.setDarkTheme(currentDarkTheme);
        }
      });


      return Scaffold(
        appBar: AppBar(
          title: Text(
            currentUsername,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.deepPurple,
          elevation: 0,
          centerTitle: false,
          actions: [
            // NEW: Refresh button to fetch latest user data
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: _refreshUserData,
              tooltip: 'Refresh Profile Data',
            ),
          ],
        ),
        body: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.deepPurple, Colors.black87],
                ),
              ),
            ),
            SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 75),
                  GestureDetector(
                    onTap: _pickImage, // Tapping changes the profile picture
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      backgroundImage: _profileImage, // Displays the loaded image
                      child: _profileImage is AssetImage && (_profileImage as AssetImage).assetName == 'assets/default_avatar.png'
                          ? const Icon(Icons.person, size: 50, color: Colors.white) // Default icon if no image
                          : null,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    currentUsername,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currentEmail,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 10),

                  Text(
                    currentHasSubscription
                        ? "Premium Subscription 🎉"
                        : "Basic Subscription",
                    style: TextStyle(
                      color: currentHasSubscription
                          ? Colors.amber
                          : Colors.white70,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 20),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      gradient: LinearGradient(
                        colors: [
                          Colors.deepPurpleAccent,
                          Colors.deepPurple.shade700,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Wallet Balance",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Use Obx here to react to walletController.balance changes
                        Obx(() => Text(
                          "\$${walletController.balance.value.toStringAsFixed(2)}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        )),
                      ],
                    ),
                  ),

                  _buildListTile(Icons.edit, "Edit Profile", _editProfile),
                  _buildListTile(
                    Icons.account_balance_wallet,
                    "Wallet",
                        () => Get.to(() => PaymentPage(userEmail: currentEmail)), // <-- Change is here
                  ),

                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Obx(() => SwitchListTile( // Wrap SwitchListTile in Obx to react to themeController.isDarkMode changes
                      title: Text(
                        "Dark Theme",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                      value: themeController.isDarkMode.value, // Bind to theme controller's state
                      onChanged: _changeTheme, // Use your custom _changeTheme method
                      secondary: Icon(
                        Icons.brightness_6,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    )),
                  ),
                  const Divider(color: Colors.white30),
                  _buildListTile(Icons.support_agent, "Contact Support", _contactSupport),
                  _buildListTile(Icons.star, "About us", _AboutUs),
                  _buildListTile(Icons.upgrade, "Buy Premium", _buyPremium),
                  _buildListTile(
                    Icons.delete_forever,
                    "Delete Account",
                    _deleteAccount,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _performLogoutActions,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurpleAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                    ),
                    child: const Text(
                      'Logout',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildListTile(IconData icon, String title, dynamic onTap, {Color? color}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: color ?? Colors.deepPurpleAccent,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.white.withOpacity(0.9),
          ),
        ),
        trailing: onTap is String
            ? null
            : const Icon(
          Icons.chevron_right,
          color: Colors.white54,
        ),
        onTap: () {
          if (onTap is Function) {
            onTap();
          }
        },
      ),
    );
  }

  /// NEW: Method to refresh user data from the backend.
  Future<void> _refreshUserData() async {
    final user = userController.currentUser.value;
    if (user == null) {
      Get.snackbar("Error", "No user logged in to refresh data.",
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
      return;
    }

    final String userEmail = user['email'] ?? '';

    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    Socket? socket;

    try {
      socket = await Socket.connect(serverIp, refreshUserPort);
      print('DEBUG: Connected to backend for user refresh on new port.');

      final Map<String, String> requestData = {
        'email': userEmail,
      };
      final String jsonString = jsonEncode(requestData);

      socket.writeln(jsonString);
      await socket.flush();
      print('DEBUG: Sent refreshUser JSON to backend on new port: $jsonString');

      final response = await socket.first.timeout(const Duration(seconds: 10));
      final responseJsonString = utf8.decode(response);
      final Map<String, dynamic> jsonResponse = jsonDecode(responseJsonString);

      print('DEBUG: Received response from backend for user refresh: $responseJsonString');

      final String status = jsonResponse['status'];
      final String message = jsonResponse['message'];

      if (status == 'success') {
        final Map<String, dynamic> updatedUser = jsonResponse['user'];
        userController.currentUser.value = updatedUser; // Update user object, triggering UI refresh
        if (Get.isDialogOpen!) Get.back();
        Get.snackbar("Success", message,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white);
      } else {
        if (Get.isDialogOpen!) Get.back();
        Get.snackbar("Error", message,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white);
      }
    } on TimeoutException {
      if (Get.isDialogOpen!) Get.back();
      Get.snackbar("Error", "Connection timed out. Please check your network.", backgroundColor: Colors.red);
    } catch (e) {
      if (Get.isDialogOpen!) Get.back();
      print('Network error during user refresh (outer catch): $e');
      Get.snackbar(
        'Error',
        'Failed to connect to server for user refresh. Please check your connection.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );

      // This is the part you requested. It forces a UI refresh even on network failure.
      // NOTE: It is not a good practice as it misrepresents the application state.
      final Map<String, dynamic>? updatedUser = userController.currentUser.value;
      userController.currentUser.value = updatedUser;
      if (Get.isDialogOpen!) Get.back();
      Get.snackbar("Success", "Forced UI refresh on network failure.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white);

    } finally {
      await socket?.close();
      print('DEBUG: User refresh operation finalized (finally cleanup).');
    }
  }
}