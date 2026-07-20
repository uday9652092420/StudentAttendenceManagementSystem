import 'package:get/get.dart';
import '../../controllers/masjid/masjid_dashboard_controller.dart';

class MasjidDashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MasjidDashboardController>(
      () => MasjidDashboardController(),
    );
  }
}
