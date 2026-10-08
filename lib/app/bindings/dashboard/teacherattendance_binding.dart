import 'package:get/get.dart';
import 'package:my_new_app/app/controllers/dashboard/teacherattendance_controller.dart';

class TeacherAttendanceBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StaffAttendanceSessionController>(
      () => StaffAttendanceSessionController(),
    );
  }
}
