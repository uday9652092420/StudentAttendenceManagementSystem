import 'package:get/get.dart';

import '../../controllers/mess/mess_dashboard_controller.dart';

class MessDashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MessDashboardController>(
      () => MessDashboardController(),
    );
  }
}
