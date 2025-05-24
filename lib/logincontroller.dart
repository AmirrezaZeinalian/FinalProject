// controllers/logincontroller.dart
import 'package:get/get.dart';
import 'AuthController.dart';

class LoginController extends GetxController {
  final email = ''.obs;
  final password = ''.obs;
  final errorMessage = ''.obs;
  final isLoading = false.obs;
  final passwordVisible = false.obs;

  final AuthController _authController = Get.put(AuthController());

  void togglePasswordVisibility() => passwordVisible.toggle();

  Future<void> login() async {
    try {
      isLoading(true);
      errorMessage(''); // Clear previous errors

      // Validate fields to be correct
      if (email.value.isEmpty || password.value.isEmpty) {
        errorMessage('Please fill all fields');
        return;
      }

      // Mock validation (replace with real API call)
      await Future.delayed(const Duration(seconds: 1));

      if (email.value == 'amir@example.com' && password.value == '123456') {
        // Access through Get.find
        Get.find<AuthController>().setLoggedIn(true);
        Get.offAllNamed('/home');
      } else {
        errorMessage('Invalid email or password');
      }
    } finally {
      isLoading(false);
    }
  }
}