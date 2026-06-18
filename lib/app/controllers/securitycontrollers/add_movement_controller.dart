import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_new_app/app/helpers/flutter_toast.dart';
import 'package:my_new_app/app/models/security/movement_save_model.dart';

import '../../models/security/gate_pass_details_model.dart';
import 'package:dio/dio.dart';
import '../../repositories/security/movement_repository.dart';

class AddMovementController extends GetxController {
  final GatePassRepository repository = GatePassRepository();
  RxBool isLoading = false.obs;

  Rxn<GatePassDetailsModel> gatePass = Rxn<GatePassDetailsModel>();

  final TextEditingController outNotesController = TextEditingController();

  final TextEditingController returnNotesController = TextEditingController();

  String gatePassId = "";

  // Security Guards
  final TextEditingController outSecurityGuardController =
      TextEditingController();

  final TextEditingController returnSecurityGuardController =
      TextEditingController();

// Checkboxes
  RxBool confirmStudentLeft = false.obs;
  RxBool confirmStudentReturned = false.obs;

  @override
  void onInit() {
    super.onInit();

    print("################################");
    print("ADD MOVEMENT CONTROLLER RUNNING");
    print("################################");

    final args = Get.arguments;

    print("GET ARGUMENTS => $args");
    print("ARGS TYPE => ${args.runtimeType}");

    gatePassId = args.toString();

    print("FINAL GATEPASS ID => $gatePassId");

    loadGatePassDetails();
  }

  Future<void> loadGatePassDetails() async {
    try {
      isLoading.value = true;

      print("CALLING API WITH => $gatePassId");

      final apiResponse = await repository.getGatePassDetails(
        gatePassId,
      );

      print("API RESPONSE => ${apiResponse?.data}");

      if (apiResponse != null &&
          apiResponse.statusCode == 200 &&
          apiResponse.data["success"] == true) {
        gatePass.value = GatePassDetailsModel.fromJson(
          apiResponse.data["data"],
        );
        final movement = gatePass.value!;

        outSecurityGuardController.text = movement.outSecurityGuard ?? "";

        returnSecurityGuardController.text = movement.returnSecurityGuard ?? "";

        confirmStudentLeft.value = movement.outConfirmed ?? false;

        confirmStudentReturned.value = movement.returnConfirmed ?? false;
        print(
          "API URL => hostel-in-out-movements/gate-pass-id/$gatePassId",
        );
        print("DATA LOADED SUCCESSFULLY");
      } else {
        print("API FAILED");
      }
    } catch (e) {
      print("LOAD GATE PASS ERROR => $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveMovement() async {
    print("====================================");
    print("SAVE BUTTON CLICKED");
    print("====================================");

    try {
      final data = gatePass.value;

      if (data == null) {
        errorToast("Gate Pass Data Missing");
        return;
      }

      // RETURN MOVEMENT
      if ((data.outConfirmed ?? false) && !(data.returnConfirmed ?? false)) {
        await updateReturnMovement();
        return;
      }

      // BOTH COMPLETED
      if ((data.outConfirmed ?? false) && (data.returnConfirmed ?? false)) {
        errorToast("Both movements already completed");
        return;
      }

      // OUT MOVEMENT VALIDATION
      if (!confirmStudentLeft.value) {
        errorToast("Please confirm student has left the hostel");
        return;
      }

      if (outSecurityGuardController.text.trim().isEmpty) {
        errorToast("Please enter Security Guard name");
        return;
      }

      isLoading.value = true;

      final body = {
        "gatePassId": data.gatePassId,
        "hostelAdmissionId": data.hostelAdmissionId,
        "studentId": data.studentId,
        "studentName": data.studentName,
        "roomNo": data.roomNo,
        "courseName": data.courseName,
        "gatePassNo": data.gatePassNo,
        "outConfirmed": true,
        "outSecurityGuard": outSecurityGuardController.text.trim(),
      };

      print("=================================");
      print("POST BODY => $body");
      print("=================================");

      final response = await repository.saveMovement(body);
      print("TYPE => ${response?.data.runtimeType}");
      print("DATA => ${response?.data}");
      print("STATUS => ${response?.statusCode}");
      print("RESPONSE => ${response?.data}");
      print("=================================");
      print("STATUS CODE => ${response?.statusCode}");
      print("SAVE RESPONSE => ${response?.data}");
      print("=================================");

      if (response != null &&
          response.statusCode == 200 &&
          response.data["success"] == true) {
        successToast(
          response.data["message"] ?? "Movement created successfully",
        );

        await loadGatePassDetails();

        Get.back(result: true);
      } else {
        errorToast(
          response?.data["message"] ?? "Failed to save movement",
        );
      }
    } on DioException catch (e) {
      print("=================================");
      print("DIO STATUS => ${e.response?.statusCode}");
      print("DIO DATA => ${e.response?.data}");
      print("=================================");

      String message = "Server Error";

      if (e.response?.data != null &&
          e.response!.data is Map &&
          e.response!.data["message"] != null) {
        message = e.response!.data["message"].toString();
      }

      errorToast(message);
    } catch (e) {
      print("GENERAL ERROR => $e");
      errorToast(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createOutMovement() async {
    try {
      final data = gatePass.value!;

      final body = {
        "gatePassId": data.gatePassId,
        "hostelAdmissionId": data.hostelAdmissionId,
        "studentId": data.studentId,
        "studentName": data.studentName,
        "roomNo": data.roomNo,
        "courseName": data.courseName,
        "gatePassNo": data.gatePassNo,
        "outConfirmed": true,
        "outSecurityGuard": outSecurityGuardController.text.trim(),
      };

      final response = await repository.saveMovement(body);

      print("STATUS => ${response?.statusCode}");
      print("RESPONSE => ${response?.data}");

      if (response?.data["success"] == true) {
        final movementData = response?.data["data"];

        if (movementData != null) {
          gatePass.value?.movementId = movementData["id"]?.toString();
        }
        successToast("Exit Movement Saved");

        await loadGatePassDetails();

        // Get.back(result: true);
      }
    } catch (e) {
      errorToast(e.toString());
    }
  }

  Future<void> updateReturnMovement() async {
    try {
      final data = gatePass.value!;

      if (data.movementId == null || data.movementId!.isEmpty) {
        errorToast("Movement ID not found");
        return;
      }

      final body = {
        "returnConfirmed": true,
        "returnSecurityGuard": returnSecurityGuardController.text.trim(),
      };

      print("PUT ID => ${data.movementId}");
      print("PUT BODY => $body");
      if (!confirmStudentReturned.value) {
        errorToast(
          "Please confirm student has returned",
        );
        return;
      }

      if (returnSecurityGuardController.text.trim().isEmpty) {
        errorToast(
          "Enter Return Security Guard",
        );
        return;
      }

      final response = await repository.updateMovement(
        data.movementId!,
        body,
      );

      print("PUT RESPONSE => ${response?.data}");

      if (response?.data["success"] == true) {
        successToast("Return Movement Saved");

        await loadGatePassDetails();

        Get.back(result: true);
      }
    } on DioException catch (e) {
      print("PUT STATUS => ${e.response?.statusCode}");
      print("PUT DATA => ${e.response?.data}");

      errorToast(
        e.response?.data?["message"]?.toString() ?? "Update Failed",
      );
    } catch (e) {
      errorToast(e.toString());
    }
  }

  @override
  void onClose() {
    outNotesController.dispose();
    returnNotesController.dispose();
    outSecurityGuardController.dispose();
    returnSecurityGuardController.dispose();
    super.onClose();
  }
}
