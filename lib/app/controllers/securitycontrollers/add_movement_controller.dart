import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_new_app/app/helpers/flutter_toast.dart';
import 'package:my_new_app/app/models/security/movement_save_model.dart';

import '../../models/security/gate_pass_details_model.dart';
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
// both already completed
      if ((data.outConfirmed ?? false) && (data.returnConfirmed ?? false)) {
        errorToast("Both movements already completed");
        return;
      }

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
        "outConfirmed": confirmStudentLeft.value,
        "outSecurityGuard": outSecurityGuardController.text.trim(),
      };

      print("=================================");
      print(
          "POST URL => http://192.168.1.230:3002/api/hostel-in-out-movements");
      print("SAVE BODY => $body");
      print("=================================");

      final response = await repository.saveMovement(body);

      print("=================================");
      print("STATUS CODE => ${response?.statusCode}");
      print("SAVE RESPONSE => ${response?.data}");
      print("=================================");

      if (response == null) {
        errorToast("No response from server");
        return;
      }

      if (response.statusCode == 200 && response.data["success"] == true) {
        successToast(
          response.data["message"] ?? "Movement created successfully",
        );

        if (gatePass.value != null) {
          gatePass.value!.movementExists = true;
          gatePass.refresh();
        }

        Get.back(result: true);
      } else {
        errorToast(
          response.data["message"] ?? "Failed to save movement",
        );
      }
    } catch (e) {
      print("SAVE MOVEMENT ERROR => $e");
      errorToast(e.toString());
    } finally {
      isLoading.value = false;
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
