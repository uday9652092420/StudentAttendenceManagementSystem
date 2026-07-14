import 'package:get/get.dart';
import 'package:my_new_app/app/controllers/kitchen/meal_checkin_controller.dart';

class MealCheckinBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => MealCheckinController());
  }
}
