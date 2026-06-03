import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_new_app/app/helpers/flutter_toast.dart';
import 'package:my_new_app/app/models/dashboard/student_model.dart';

class AttendanceController extends GetxController {
  /// TEXT CONTROLLERS
  final TextEditingController courseController = TextEditingController();

  final TextEditingController classController = TextEditingController();

  /// PERIODS
  RxList<String> periods = <String>[].obs;

  RxString selectedPeriod = "".obs;

  /// COUNTS
  RxInt presentCount = 0.obs;
  RxInt absentCount = 0.obs;
//total students
  RxInt totalStudents = 0.obs;

  /// STUDENTS
  RxList<StudentModel> students = <StudentModel>[].obs;

  @override
  void onInit() {
    super.onInit();

    final data = Get.arguments ?? {};

    print("QR DATA ======> $data");

    /// COURSE NAME
    courseController.text = data["courseName"]?.toString() ?? "";

    /// CLASS NAME
    classController.text = data["className"]?.toString() ?? "";

    /// PERIOD
    final String qrPeriod = data["period"]?.toString() ?? "";

    periods.clear();

    if (qrPeriod.isNotEmpty) {
      periods.add(qrPeriod);

      selectedPeriod.value = qrPeriod;
    }

    /// STUDENTS
    final List<dynamic> studentList = data["students"] ?? [];

    students.assignAll(
      List.generate(studentList.length, (index) {
        final student = studentList[index];

        return StudentModel(
          /// AUTO GENERATED ROLL NUMBER
          rollNo: "${index + 1}",

          /// NAME FROM QR
          name: student["name"]?.toString() ?? "",

          /// DEFAULT STATUS
          status: "P",
        );
      }),
    );

    calculateCounts();
  }

  void toggleAttendance(int index) {
    if (students[index].status == "P") {
      students[index].status = "A";
    } else {
      students[index].status = "P";
    }

    students.refresh();

    calculateCounts();
  }

  void calculateCounts() {
    presentCount.value = students.where((e) => e.status == "P").length;

    absentCount.value = students.where((e) => e.status == "A").length;
    totalStudents.value = students.length;
  }

  void saveAttendance() {
    successToast("Attendance Saved Successfully");
  }

  @override
  void onClose() {
    courseController.dispose();

    classController.dispose();

    super.onClose();
  }
}
