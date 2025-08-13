import 'package:get/get.dart';

class UserController extends GetxController {
  // Use RxMap or Rx<Map<String, dynamic>> to make it reactive
  final Rx<Map<String, dynamic>?> currentUser = Rx<Map<String, dynamic>?>(null);

  void setUser(Map<String, dynamic> userData) {
    currentUser.value = userData;
    print('User set in UserController: ${currentUser.value}');
  }

  void clearUser() {
    currentUser.value = null;
    print('User cleared from UserController.');
  }

  // Optional: Add getters for specific user properties for convenience
  String? get username => currentUser.value?['username'];
  String? get email => currentUser.value?['email'];
  String? get city => currentUser.value?['city'];
  bool? get darkTheme => currentUser.value?['darkTheme'];
  bool? get hasSubscription => currentUser.value?['hasSubscription'];
  String? get wallpaperPath => currentUser.value?['wallpaperPath'];
  int? get wallet => currentUser.value?['wallet'];
// Add other getters as needed
}