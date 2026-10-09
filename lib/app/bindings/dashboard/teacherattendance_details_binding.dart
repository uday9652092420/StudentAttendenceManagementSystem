import 'package:get/get.dart';
import 'package:my_new_app/app/controllers/dashboard/teacherattendance_details_controller.dart';

class TeacherAttendanceDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TeacherAttendanceDetailsController>(
      () => TeacherAttendanceDetailsController(),
    );
  }
}
