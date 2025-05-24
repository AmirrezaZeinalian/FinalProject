// subscription_controller.dart
import 'package:get/get.dart';

class SubscriptionController extends GetxController {
  var isPremium = false.obs;

  void upgradeToPremium() => isPremium.value = true;
  void downgradeToBasic() => isPremium.value = false;
}