import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WalletController2 extends GetxController {
  String? userEmail; // Can be null
  var balance = 0.0.obs;

  static const String serverIp = '192.168.100.3';
  static const int serverPort = 13579;

  @override
  void onInit() {
    super.onInit();
    // This method can be used to fetch the initial balance after login
    // For now, we'll assume the balance is 0.0 unless funds are added.
    print('Fetching initial balance is a good practice, but requires a dedicated backend endpoint.');
  }

  void addFunds(double amount) {
    balance.value += amount;
  }

  void deductFunds(double amount) {
    if (balance.value >= amount) {
      balance.value -= amount;
    } else {
      Get.snackbar(
        "Insufficient Funds",
        "You don't have enough money in your wallet for this transaction.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // This is the updated method
  Future<String> addMoney(double amount, {String? email}) async {
    // Use the provided email or default to 'a@gmail.com' if null
    final String emailToSend = email ?? 'a@gmail.com';
    final int amountToSend = amount.toInt();

    print('Attempting to add funds for email: $emailToSend with amount: $amountToSend');

    try {
      final socket = await Socket.connect(serverIp, serverPort, timeout: const Duration(seconds: 10));
      print('Connected to server: ${socket.remoteAddress.address}:${socket.remotePort}');

      final requestJson = jsonEncode({
        'action': 'addFunds',
        'email': emailToSend,
        'amount': amountToSend,
      });

      socket.write('$requestJson\n');

      final response = await socket.first;
      final responseJsonString = utf8.decode(response);
      final responseJson = jsonDecode(responseJsonString);

      await socket.close();

      if (responseJson['status'] == 'success') {
        final userData = responseJson['user'];
        balance.value = (userData['wallet'] as int?)?.toDouble() ?? 0.0;
        return responseJson['message'];
      } else {
        return responseJson['message'] ?? 'An unknown error occurred.';
      }
    } catch (e) {
      print('Error during addFunds request: $e');
      return 'Failed to add funds. Please check your network connection.';
    }
  }

  void deductMoney(double price) {
    if (balance.value >= price) {
      balance.value -= price;
    } else {
      Get.snackbar(
        "Insufficient Funds",
        "You don't have enough money in your wallet for this transaction.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}













// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
//
// class WalletController2 extends GetxController { // Renamed to WalletController2
//   var balance = 0.0.obs;
//
//   void addFunds(double amount) {
//     balance.value += amount;
//   }
//
//   void deductFunds(double amount) {
//     if (balance.value >= amount) {
//       balance.value -= amount;
//     } else {
//       // Optional: Add a snackbar or error message if funds are insufficient
//       Get.snackbar(
//         "Insufficient Funds",
//         "You don't have enough money in your wallet for this transaction.",
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.red, // You'll need to import flutter/material.dart for Colors
//         colorText: Colors.white,
//       );
//     }
//   }
//
//   void addMoney(double amount) {
//     balance.value += amount;
//   }
//
//   void deductMoney(double price) {
//     if (balance.value >= price) {
//       balance.value -= price;
//     } else {
//       // Optional: Add a snackbar or error message if funds are insufficient
//       Get.snackbar(
//         "Insufficient Funds",
//         "You don't have enough money in your wallet for this transaction.",
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.red, // You'll need to import flutter/material.dart for Colors
//         colorText: Colors.white,
//       );
//     }
//   }
// }