import 'package:get/get.dart';

import 'package:my_new_app/app/controllers/kitchen/kitchen_dashboard_controller.dart';

class KitchenDashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<KitchenDashboardController>(
      () => KitchenDashboardController(),
    );
  }
}
