import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_new_app/app/models/warden/take_attendance_model.dart';

class TakeAttendanceController extends GetxController {
  RxString floorName = "".obs;
  RxString hostelName = "Happy Homes".obs;

  RxList<StudentAttendanceModel> students = <StudentAttendanceModel>[].obs;

  @override
  void onInit() {
    super.onInit();

    floorName.value = Get.arguments ?? "Level 1";

    loadStudents();
  }

  void loadStudents() {
    students.assignAll([
      StudentAttendanceModel(
        rollNo: "ADM-1779448457412",
        studentId: "216",
        studentName: "First Last",
        roomNo: "L2-1",
        bedNo: "Bed-1",
      ),
    ]);
  }

  int get totalStudents => students.length;

  int get presentCount => students.where((e) => e.status == "Present").length;

  int get absentCount => students.where((e) => e.status == "Absent").length;

  int get leaveCount => students.where((e) => e.status == "Leave").length;

  int get outPassCount => students.where((e) => e.status == "Out Pass").length;

  void saveAttendance() {
    Get.snackbar(
      "Success",
      "Attendance Saved Successfully",
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
