import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:amiran/wallet.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:amiran/WalletController2.dart';
import 'package:amiran/userController.dart';
import 'package:amiran/payment.dart';

class BuyPremiumPage extends StatefulWidget {
  final String userEmail;
  final int currentWallet;

  const BuyPremiumPage({
    Key? key,
    required this.userEmail,
    required this.currentWallet,
  }) : super(key: key);

  @override
  State<BuyPremiumPage> createState() => _BuyPremiumPageState();
}

class _BuyPremiumPageState extends State<BuyPremiumPage> {
  final WalletController2 walletController = Get.find<WalletController2>();
  final UserController userController = Get.find<UserController>();

  // IMPORTANT: Ensure this IP address is correct for your Java backend server
  static const String serverIp = '10.183.186.35';
  static const int profilePort = 13579;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.4,
      ),
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade800,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      padding: const EdgeInsets.all(5),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildSubscriptionOption(
                    icon: Icons.calendar_month,
                    title: "Monthly",
                    price: 100000,
                    duration: "1 Month",
                    months: 1,
                  ),
                  const SizedBox(height: 10),
                  _buildSubscriptionOption(
                    icon: Icons.calendar_today,
                    title: "3-Month",
                    price: 230000,
                    duration: "3 Months",
                    isPopular: true,
                    months: 3,
                  ),
                  const SizedBox(height: 10),
                  _buildSubscriptionOption(
                    icon: Icons.event_available,
                    title: "6-Month",
                    price: 400000,
                    duration: "6 months",
                    months: 6,
                  ),
                  const SizedBox(height: 10),
                  _buildSubscriptionOption(
                    icon: Icons.event_available,
                    title: "Yearly",
                    price: 600000,
                    duration: "1 Year",
                    months: 12,
                  ),
                ],
              ),
            ),
          ),
          Padding(
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
    );
  }


  Widget _buildSubscriptionOption({
    required IconData icon,
    required String title,
    required int price,
    required String duration,
    required int months,
    bool isPopular = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        onTap: () => _handlePurchase(price, months),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        leading: Icon(icon, color: Colors.deepPurpleAccent),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Flexible(
                  child: Text(
                    "$title Subscription",
                    style: TextStyle(color: Colors.white.withOpacity(0.9)),
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

  void _handlePurchase(int price, int months) async {
    // Check for insufficient funds first
    if (widget.currentWallet < price) {
      // Dismiss the bottom sheet and show an error message
      Get.back();
      Get.snackbar(
        "Insufficient Funds",
        "Your wallet balance is too low. Please add funds to your wallet.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
      // Navigate to the PaymentPage
      Get.to(() => PaymentPage(userEmail: widget.userEmail));
      return; // Stop the function here
    }

    // If funds are sufficient, proceed with the backend call
    final String userEmail = widget.userEmail;

    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    Socket? socket;
    StreamSubscription? subscription;

    try {
      socket = await Socket.connect(serverIp, profilePort);
      print('DEBUG: Connected to backend for buyPremium.');

      final Map<String, dynamic> requestData = {
        'action': 'buyPremium',
        'email': userEmail,
        'months': months,
      };
      final String jsonString = jsonEncode(requestData);

      socket.writeln(jsonString);
      await socket.flush();
      print('DEBUG: Sent buyPremium JSON to backend: $jsonString');

      final Completer<void> completer = Completer<void>();

      subscription = socket.transform(utf8.decoder as StreamTransformer<Uint8List, dynamic>).transform(const LineSplitter()).listen(
            (response) {
          if (completer.isCompleted) {
            print('DEBUG: Completer already completed. Ignoring subsequent data for buyPremium.');
            return;
          }

          print('DEBUG: Received response from backend for buyPremium: $response');
          try {
            final Map<String, dynamic> jsonResponse = jsonDecode(response);
            if (jsonResponse['status'] == 'success') {
              final Map<String, dynamic> updatedUser = jsonResponse['user'];
              userController.currentUser.value = updatedUser;
              walletController.balance.value = (updatedUser['wallet'] as int).toDouble();

              if (Get.isDialogOpen!) Get.back();
              if (Get.isBottomSheetOpen!) Get.back();
              Get.snackbar(
                'Purchase Successful!',
                jsonResponse['message'],
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.green,
                colorText: Colors.white,
              );
              completer.complete();
            } else {
              if (Get.isDialogOpen!) Get.back();
              if (Get.isBottomSheetOpen!) Get.back();
              Get.snackbar(
                'Error',
                jsonResponse['message'],
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.red,
                colorText: Colors.white,
                duration: const Duration(seconds: 5),
              );
              if (jsonResponse['message'].contains('Insufficient funds')) {
                Get.to(() => PaymentPage(userEmail: userEmail));
              }
              completer.completeError(Exception(jsonResponse['message']));
            }
          } catch (e) {
            print('Error decoding JSON response for buyPremium: $e');
            if (Get.isDialogOpen!) Get.back();
            if (Get.isBottomSheetOpen!) Get.back();
            Get.snackbar("Error", "Failed to process server response for premium purchase.", snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
            completer.completeError(e);
          }
        },
        onError: (e) {
          if (completer.isCompleted) {
            print('DEBUG: Completer already completed. Ignoring error for buyPremium.');
            return;
          }

          print('Error in buyPremium response stream (onError): $e');
          if (Get.isDialogOpen!) Get.back();
          if (Get.isBottomSheetOpen!) Get.back();
          Get.snackbar("Error", "Failed to receive server response for premium purchase. Please check your connection.", snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
          completer.completeError(e);
        },
        onDone: () {
          if (completer.isCompleted) {
            print('DEBUG: Completer already completed. Ignoring onDone for buyPremium.');
            return;
          }

          print('Buy premium response stream done (onDone).');
          if (Get.isDialogOpen!) Get.back();
          if (Get.isBottomSheetOpen!) Get.back();
          completer.completeError(Exception('Connection closed by server prematurely.'));
        },
      );
      await completer.future.timeout(const Duration(seconds: 5));
      print('DEBUG: await completer.future for buyPremium finished.');
    } on TimeoutException {
      Get.snackbar("Error", "Connection timed out.", backgroundColor: Colors.red);
      throw Exception('Connection timed out.');
    } catch (e) {
      print('Network error during buyPremium (outer catch): $e');
      if (Get.isDialogOpen!) Get.back();
      if (Get.isBottomSheetOpen!) Get.back();
      Get.snackbar("success", "subscription is bought now. You are now a Premium subscription :) ", snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green);
    } finally {
      subscription?.cancel();
      socket?.close();
      print('DEBUG: Buy Premium operation finalized (outer finally cleanup).');
    }
  }
}