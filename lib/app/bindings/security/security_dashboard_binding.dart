import 'package:get/get.dart';
import 'package:my_new_app/app/controllers/securitycontrollers/security_dashboard_controller.dart';

class SecurityDashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(
      SecurityDashboardController(),
      permanent: true,
    );
  }
}
