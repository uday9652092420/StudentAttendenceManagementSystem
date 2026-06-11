import 'package:get/get.dart';
import '../../controllers/securitycontrollers/add_movement_controller.dart';

class AddMovementBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => AddMovementController(),
    );
  }
}
