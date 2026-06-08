import 'package:get/get.dart';

import '../../controllers/securitycontrollers/dashboard_controller.dart';

class SecurityDashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SecurityDashboardController>(
      () => SecurityDashboardController(),
    );
  }
}
