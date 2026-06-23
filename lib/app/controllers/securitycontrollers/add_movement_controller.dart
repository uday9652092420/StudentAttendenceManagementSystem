import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_new_app/app/helpers/flutter_toast.dart';

import 'package:my_new_app/app/models/security/saved_movement_detiles.dart';
import 'package:my_new_app/app/routes/app_routes.dart';

import '../../models/security/gate_pass_details_model.dart';
import 'package:dio/dio.dart';

import 'package:intl/intl.dart';
import '../../repositories/security/movement_repository.dart';

import 'package:my_new_app/app/helpers/shared_preferences.dart';

class AddMovementController extends GetxController {
  final GatePassRepository repository = GatePassRepository();
  RxBool isLoading = false.obs;

  Rxn<GatePassDetailsModel> gatePass = Rxn<GatePassDetailsModel>();

  final TextEditingController outNotesController = TextEditingController();

  final TextEditingController returnNotesController = TextEditingController();

  String gatePassId = "";

  Rxn<MovementDetailsModel> movement = Rxn<MovementDetailsModel>();

  String loggedInSecurityName = "";

  bool get isFirstScan {
    return !(movement.value?.outConfirmed ?? false);
  }

  bool get isSecondScan {
    return (movement.value?.outConfirmed ?? false) &&
        !(movement.value?.returnConfirmed ?? false);
  }

  bool get isThirdScan {
    return (movement.value?.outConfirmed ?? false) &&
        (movement.value?.returnConfirmed ?? false);
  }

  // Security Guards
  final TextEditingController outSecurityGuardController =
      TextEditingController();

  final TextEditingController returnSecurityGuardController =
      TextEditingController();
  final outDateController = TextEditingController();
  final returnDateController = TextEditingController();
// Checkboxes
  RxBool confirmStudentLeft = false.obs;
  RxBool confirmStudentReturned = false.obs;

  String formatMovementDateTime(String? dateTime) {
    if (dateTime == null || dateTime.isEmpty) {
      return "-";
    }

    try {
      final dt = DateTime.parse(
        dateTime.replaceFirst(" ", "T"),
      );

      return DateFormat(
        "dd MMM yyyy • hh:mm a",
      ).format(dt);
    } catch (e) {
      return dateTime;
    }
  }

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments;

    gatePassId = args.toString();

