import 'package:get/get.dart';
import 'package:my_new_app/app/controllers/warden/take_attendance_controller.dart';

class TakeAttendanceBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TakeAttendanceController>(
      () => TakeAttendanceController(),
    );
  }
}
