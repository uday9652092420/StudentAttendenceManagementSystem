import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:my_new_app/app/repositories/kitchen/kitchen_repository.dart';

class MealCheckinController extends GetxController {
  final KitchenRepository repository = KitchenRepository();
  final studentIdController = TextEditingController();

  final studentNameController = TextEditingController();

  final mealController = TextEditingController();

  final dateController = TextEditingController();

  final timeController = TextEditingController();

  RxBool isSaving = false.obs;

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments;

    studentIdController.text = args["studentId"] ?? "";

    studentNameController.text = args["studentName"] ?? "";

    mealController.text = args["meal"] ?? "";

    dateController.text = DateFormat("dd-MM-yyyy").format(DateTime.now());

    timeController.text = DateFormat("hh:mm a").format(DateTime.now());
  }

  Future<void> saveMeal() async {
    try {
      isSaving.value = true;

      final body = {
        "studentId": studentIdController.text,
        "studentName": studentNameController.text,
        "mealType": mealController.text,
        "date": dateController.text,
        "time": timeController.text,
      };

      final response = await repository.saveMealAttendance(body);

      if (response != null &&
          (response.statusCode == 200 || response.statusCode == 201)) {
        Get.snackbar("Success", "Meal Attendance Saved");

        Get.back(result: true);
      } else {
        Get.snackbar(
          "Error",
          response?.data["message"] ?? "Unable to Save",
        );
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isSaving.value = false;
    }
  }
}
