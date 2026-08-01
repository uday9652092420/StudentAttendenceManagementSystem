import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:my_new_app/app/helpers/flutter_toast.dart';
import 'package:my_new_app/app/repositories/kitchen/kitchen_repository.dart';

class MealCheckinController extends GetxController {
  final KitchenRepository repository = KitchenRepository();

  final studentIdController = TextEditingController();
  final studentCodeController = TextEditingController();
  final studentNameController = TextEditingController();
  final courseNameController = TextEditingController();
  final classNameController = TextEditingController();
  final mealController = TextEditingController();
  final dateController = TextEditingController();
  final timeController = TextEditingController();

  RxBool isSaving = false.obs;

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments ?? {};

    studentIdController.text = args["studentId"]?.toString() ?? "";

    studentCodeController.text = args["studentCode"]?.toString() ?? "";

    studentNameController.text = args["studentName"]?.toString() ?? "";

    courseNameController.text = args["courseName"]?.toString() ?? "";

    classNameController.text = args["className"]?.toString() ?? "";

    mealController.text = args["meal"]?.toString() ?? "";

    // Backend expects yyyy-MM-dd
    dateController.text = DateFormat("yyyy-MM-dd").format(DateTime.now());

    // Backend accepts this format
    timeController.text = DateFormat("HH:mm").format(DateTime.now());
    print("Meal Type = ${mealController.text}");
  }

  Future<void> saveMeal() async {
    try {
      isSaving.value = true;

      final body = {
        "currentDate": dateController.text,
        "currentTime": timeController.text,
        "studentId": studentIdController.text,
        "studentCode": studentCodeController.text,
        "studentName": studentNameController.text,
        "courseName": courseNameController.text,
        "className": classNameController.text,
        "mealType": mealController.text.toLowerCase(),
        "checkedInBy": "Kitchen Supervisor",
        "source": "mobile",
      };

      print(body);

      final response = await repository.saveMealAttendance(body);
      if (response != null &&
          (response.statusCode == 200 || response.statusCode == 201)) {
        Get.back(result: true);

        successToast(
          response.data["message"] ?? "Meal Attendance Saved",
        );
      } else {
        errorToast(
          response?.data["message"] ?? "Unable to Save",
        );
      }
    } catch (e) {
      errorToast(e.toString());
    } finally {
      isSaving.value = false;
    }
  }

  @override
  void onClose() {
    studentIdController.dispose();
    studentCodeController.dispose();
    studentNameController.dispose();
    courseNameController.dispose();
    classNameController.dispose();
    mealController.dispose();
    dateController.dispose();
    timeController.dispose();

    super.onClose();
  }
}
