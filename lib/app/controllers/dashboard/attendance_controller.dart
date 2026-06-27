import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_new_app/app/helpers/flutter_toast.dart';
import 'package:my_new_app/app/models/dashboard/class_details_model.dart';
import 'package:my_new_app/app/models/dashboard/student_model.dart';
import 'package:my_new_app/app/repositories/teacherstundentattendance/attendance_repository.dart';

class AttendanceController extends GetxController {
  /// TEXT CONTROLLERS
  final TextEditingController courseController = TextEditingController();
  final TextEditingController classController = TextEditingController();

  /// REPOSITORY
  final AttendanceRepository repository = AttendanceRepository();

  /// CLASS DETAILS
  Rxn<ClassDetailsModel> classDetails = Rxn<ClassDetailsModel>();

  final TextEditingController periodController = TextEditingController();

  /// COUNTS
  RxInt presentCount = 0.obs;
  RxInt absentCount = 0.obs;
  RxInt totalStudents = 0.obs;

  RxBool isLoading = false.obs;

  /// STUDENTS
  RxList<StudentModel> students = <StudentModel>[].obs;

  /// Hostel Block
  RxString hostelName = "".obs;

  @override
  void onInit() {
    super.onInit();

    final Map<String, dynamic> args =
        (Get.arguments as Map<String, dynamic>?) ?? {};

    final String classId = args["classId"]?.toString() ?? "";

    hostelName.value = args["hostelName"]?.toString() ?? "";

    if (classId.isNotEmpty) {
      loadClassDetails(classId);
    }
  }

  Future<void> loadClassDetails(String classId) async {
    try {
      isLoading.value = true;

      final response = await repository.getClassDetails(classId);

      if (response != null &&
          response.statusCode == 200 &&
          response.data["success"] == true) {
        final model = ClassDetailsModel.fromJson(
          response.data["data"],
        );

        classDetails.value = model;

        courseController.text = model.courseName ?? "";

        classController.text = model.className ?? "";

        periodController.text = model.currentPeriodName ?? "";
        students.assignAll(
          List.generate(
            model.students.length,
            (index) => StudentModel(
              studentId: model.students[index].studentId ?? "",
              rollNo: "${index + 1}",
              name: model.students[index].studentName ?? "",
              status: "P",
            ),
          ),
        );

        calculateCounts();
      }
    } catch (e) {
      errorToast(
        "Failed to load class details",
      );
    } finally {
      isLoading.value = false;
    }
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

  Future<void> saveAttendance() async {
    try {
      final body = {
        "classId": classDetails.value?.classId,
        "periodId": classDetails.value?.currentPeriodId,
        "attendance": students.map((e) {
          return {
            "studentId": e.studentId,
            "status": e.status,
          };
        }).toList(),
      };

      print("ATTENDANCE BODY => $body");

      // final response = await repository.saveAttendance(body);

      successToast("Attendance Saved Successfully");
    } catch (e) {
      errorToast(e.toString());
    }
  }

  @override
  void onClose() {
    courseController.dispose();
    classController.dispose();
    super.onClose();
    periodController.dispose();
  }
}
