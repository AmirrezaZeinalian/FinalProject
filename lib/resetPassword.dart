import 'package:amiran/resetPasswordController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
class ResetPasswordPage extends StatelessWidget {
  final ResetPasswordController controller = Get.put(ResetPasswordController());
  final _formKey = GlobalKey<FormState>(); // Form key for validation

  InputDecoration _inputDecoration(String label, IconData icon, {Widget? suffixIcon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.deepPurple),
      prefixIcon: Icon(icon, color: Colors.deepPurple[300]),
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.deepPurple),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Reset Password', style: TextStyle(color: Colors.deepPurple)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.deepPurple),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
            padding: const EdgeInsets.all(25.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                Hero(
                tag: 'reset_password_hero', // Unique tag for this hero
                child: Image.asset(
                  'assets/reset_password_illustration.png', // You'll need an image for this
                  height: 180,
                  errorBuilder: (context, error, stackTrace) =>
                      Icon(Icons.lock_reset, size: 100, color: Colors.deepPurple),
                ),
              ),
              const SizedBox(height: 30),

              // Error Message Display
              Obx(() => AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: controller.errorMessage.value.isNotEmpty
                      ? Container(
                    key: ValueKey(controller.errorMessage.value), // Key for animation
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error, color: Colors.red),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            controller.errorMessage.value,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ):
                       const SizedBox(key: ValueKey('empty_error_message')),
            )),
        const SizedBox(height: 20),

        // Personal Details for Verification
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          margin: const EdgeInsets.symmetric(vertical: 10),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextFormField(
                  controller: controller.cityController,
                  decoration: _inputDecoration('City', Icons.location_city),
                  validator: (value) => value == null || value.isEmpty ? 'City is required' : null,
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: controller.dayController,
                        decoration: _inputDecoration('Day', Icons.calendar_today),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          final day = int.tryParse(value ?? '');
                          if (day == null || day < 1 || day > 31) return 'Invalid day';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: controller.monthController,
                        decoration: _inputDecoration('Month', Icons.calendar_today),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          final month = int.tryParse(value ?? '');
                          if (month == null || month < 1 || month > 12) return 'Invalid month';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: controller.yearController,
                        decoration: _inputDecoration('Year', Icons.calendar_today),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          final year = int.tryParse(value ?? '');
                          if (year == null || year < 1900 || year > DateTime.now().year) return 'Invalid year';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Obx(() => SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: controller.isLoading.value ? null : () {
                      if (_formKey.currentState!.validate()) {
                        controller.verifyDetails();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: controller.isLoading.value && !controller.isVerified.value
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Verify Details', style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                )),
              ],
            ),
          ),
        ),
        const SizedBox(height: 30),

        // New Password Fields (conditionally visible)
        Obx(() => controller.isVerified.value
            ? Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          margin: const EdgeInsets.symmetric(vertical: 10),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextFormField(
                  controller: controller.newPasswordController,
                  obscureText: controller.obscureNewPassword.value,
                  decoration: _inputDecoration(
                    'New Password',
                    Icons.lock,
                    suffixIcon: IconButton(
                      icon: Icon(
                        controller.obscureNewPassword.value ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: controller.toggleNewPasswordVisibility,
                    ),
                  ),
                  validator: controller.validatePassword,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: controller.confirmNewPasswordController,
                  obscureText: controller.obscureConfirmNewPassword.value,
                  decoration: _inputDecoration(
                    'Confirm New Password',
                    Icons.lock,
                    suffixIcon: IconButton(
                      icon: Icon(
                        controller.obscureConfirmNewPassword.value ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: controller.toggleConfirmNewPasswordVisibility,
                    ),
                  ),
                  validator: controller.validateConfirmPassword,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: controller.isLoading.value ? null : () {
                      if (_formKey.currentState!.validate()) { // Re-validate the form
                        controller.resetPassword();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: controller.isLoading.value
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Reset Password', style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        )
            : const SizedBox.shrink() // Hide password fields until verified
        ),
        ],
      ),
    ),
    ),
    ),
    );
  }
}