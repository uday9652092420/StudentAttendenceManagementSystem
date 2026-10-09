import 'package:get/get.dart';
import 'package:my_new_app/app/controllers/dashboard/teacherattendance_history_controller.dart';

class TeacherAttendanceHistoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TeacherAttendanceHistoryController>(
      () => TeacherAttendanceHistoryController(),
    );
  }
}