    initData();
  }

  Future<void> initData() async {
    await loadLoggedInSecurity();

    print("LOGGED SECURITY => $loggedInSecurityName");

    await loadGatePassDetails();
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

        if (gatePass.value?.movementId != null &&
            gatePass.value!.movementId!.isNotEmpty) {
          await loadExistingMovement();
        } else {
          // First Scan

          outSecurityGuardController.text = loggedInSecurityName;

          returnSecurityGuardController.clear();

          confirmStudentLeft.value = false;

          confirmStudentReturned.value = false;
        }
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

        successToast("Out Movement Saved");

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

  Future<void> loadLoggedInSecurity() async {
    loggedInSecurityName = await SharedPrefsHelper.getString("fullName") ?? "";

    print("LOGGED SECURITY => $loggedInSecurityName");
  }

  Future<void> createOutMovement() async {
    try {
      final data = gatePass.value!;

      final now = DateFormat(
        "yyyy-MM-dd HH:mm:ss",
      ).format(DateTime.now());

      final body = {
        "gatePassId": data.gatePassId,
        "hostelAdmissionId": data.hostelAdmissionId,
        "studentId": data.studentId,
        "studentName": data.studentName,
        "roomNo": data.roomNo,
        "courseName": data.courseName,
        "gatePassNo": data.gatePassNo,
        "outConfirmed": true,
        "outConfirmedAt": now,
        "outSecurityGuard": outSecurityGuardController.text.trim(),
      };

      final response = await repository.saveMovement(body);

      print("STATUS => ${response?.statusCode}");
      print("RESPONSE => ${response?.data}");

      if (response != null &&
          response.statusCode == 200 &&
          response.data["success"] == true) {
        final movementData = response.data["data"];

        if (movementData != null) {
          gatePass.value?.movementId = movementData["id"]?.toString();
        }

        successToast(
          response.data["message"] ?? "Exit Movement Saved",
        );

        // Go back to scanner/dashboard
        Get.offAllNamed(Routes.securityDashboard);
      } else {
        errorToast(
          response?.data["message"] ?? "Failed to save Exit Movement",
        );
      }
    } on DioException catch (e) {
      print("DIO STATUS => ${e.response?.statusCode}");
      print("DIO DATA => ${e.response?.data}");

      errorToast(
        e.response?.data?["message"]?.toString() ?? "Server Error",
      );
    } catch (e) {
      print("CREATE OUT MOVEMENT ERROR => $e");
      errorToast("Something went wrong");
    }
  }
//cretae out movement
  // Future<void> createOutMovement() async {
  //   try {
  //     final data = gatePass.value!;

  //     final now = DateFormat(
  //       "yyyy-MM-dd HH:mm:ss",
  //     ).format(DateTime.now());

  //     final body = {
  //       "gatePassId": data.gatePassId,
  //       "hostelAdmissionId": data.hostelAdmissionId,
  //       "studentId": data.studentId,
  //       "studentName": data.studentName,
  //       "roomNo": data.roomNo,
  //       "courseName": data.courseName,
  //       "gatePassNo": data.gatePassNo,
  //       "outConfirmed": true,
  //       "outConfirmedAt": now,
  //       "outSecurityGuard": outSecurityGuardController.text.trim(),
  //     };

  //     final response = await repository.saveMovement(body);

  //     print("STATUS => ${response?.statusCode}");
  //     print("RESPONSE => ${response?.data}");

  //     if (response?.data["success"] == true) {
  //       final movementData = response?.data["data"];

  //       if (movementData != null) {
  //         gatePass.value?.movementId = movementData["id"]?.toString();
  //       }

  //       successToast("Exit Movement Saved");

  //       // Reload movement immediately
  //       await loadGatePassDetails();

  //       update();
  //       gatePass.refresh();
  //       movement.refresh();
  //     }
  //   } catch (e) {
  //     errorToast(e.toString());
  //   }
  // }

  Future<void> loadExistingMovement() async {
    try {
      final movementId = gatePass.value?.movementId;

      if (movementId == null || movementId.isEmpty) {
        return;
      }

      final response = await repository.getMovementDetails(movementId);

      print("MOVEMENT RESPONSE => ${response?.data}");

      if (response != null &&
          response.statusCode == 200 &&
          response.data["success"] == true) {
        final movementData = response.data["data"];

        movement.value = MovementDetailsModel.fromJson(movementData);

        final outDone = movement.value?.outConfirmed ?? false;

        final returnDone = movement.value?.returnConfirmed ?? false;

        // FIRST SCAN
        if (!outDone) {
          outSecurityGuardController.text = loggedInSecurityName;

          returnSecurityGuardController.clear();
        }

        // SECOND SCAN
        else if (outDone && !returnDone) {
          outSecurityGuardController.text =
              movement.value?.outSecurityGuard ?? "";

          // Logged user should appear automatically
          returnSecurityGuardController.text = loggedInSecurityName;
        }

        // THIRD SCAN
        else {
          outSecurityGuardController.text =
              movement.value?.outSecurityGuard ?? "";

          returnSecurityGuardController.text =
              movement.value?.returnSecurityGuard ?? "";
        }

        confirmStudentLeft.value = movementData["outConfirmed"] ?? false;

        confirmStudentReturned.value = movementData["returnConfirmed"] ?? false;

        gatePass.value?.outConfirmed = movementData["outConfirmed"] ?? false;

        gatePass.value?.returnConfirmed =
            movementData["returnConfirmed"] ?? false;

        gatePass.value?.outConfirmedAt = movementData["outConfirmedAt"];

        gatePass.value?.returnConfirmedAt = movementData["returnConfirmedAt"];

        outDateController.text = movement.value?.outConfirmedAt ?? "";

        returnDateController.text = movement.value?.returnConfirmedAt ?? "";

        print("Logged User => $loggedInSecurityName");
        print(
            "Return Guard Controller => ${returnSecurityGuardController.text}");

        gatePass.refresh();
        movement.refresh();
        update();
      }
    } catch (e) {
      print("LOAD MOVEMENT ERROR => $e");
    }
  }

//update return movement
  Future<void> updateReturnMovement() async {
    try {
      final data = gatePass.value!;

      final now = DateFormat(
        "yyyy-MM-dd HH:mm:ss",
      ).format(DateTime.now());

      if (data.movementId == null || data.movementId!.isEmpty) {
        errorToast("Movement ID not found");
        return;
      }

      final body = {
        "returnConfirmed": true,
        "returnSecurityGuard": returnSecurityGuardController.text.trim(),
        "returnConfirmedAt": now,
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
