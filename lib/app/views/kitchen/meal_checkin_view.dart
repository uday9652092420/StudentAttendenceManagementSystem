import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:my_new_app/app/controllers/kitchen/meal_checkin_controller.dart';

class MealCheckinView extends GetView<MealCheckinController> {
  const MealCheckinView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Meal Check-In",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blue,
        centerTitle: true,
        elevation: 0,
      ),
      body: Obx(
        () => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _textField(
                    "Date",
                    controller.dateController,
                    Icons.calendar_today,
                  ),
                  const SizedBox(height: 15),
                  _textField(
                    "Time",
                    controller.timeController,
                    Icons.access_time,
                  ),
                  const SizedBox(height: 15),
                  _textField(
                    "Meal Type",
                    controller.mealController,
                    Icons.restaurant,
                  ),
                  const SizedBox(height: 15),
                  _textField(
                    "Student ID",
                    controller.studentIdController,
                    Icons.badge,
                  ),
                  const SizedBox(height: 15),
                  _textField(
                    "Student Name",
                    controller.studentNameController,
                    Icons.person,
                  ),
                  const SizedBox(height: 15),
                  _textField(
                    "Course Name",
                    controller.courseNameController,
                    Icons.menu_book,
                  ),
                  const SizedBox(height: 15),
                  _textField(
                    "Class Name",
                    controller.classNameController,
                    Icons.class_,
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: controller.isSaving.value
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.save),
                      label: Text(
                        controller.isSaving.value
                            ? "Saving..."
                            : "Save Meal Check-In",
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: controller.isSaving.value
                          ? null
                          : () {
                              controller.saveMeal();
                            },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _textField(
    String label,
    TextEditingController controller,
    IconData icon,
  ) {
    return TextField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
