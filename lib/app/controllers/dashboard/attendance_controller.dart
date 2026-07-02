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

  RxString classId = "".obs;
  RxString periodId = "".obs;

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
    print("GET ARGUMENTS : ${Get.arguments}");

    final Map<String, dynamic> args =
        (Get.arguments as Map<String, dynamic>?) ?? {};
    final String classroomId = args["classroomId"]?.toString() ?? "";
    print("CLASSROOM ID = $classroomId");
    if (classroomId.isNotEmpty) {
      loadAttendanceData(classroomId);
    }
  }

  Future<void> loadAttendanceData(String classroomId) async {
    try {
      isLoading.value = true;

      const teacherId = "staff_1782898786845_qpk54f2yq";

      //-------------------------------
      // Context API
      //-------------------------------

      final contextResponse = await repository.getAttendanceContext(
        classroomId: classroomId,
        teacherId: teacherId,
      );

      print("STATUS = ${contextResponse?.statusCode}");
      print("BODY = ${contextResponse?.data}");

      if (contextResponse != null && contextResponse.statusCode == 200) {
        final data = contextResponse.data;

        if (data["success"] == true) {
          classId.value = data["classId"] ?? "";

          periodId.value = data["subjectId"] ?? "";

          courseController.text = data["courseName"] ?? "";

          classController.text = data["className"] ?? "";

          periodController.text =
              "Period ${data["periodNumber"]} • ${data["subjectName"]}";
        } else {
          courseController.clear();

          classController.clear();

          periodController.clear();

          courseController.clear();
          classController.clear();
          periodController.clear();

          students.clear();

          presentCount.value = 0;
          absentCount.value = 0;
          totalStudents.value = 0;

          errorToast(data["message"]);

          return;
        }
      }

      //-------------------------------
      // Students API
      //-------------------------------

      final studentResponse = await repository.getAttendanceStudents(
        classroomId: classroomId,
      );
      print(studentResponse?.statusCode);
      print(studentResponse?.data);

      if (studentResponse != null && studentResponse.statusCode == 200) {
        final List studentList = studentResponse.data as List;

// Sort alphabetically by student name
        studentList.sort(
          (a, b) => (a["studentName"] ?? "").toString().toLowerCase().compareTo(
                (b["studentName"] ?? "").toString().toLowerCase(),
              ),
        );

        students.assignAll(
          List.generate(studentList.length, (index) {
            final e = studentList[index];

            return StudentModel(
              studentId: e["studentId"].toString(),

              // Serial Number instead of Admission Number
              rollNo: (index + 1).toString(),

              name: e["studentName"] ?? "",

              status: e["status"] == "present" ? "P" : "A",
            );
          }),
        );

        calculateCounts();
      }
    } catch (e) {
      errorToast(
        e.toString(),
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
