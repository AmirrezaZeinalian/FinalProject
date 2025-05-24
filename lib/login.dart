import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'resetPassword.dart';
import 'signup.dart';
import 'AuthController.dart';
import 'logincontroller.dart';

//it has logic
class LoginPage extends StatelessWidget {
  final LoginController controller = Get.put(LoginController());
  final AuthController authController = Get.put(AuthController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Welcome Back', style: TextStyle(color: Colors.deepPurple)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.deepPurple),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            children: [
              Hero(
                tag: 'login_hero',
                child: Image.asset(
                  'assets/login_illustration.png',
                  height: 200,
                  errorBuilder: (context, error, stackTrace) =>
                      Icon(Icons.account_circle, size: 100, color: Colors.deepPurple),
                ),
              ),
              SizedBox(height: 30),

              // Email Field
              Obx(() => TextField(
                decoration: InputDecoration(
                  labelText: 'Email or Username',
                  labelStyle: TextStyle(color: Colors.deepPurple),
                  prefixIcon: Icon(Icons.email, color: Colors.deepPurple[300]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.deepPurple),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.deepPurple, width: 2),
                  ),
                  errorText: controller.errorMessage.value.isNotEmpty &&
                      controller.email.value.isEmpty
                      ? 'This field is required'
                      : null,
                ),
                onChanged: (value) => controller.email.value = value,
              )),
              SizedBox(height: 20),

              // Password Field with visibility toggle
              Obx(() => TextField(
                obscureText: !controller.passwordVisible.value,
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: TextStyle(color: Colors.deepPurple),
                  prefixIcon: Icon(Icons.lock, color: Colors.deepPurple[300]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.deepPurple, width: 2),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      controller.passwordVisible.value
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Colors.grey,
                    ),
                    onPressed: controller.togglePasswordVisibility,
                  ),
                  errorText: controller.errorMessage.value.isNotEmpty &&
                      controller.password.value.isEmpty
                      ? 'This field is required'
                      : null,
                ),
                onChanged: (value) => controller.password.value = value,
              )),
              SizedBox(height: 10),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Get.to(ResetPasswordPage()),
                  child: Text(
                    'Forgot Password?',
                    style: TextStyle(color: Colors.deepPurple),
                  ),
                ),
              ),
              SizedBox(height: 20),

              Obx(() => AnimatedSwitcher(
                duration: Duration(milliseconds: 300),
                child: controller.errorMessage.value.isNotEmpty
                    ? Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error, color: Colors.red),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          controller.errorMessage.value,
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                )
                    : SizedBox(),
              )),
              SizedBox(height: 20),

              Obx(() => AnimatedContainer(
                duration: Duration(milliseconds: 300),
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: LinearGradient(
                    colors: [Colors.deepPurple, Colors.purpleAccent],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.deepPurple.withOpacity(0.3),
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: controller.login,
                  child: controller.isLoading.value
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text(
                    'LOGIN',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )),
              SizedBox(height: 30),

              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text('OR', style: TextStyle(color: Colors.grey)),
                  ),
                  Expanded(child: Divider(color: Colors.grey)),
                ],
              ),
              SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Image.asset(
                      'assets/google.png',
                      height: 40,
                      errorBuilder: (context, error, stackTrace) =>
                          Icon(Icons.g_mobiledata, size: 40),
                    ),
                    onPressed: () {},
                  ),
                  SizedBox(width: 20),
                  IconButton(
                    icon: Image.asset(
                      'assets/facebook.png',
                      height: 40,
                      errorBuilder: (context, error, stackTrace) =>
                          Icon(Icons.facebook, size: 40),
                    ),
                    onPressed: () {},
                  ),
                ],
              ),
              SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Don't have an account? "),
                  TextButton(
                    onPressed: () => Get.to(RegisterPage()),
                    child: Text(
                      'Register',
                      style: TextStyle(
                        color: Colors.deepPurple,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

