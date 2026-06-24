import 'dart:convert';

import 'package:get/get.dart';
import 'package:my_new_app/app/helpers/flutter_toast.dart';
import 'package:my_new_app/app/routes/app_routes.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';

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

  Future<void> pickQrFromGallery() async {
    try {
      final picker = ImagePicker();

      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
      );

      if (image == null) return;

      final inputImage = InputImage.fromFilePath(
        image.path,
      );

      final barcodeScanner = BarcodeScanner();

      final barcodes = await barcodeScanner.processImage(
        inputImage,
      );

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

      handleScannedData(qrCode);
    } catch (e) {
      print("QR GALLERY ERROR => $e");

      Get.snackbar(
        "Error",
        "Unable to read QR Code",
      );
    }
  }
}
