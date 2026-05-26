import 'package:get/get.dart';
import 'package:my_new_app/app/helpers/flutter_toast.dart';
import 'package:my_new_app/app/routes/app_routes.dart';

class DashboardController extends GetxController {
  void scanQRCode() {
    errorToast("Successfully Scanned");
    Get.toNamed(Routes.studentAttendance);
  }
}
