import 'dart:convert';

import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';

import 'package:my_new_app/app/helpers/flutter_toast.dart';
import 'package:my_new_app/app/helpers/shared_preferences.dart';
import 'package:my_new_app/app/repositories/teacherstundentattendance/attendance_repository.dart';
import 'package:my_new_app/app/routes/app_routes.dart';

class DashboardController extends GetxController {
  final AttendanceRepository repository = AttendanceRepository();

  Future<void> handleScannedData(String qrData) async {
    try {
      final Map<String, dynamic> data = jsonDecode(qrData);

      final String classroomId = data["id"]?.toString() ?? "";

      if (classroomId.isEmpty) {
        errorToast("Invalid QR Code");
        return;
      }

      final String roleName =
          await SharedPrefsHelper.getString("roleName") ?? "";

      final String staffId = await SharedPrefsHelper.getString("staffId") ?? "";

      final role = roleName.toLowerCase();

      /// -------------------------------
      /// Teacher Flow
      /// -------------------------------
      if ((role.contains("teacher") || role.contains("lecturer")) &&
          staffId.isNotEmpty) {
        final response = await repository.getAttendanceContext(
          classroomId: classroomId,
          teacherId: staffId,
        );

        if (response != null && response.statusCode == 200) {
          final body = response.data;

          if (body["success"] == true) {
            successToast("Successfully Scanned");

            Get.toNamed(
              Routes.studentAttendance,
              arguments: {
                "classroomId": classroomId,
              },
            );
          } else {
            errorToast(body["message"] ?? "You are not assigned to this class");
          }
        } else {
          errorToast("Unable to verify classroom");
        }

        return;
      }

      /// -------------------------------
      /// Other Roles
      /// -------------------------------
      successToast("Successfully Scanned");

      Get.toNamed(
        Routes.studentAttendance,
        arguments: {
          "classroomId": classroomId,
        },
      );
    } catch (e) {
      print("QR ERROR => $e");
      errorToast("Invalid QR Code");
    }
  }

  Future<void> pickQrFromGallery() async {
    try {
      final picker = ImagePicker();

      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
      );

      if (image == null) return;

      final inputImage = InputImage.fromFilePath(image.path);

      final barcodeScanner = BarcodeScanner();

      final barcodes = await barcodeScanner.processImage(inputImage);

      await barcodeScanner.close();

      if (barcodes.isEmpty) {
        Get.snackbar(
          "Error",
          "No QR Code found in image",
        );
        return;
      }

      final qrCode = barcodes.first.rawValue;

      if (qrCode == null || qrCode.isEmpty) {
        Get.snackbar(
          "Error",
          "Invalid QR Code",
        );
        return;
      }

      print("QR FROM GALLERY => $qrCode");

      await handleScannedData(qrCode);
    } catch (e) {
      print("QR GALLERY ERROR => $e");

      Get.snackbar(
        "Error",
        "Unable to read QR Code",
      );
    }
  }
}
