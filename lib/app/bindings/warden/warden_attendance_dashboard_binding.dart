import 'package:get/get.dart';
import 'package:my_new_app/app/controllers/warden/warden_attendance_dashboard_controller.dart';

class WardenAttendanceDashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WardenAttendanceDashboardController>(
      () => WardenAttendanceDashboardController(),
    );
  }
}
