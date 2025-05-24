import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'Payment.dart';
import 'dart:io';
import 'ThemeController2.dart';
import 'editProfile.dart';
import 'wallet.dart';
import 'subscription_controller.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  String username = "Guest User";
  String email = "guest@example.com";
  String subscriptionType = "Basic Subscription";
  int credit = 45;
  bool isDarkTheme = false;
  ImageProvider profileImage = const AssetImage('assets/default_avatar.png');
  final WalletController2 walletController = Get.put(WalletController2());
  final SubscriptionController subController = Get.find<SubscriptionController>();

  @override
  void initState() {
    super.initState();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();

    // Show option dialog to choose source
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
      final picked = await picker.pickImage(source: source);
      if (picked != null) {
        setState(() {
          profileImage = FileImage(File(picked.path));
        });
      }
    }
  }

  void _changeTheme(bool value) {
    setState(() {
      isDarkTheme = value;
    });
    Get.find<ThemeController>().toggleTheme();
  }

  void _deleteAccount() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Account", style: TextStyle(color: Colors.red)),
        content: const Text("Are you sure you want to delete your account?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("No")),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Yes", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _contactSupport() {
    Get.snackbar(
      "Support",
      "Contact us at support@nava.com",
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _AboutUs() {
    Get.snackbar(
      "🎵 About Us",
      "This music player app was proudly created in the year 1404 by Mr. Amir Torab Eghdami and Mr. Amirreza Zeinalian as part of their Advanced Programming project at Shahid Beheshti University.\n\nBoth developers are passionate Computer Engineering students dedicated to crafting smooth, stylish, and functional user experiences. This project is a reflection of their creativity, collaboration, and coding excellence.\n\nEnjoy the music – powered by innovation and built with heart.",
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 10),
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
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.4, // Slightly increased height
        ),
        decoration: BoxDecoration(
          color: Colors.deepPurple.shade800,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(5, 5, 5, 5), // Removed bottom padding
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded( // Added Expanded to make content scrollable
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildSubscriptionOption(
                      icon: Icons.calendar_month,
                      title: "Monthly",
                      price: 100000,
                      duration: "1 Month",
                    ),
                    const SizedBox(height: 10),
                    _buildSubscriptionOption(
                      icon: Icons.calendar_today,
                      title: "3-Month",
                      price: 230000,
                      duration: "3 Months",
                      isPopular: true,
                    ),
                    const SizedBox(height: 10),
                    _buildSubscriptionOption(
                      icon: Icons.event_available,
                      title: "Yearly",
                      price: 600000,
                      duration: "1 Year",
                    ),
                  ],
                ),
              ),
            ),
            Padding( // Wrapped the close button in Padding
              padding: const EdgeInsets.only(bottom: 16, top: 8),
              child: TextButton(
                onPressed: () => Get.back(),
                child: const Text(
                  'Close',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

// Keep your existing _buildSubscriptionOption widget exactly as is

  Widget _buildSubscriptionOption({
    required IconData icon,
    required String title,
    required int price,
    required String duration,
    bool isPopular = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade700,
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        onTap: () => _handlePurchase(price), // 👈 Entire tile is tappable now
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        leading: Icon(icon, color: Colors.white),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Flexible(
                  child: Text(
                    "$title Subscription",
                    style: const TextStyle(color: Colors.white),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isPopular)
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      "Popular",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            Text(
              duration,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: Text(
          '${(price / 1000).toStringAsFixed(0)}k\$',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }



  void _handlePurchase(int price) {
    final currentBalance = walletController.balance.value;
    final priceDouble = price.toDouble();

    if (currentBalance >= priceDouble) {
      walletController.deductMoney(priceDouble);
      subController.upgradeToPremium(); // 👈 Update premium status here
      Get.back();
      Get.snackbar(
        'Purchase Successful!',
        'Enjoy your premium subscription!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } else {
      final neededAmount = priceDouble - currentBalance;
      Get.back();
      Get.to(() => PaymentPage());
      Get.snackbar(
        'Insufficient Funds',
        'You need \$${neededAmount.toStringAsFixed(2)} more to purchase this subscription',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
    }
  }

  void _editProfile() async {
    final result = await Get.to(
          () => EditProfilePage(
        initialUsername: username,
        initialEmail: email,
      ),
    );

    if (result != null) {
      setState(() {
        username = result['username'];
        email = result['email'];
      });

      Get.snackbar(
        'Success',
        'Profile updated successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    backgroundImage: profileImage,
                    child: profileImage is AssetImage
                        ? const Icon(Icons.person, size: 50, color: Colors.white)
                        : null,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  username,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  email,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 10),

                Obx(() => Text(
                  subController.isPremium.value
                      ? "Premium Subscription 🎉"
                      : "Basic Subscription",
                  style: TextStyle(
                    color: subController.isPremium.value
                        ? Colors.amber
                        : Colors.white70,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                )),

                const SizedBox(height: 20),

                // Wallet Balance Card
                Obx(() {
                  final balance = walletController.balance.value;
                  return Container(
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
                        Text(
                          "\$${balance.toStringAsFixed(2)}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  );
                }),

                _buildListTile(Icons.edit, "Edit Profile", _editProfile),
                _buildListTile(
                  Icons.account_balance_wallet,
                  "Wallet",
                      () => Get.to(() => const PaymentPage()),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: SwitchListTile(
                    title: Text(
                      "Dark Theme",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    value: isDarkTheme,
                    onChanged: _changeTheme,
                    secondary: Icon(
                      Icons.brightness_6,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
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
                  onPressed: () {
                    Get.toNamed('/login');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurpleAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  ),
                  child: const Text(
                    'Login to your account',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
}


class WalletController2 extends GetxController {
  var balance = 0.0.obs;

  void addMoney(double amount) {
    balance.value += amount;
  }

  void deductMoney(double amount) {
    balance.value -= amount;
  }
}








// Example usage in another widget
// class PremiumFeature extends StatelessWidget {
//   final SubscriptionController subCtrl = Get.find();
//
//   @override
//   Widget build(BuildContext context) {
//     return Obx(() => Column(
//       children: [
//         SwitchListTile(
//           title: Text('Premium Features ${subCtrl.isPremium.value ? '🔓' : '🔒'}'),
//           value: subCtrl.isPremium.value,
//           onChanged: (value) {
//             if (value) {
//               Get.to(() => ProfileTab()); // Navigate to upgrade
//             } else {
//               subCtrl.downgradeToBasic();
//             }
//           },
//         ),
//         if (subCtrl.isPremium.value)
//           const Text('🎵 Unlimited Skips\n🌟 Exclusive Content\n⚡ Priority Support',
//               style: TextStyle(color: Colors.amber)),
//       ],
//     ));
//   }
// }


// // Get current status
// bool isPremium = Get.find<SubscriptionController>().isPremium.value;
//
// // Reactively listen for changes
// Obx(() => Text(
// Get.find<SubscriptionController>().isPremium.value
// ? "Premium User"
// : "Basic User"
// ));