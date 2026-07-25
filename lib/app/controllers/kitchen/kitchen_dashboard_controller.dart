import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:my_new_app/app/repositories/kitchen/kitchen_repository.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:my_new_app/app/helpers/flutter_toast.dart';

import 'package:my_new_app/app/models/kitchen/meal_scan_model.dart';

import 'package:my_new_app/app/routes/app_routes.dart';

class KitchenDashboardController extends GetxController {
  /// Loading
  RxBool isLoading = false.obs;

  /// Meal Counts
  RxInt breakfastCount = 0.obs;
  RxInt lunchCount = 0.obs;
  RxInt dinnerCount = 0.obs;

  /// Selected Meal
  RxString selectedMeal = "Lunch".obs;

  final List<String> mealTypes = [
    "Breakfast",
    "Lunch",
    "Dinner",
  ];

  /// Recent Scans
  RxList<MealScanModel> recentScans = <MealScanModel>[].obs;

  /// Scanner
  final MobileScannerController scannerController = MobileScannerController();

  final KitchenRepository repository = KitchenRepository();

  // Future<void> loadDashboard() async {
  //   await Future.wait([
  //     getMealCounts(),
  //     getRecentScans(),
  //   ]);
  // }

  // /// Today's Meal Counts
  // Future<void> getMealCounts() async {
  //   // final response = await repository.getTodayMealCount();

  //   if (response != null && response.statusCode == 200) {
  //     breakfastCount.value = response.data["breakfast"] ?? 0;
  //     lunchCount.value = response.data["lunch"] ?? 0;
  //     dinnerCount.value = response.data["dinner"] ?? 0;
  //   }
  // }

  // /// Recent Students
  // Future<void> getRecentScans() async {
  //   final response = await repository.getRecentScans();

  //   if (response != null && response.statusCode == 200) {
  //     recentScans.assignAll(
  //       (response.data as List).map((e) => MealScanModel.fromJson(e)).toList(),
  //     );
  //   }
  // }

  Future<void> handleScannedData(String qrCode) async {
    try {
      if (isLoading.value) return;

      isLoading.value = true;

      String studentId = "";

      // QR contains JSON
      if (qrCode.trim().startsWith("{")) {
        final data = jsonDecode(qrCode);

        studentId = data["studentId"]?.toString() ?? "";
      } else {
        // QR contains only ID
        studentId = qrCode.trim();
      }

      if (studentId.isEmpty) {
        errorToast("Invalid QR Code");
        return;
      }

      print("STUDENT ID => $studentId");

      final response = await repository.getStudentByQr(studentId);

      print(response?.data);

      if (response == null || response.statusCode != 200) {
        errorToast("Student not found");
        return;
      }

      if (response.data["success"] != true) {
        errorToast("Student not found");
        return;
      }

      final student = response.data["data"];

      Get.toNamed(
        Routes.mealCheckin,
        arguments: {
          "studentId": student["studentId"]?.toString() ?? "",
          "studentCode": student["studentCode"]?.toString() ?? "",
          "studentName": student["studentName"] ?? "",
          "courseName": student["courseName"] ?? "",
          "className": student["className"] ?? "",
          "meal": selectedMeal.value,
        },
      );
    } catch (e) {
      print(e);
      errorToast("Unable to load student details");
    } finally {
      isLoading.value = false;
    }
  }

  // Future<void> handleScannedData(String qrCode) async {
  //   print("========== QR SCANNED ==========");
  //   print(qrCode);

  //   if (isLoading.value) return;

  //   isLoading.value = true;

  //   try {
  //     print("Calling student API...");

  //     final studentResponse = await repository.getStudentByQr(qrCode);

  //     print("STATUS = ${studentResponse?.statusCode}");
  //     print("BODY = ${studentResponse?.data}");

  //     if (studentResponse == null) {
  //       print("Response NULL");
  //       return;
  //     }

  //     if (studentResponse.statusCode != 200) {
  //       print("API FAILED");
  //       return;
  //     }

  //     final student = studentResponse.data;

  //     print("Navigating...");

  //     Get.toNamed(
  //       Routes.mealCheckin,
  //       arguments: {
  //         "studentId": student["studentId"].toString(),
  //         "studentName": student["studentName"],
  //         "rollNo": student["rollNo"],
  //         "roomNo": student["roomNo"],
  //         "meal": selectedMeal.value,
  //       },
  //     );

  //     print("Navigation completed");
  //   } catch (e) {
  //     print("ERROR = $e");
  //   } finally {
  //     isLoading.value = false;
  //   }
  // }

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
        errorToast("No QR Code Found");
        return;
      }

      final qrCode = barcodes.first.rawValue;

      if (qrCode == null || qrCode.isEmpty) {
        errorToast("Invalid QR Code");
        return;
      }

      print("QR FROM IMAGE");
      print(qrCode);

      await handleScannedData(qrCode);
    } catch (e) {
      print(e);
      errorToast("Unable to read QR Image");
    }
  }

  @override
  void onClose() {
    scannerController.dispose();
    super.onClose();
  }
}
