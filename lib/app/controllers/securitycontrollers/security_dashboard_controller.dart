import 'dart:convert';

import 'package:get/get.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_new_app/app/helpers/flutter_toast.dart';

import '../../helpers/shared_preferences.dart';
import '../../models/security/secuity_dashboardmodel.dart';
import '../../routes/app_routes.dart';
import '../../services/api_service.dart';

class SecurityDashboardController extends GetxController {
  final ApiService apiService = ApiService();

  RxBool isLoading = false.obs;

//logout
  Future<void> logout() async {
    await SharedPrefsHelper.remove("username");
    await SharedPrefsHelper.remove("roleName");
    await SharedPrefsHelper.remove(
      SharedPrefsHelper.accessToken,
    );

    Get.offAllNamed(Routes.login);
  }

  Future<void> pickQrFromGallery() async {
    try {
      final picker = ImagePicker();

      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
      );

      if (image == null) {
        Get.snackbar(
          "Cancelled",
          "No image selected",
        );
        return;
      }

      final inputImage = InputImage.fromFilePath(
        image.path,
      );

      final barcodeScanner = BarcodeScanner(
        formats: [
          BarcodeFormat.qrCode,
        ],
      );

      final List<Barcode> barcodes = await barcodeScanner.processImage(
        inputImage,
      );

      await barcodeScanner.close();

      if (barcodes.isEmpty) {
        Get.snackbar(
          "Invalid QR",
          "No QR code found in image",
        );
        return;
      }

      final String qrCode = barcodes.first.rawValue ?? "";

      print("QR FROM GALLERY => $qrCode");

      String gatePassId = "";

      try {
        final qrData = jsonDecode(qrCode) as Map<String, dynamic>;

        gatePassId = qrData["gatePassId"]?.toString() ?? "";
      } catch (_) {
        gatePassId = qrCode;
      }

      print(
        "EXTRACTED GATEPASS ID => $gatePassId",
      );

      if (gatePassId.isEmpty) {
        Get.snackbar(
          "Error",
          "Gate Pass ID not found in QR",
        );
        return;
      }

      await processScan(qrCode);

      Get.toNamed(
        Routes.addMovement,
        arguments: gatePassId,
      );
    } catch (e) {
      print("QR ERROR => $e");

      Get.snackbar(
        "Error",
        e.toString(),
      );
    }
  }

  Future<void> processScan(String qrCode) async {
    try {
      isLoading.value = true;

      final username = await SharedPrefsHelper.getString(
            "username",
          ) ??
          "Security";

      final scanModel = GatepassScanModel(
        qrCode: qrCode,
        securityName: username,
        scanTime: DateTime.now().toIso8601String(),
      );

      print(
        "SCAN DATA => ${scanModel.toJson()}",
      );

      await apiService.validateGatepass(
        scanModel.toJson(),
      );

      successToast(
        "Gatepass scanned successfully",
      );
    } catch (e) {
      print("SCAN ERROR => $e");

      Get.snackbar(
        "Error",
        e.toString(),
      );
    } finally {
      isLoading.value = false;
    }
  }
}
