import 'package:get/get.dart';

class AuthController extends GetxController {
  final RxBool isLoggedIn = false.obs;

  static AuthController get to => Get.find<AuthController>();

  void setLoggedIn(bool value) {
    isLoggedIn.value = value;
  }
}




// how to use it

// // In any other widget or controller:
// bool isLoggedIn = AuthController.to.isLoggedIn.value;
//
// // Reactively listen to changes:
// Obx(() {
// bool isLoggedIn = AuthController.to.isLoggedIn.value;
// return Text(isLoggedIn ? 'Logged In' : 'Logged Out');
// });
//
// // To logout from anywhere:
// AuthController.to.setLoggedIn(false);

// how to use it

// // In any other widget or controller:
// bool isLoggedIn = AuthController.to.isLoggedIn.value;
//
// // Reactively listen to changes:
// Obx(() {
// bool isLoggedIn = AuthController.to.isLoggedIn.value;
// return Text(isLoggedIn ? 'Logged In' : 'Logged Out');
// });
//
// // To logout from anywhere:
// AuthController.to.setLoggedIn(false);