import 'package:get/get.dart';
import 'package:my_new_app/app/controllers/dashboard/attendance_controller.dart';

class StudentAttendanceBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AttendanceController>(
      () => AttendanceController(),
    );
  }
}
