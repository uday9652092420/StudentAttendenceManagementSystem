import 'package:get/get.dart';
import 'package:my_new_app/app/controllers/sponsor/sponsor_dashboard_controller.dart';

class SponsorDashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SponsorDashboardController>(
      () => SponsorDashboardController(),
    );
  }
}
