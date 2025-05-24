import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';

class PAY extends StatefulWidget {
  const PAY({Key? key}) : super(key: key);

  @override
  State<PAY> createState() => _PAYState();
}

class _PAYState extends State<PAY> {
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final WalletController _walletController = Get.find();

  // Static user password (last 4 digits)
  final String _userPassword = "1234"; // Replace with actual user's last 4 password digits

  @override
  void dispose() {
    _cardNumberController.dispose();
    _pinController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Payment', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Current Balance Card
            Obx(() => Container(
              margin: const EdgeInsets.only(bottom: 30),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.deepPurple[400]!, Colors.deepPurple[800]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.deepPurple.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  )
                ],
              ),
              child: Column(
                children: [
                  const Text('Current Balance',
                      style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 10),
                  Text('\$${_walletController.balance.value.toStringAsFixed(2)}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            )),

            // Payment Form
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Card Number Field
                    TextFormField(
                      controller: _cardNumberController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(16),
                        CardNumberFormatter(),
                      ],
                      decoration: InputDecoration(
                        labelText: 'Card Number',
                        hintText: 'XXXX XXXX XXXX XXXX',
                        prefixIcon: Icon(Icons.credit_card, color: Colors.deepPurple),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.deepPurple),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // PIN Field
                    TextFormField(
                      controller: _pinController,
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      maxLength: 4,
                      decoration: InputDecoration(
                        labelText: 'PIN (Last 4 digits of your password)',
                        prefixIcon: Icon(Icons.lock, color: Colors.deepPurple),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Amount Field
                    TextFormField(
                      controller: _amountController,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Amount',
                        prefixIcon: Icon(Icons.attach_money, color: Colors.deepPurple),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Pay Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: _processPayment,
                        child: const Text('PAY NOW',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _processPayment() {
    // Validate card number (must be 16 digits)
    final cardNumber = _cardNumberController.text.replaceAll(' ', '');
    if (cardNumber.length != 16) {
      Get.snackbar(
        'Error',
        'Please enter a valid 16-digit card number',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Validate PIN (must match user's last 4 password digits)
    if (_pinController.text != _userPassword) {
      Get.snackbar(
        'Error',
        'Incorrect PIN. Please enter the last 4 digits of your password',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Validate amount
    final amount = double.tryParse(_amountController.text) ?? 0;
    if (amount <= 0) {
      Get.snackbar(
        'Error',
        'Please enter a valid amount greater than 0',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Process payment
    _walletController.addFunds(amount);

    // Show success message
    Get.snackbar(
      'Success',
      '\$${amount.toStringAsFixed(2)} added to your wallet',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.deepPurple,
      colorText: Colors.white,
    );

    // Clear fields
    _cardNumberController.clear();
    _pinController.clear();
    _amountController.clear();
  }
}

// Card number formatter (XXXX XXXX XXXX XXXX)
class CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text.replaceAll(' ', '');
    String formatted = '';

    for (int i = 0; i < text.length; i++) {
      if (i > 0 && i % 4 == 0) formatted += ' ';
      formatted += text[i];
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

// Wallet Controller (should be in a separate file)
class WalletController extends GetxController {
  var balance = 0.0.obs;

  void addFunds(double amount) {
    balance.value += amount;
  }

  void deductFunds(double amount) {
    if (balance.value >= amount) {
      balance.value -= amount;
    }
  }
}