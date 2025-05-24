import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import 'Controllers/signupController.dart';
import 'login.dart';
import 'signupController.dart';
class RegisterPage extends StatelessWidget {
  RegisterPage({Key? key}) : super(key: key);

  final _formKey = GlobalKey<FormState>();
  final SignupController controller = Get.put(SignupController());

  InputDecoration _inputDecoration(String label, {Widget? suffixIcon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.deepPurple.withOpacity(0.8)),
      floatingLabelStyle: TextStyle(color: Colors.deepPurple),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.deepPurple.withOpacity(0.5)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.deepPurple.withOpacity(0.5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.deepPurple, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red, width: 2),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      suffixIcon: suffixIcon,
      prefixIcon: label.contains('Username')
          ? Icon(Icons.person_outline, color: Colors.deepPurple)
          : label.contains('Email')
          ? Icon(Icons.email_outlined, color: Colors.deepPurple)
          : Icon(Icons.lock_outline, color: Colors.deepPurple),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.deepPurple),
                      onPressed: () => Get.back(),
                    ),
                  ],
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Create Account',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Fill in your details to get started',
                      style: TextStyle(color: Colors.grey[600], fontSize: 16),
                    ),
                    SizedBox(height: 32),

                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Username
                          TextFormField(
                            controller: controller.usernameController,
                            decoration: _inputDecoration('Username'),
                            validator: controller.validateUsername,
                          ),
                          SizedBox(height: 20),

                          // Email
                          TextFormField(
                            controller: controller.emailController,
                            decoration: _inputDecoration('Email'),
                            keyboardType: TextInputType.emailAddress,
                            validator: controller.validateEmail,
                          ),
                          SizedBox(height: 20),

                          // Password
                          Obx(() => TextFormField(
                            controller: controller.passwordController,
                            obscureText: controller.obscurePassword.value,
                            decoration: _inputDecoration(
                              'Password',
                              suffixIcon: IconButton(
                                icon: Icon(
                                  controller.obscurePassword.value
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: Colors.grey,
                                ),
                                onPressed: controller.togglePasswordVisibility,
                              ),
                            ),
                            validator: (value) => controller.validatePassword(
                              value,
                              controller.usernameController.text,
                            ),
                          )),
                          SizedBox(height: 20),

                          // Confirm Password
                          Obx(() => TextFormField(
                            controller: controller.confirmPasswordController,
                            obscureText: controller.obscureConfirmPassword.value,
                            decoration: _inputDecoration(
                              'Confirm Password',
                              suffixIcon: IconButton(
                                icon: Icon(
                                  controller.obscureConfirmPassword.value
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: Colors.grey,
                                ),
                                onPressed: controller.toggleConfirmPasswordVisibility,
                              ),
                            ),
                            validator: (value) => controller.validateConfirmPassword(
                              value,
                              controller.passwordController.text,
                            ),
                          )),
                          SizedBox(height: 32),

                          // Register Button
                          Obx(() => SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: controller.isLoading.value
                                  ? null
                                  : () => controller.register(_formKey),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 3,
                                shadowColor: Colors.deepPurple.withOpacity(0.3),
                              ),
                              child: controller.isLoading.value
                                  ? CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 3,
                              )
                                  : Text(
                                'REGISTER',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          )),
                          SizedBox(height: 24),



                          // Divider
                          Row(
                            children: [
                              Expanded(child: Divider(color: Colors.grey[400])),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: Text('OR', style: TextStyle(color: Colors.grey)),
                              ),
                              Expanded(child: Divider(color: Colors.grey[400])),
                            ],
                          ),
                          SizedBox(height: 24),
                          SizedBox(height: 0),
                          SizedBox(height: 0),
                          SizedBox(height: 0),
                          SizedBox(height: 0),
                          SizedBox(height: 0),

                          // Login Redirect
                          Center(
                            child: TextButton(
                              onPressed: () => Get.off(() => LoginPage()),
                              child: RichText(
                                text: TextSpan(
                                  text: 'Already have an account? ',
                                  style: TextStyle(color: Colors.grey[600]),
                                  children: [
                                    TextSpan(
                                      text: 'Login',
                                      style: TextStyle(
                                        color: Colors.deepPurple,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],

                                  
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
