import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
    try {
      isLoading.value = true;

      Get.snackbar(
        "Success",
        "Movement saved successfully",
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        e.toString(),
      );
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
