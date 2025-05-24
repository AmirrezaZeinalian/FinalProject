import 'package:get/get.dart';

class AuthController extends GetxController {
  final RxBool isLoggedIn = false.obs;

  static AuthController get to => Get.find<AuthController>();

  void setLoggedIn(bool value) {
    isLoggedIn.value = value;
  }
}


