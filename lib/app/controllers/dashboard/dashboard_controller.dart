import 'dart:convert';

import 'package:get/get.dart';
import 'package:my_new_app/app/helpers/flutter_toast.dart';
import 'package:my_new_app/app/routes/app_routes.dart';

class DashboardController extends GetxController {
  void handleScannedData(String qrData) {
    try {
      final Map<String, dynamic> data = jsonDecode(qrData);

      successToast("Successfully Scanned");

      Get.toNamed(
        Routes.studentAttendance,
        arguments: data,
      );
    } catch (e) {
      errorToast("Invalid QR Code");
    }
  }
}
