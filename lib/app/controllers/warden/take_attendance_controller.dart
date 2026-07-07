import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:my_new_app/app/models/warden/HostelBlockModel.dart';
import 'package:my_new_app/app/models/warden/HostelFloorModel.dart';
import 'package:my_new_app/app/models/warden/take_attendance_model.dart';
import 'package:my_new_app/app/repositories/wardenattendance/warden_repository.dart';

class TakeAttendanceController extends GetxController {
  final repository = WardenRepository();

  RxString blockId = "".obs;
  RxString blockName = "".obs;

  RxString selectedFloorId = "".obs;
  RxString floorName = "".obs;
  RxBool isSaving = false.obs;

  RxList<HostelFloorModel> floors = <HostelFloorModel>[].obs;

  RxList<StudentAttendanceModel> students = <StudentAttendanceModel>[].obs;

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments as Map<String, dynamic>;

    blockId.value = args["blockId"] ?? "";
    blockName.value = args["blockName"] ?? "";

    selectedFloorId.value = args["floorId"] ?? "";
    floorName.value = args["floorName"] ?? "";

    loadBlockFloors();
  }

  Future<void> loadBlockFloors() async {
    final response = await repository.getBlocksStructure();

    if (response == null || response.statusCode != 200) return;

    final List list = response.data;

    final block = list.firstWhere(
      (e) => e["id"] == blockId.value,
    );

    floors.assignAll(
      (block["floors"] as List)
          .map((e) => HostelFloorModel.fromJson(e))
          .toList(),
    );
    if (selectedFloorId.value.isEmpty && floors.isNotEmpty) {
      selectedFloorId.value = floors.first.id;
      floorName.value = floors.first.floorLabel;
    }

    await loadStudents();
  }

  Future<void> loadStudents() async {
    students.clear();

    final attendanceDate = DateTime.now().subtract(const Duration(days: 1));

    final date = DateFormat("yyyy-MM-dd").format(attendanceDate);

    final response = await repository.getFloorAttendance(
      buildingId: blockId.value,
      floorId: selectedFloorId.value,
      date: date,
    );

    if (response == null) return;

    if (response.data == null) {
      students.clear();
      return;
    }

    final data = response.data;

    if (data["entries"] == null) {
      students.clear();
      return;
    }
    print(response.data);

    print(response.data["entries"]);

    final List entries = data["entries"];
    students.assignAll(
      entries.map<StudentAttendanceModel>((e) {
        return StudentAttendanceModel(
          hostelAdmissionId: e["hostel_admission_id"]?.toString() ?? "",
          roomId: e["room_id"]?.toString() ?? "",
          studentId: e["student_id"]?.toString() ?? "",
          rollNo: e["student_code"]?.toString() ?? "",
          studentName: e["student_name"]?.toString() ?? "",
          roomNo: e["room_no"]?.toString() ?? "",
          bedNo: e["bed_no"]?.toString() ?? "",
          remarks: e["remarks"]?.toString() ?? "",
          status: _statusToUi(
            e["attendance_status"]?.toString() ?? "present",
          ),
        );
      }).toList(),
    );
  }

  String _statusToUi(String status) {
    switch (status.toLowerCase()) {
      case "present":
        return "Present";

      case "absent":
        return "Absent";

      case "leave":
        return "Leave";

      case "outpass":
        return "Out Pass";

      default:
        return "Present";
    }
  }

  String _statusToApi(String status) {
    switch (status) {
      case "Present":
        return "present";

      case "Absent":
        return "absent";

      case "Leave":
        return "leave";

      case "Out Pass":
        return "outpass";

      default:
        return "present";
    }
  }

  Future<void> changeFloor(String floorId) async {
    selectedFloorId.value = floorId;

    final floor = floors.firstWhere(
      (e) => e.id == floorId,
    );

    floorName.value = floor.floorLabel;

    selectedFloorId.value = floor.id;

    await loadStudents();
  }

  int get totalStudents => students.length;

  int get presentCount => students.where((e) => e.status == "Present").length;

  int get absentCount => students.where((e) => e.status == "Absent").length;

  int get leaveCount => students.where((e) => e.status == "Leave").length;

  int get outPassCount => students.where((e) => e.status == "Out Pass").length;
  Future<void> saveAttendance() async {
    if (isSaving.value) return;

    isSaving.value = true;

    try {
      final body = {
        "attendanceDate": DateFormat("yyyy-MM-dd").format(DateTime.now()),
        "buildingId": blockId.value,
        "floorId": selectedFloorId.value,
        "entries": students.map((student) {
          return {
            "hostelAdmissionId": student.hostelAdmissionId,
            "studentId": student.studentId,
            "studentCode": student.rollNo,
            "studentName": student.studentName,
            "roomId": student.roomId,
            "roomNo": student.roomNo,
            "bedNo": student.bedNo,
            "attendanceStatus": _statusToApi(student.status),
            "remarks": student.remarks.isEmpty ? null : student.remarks,
            "biometricStatus": "manual",
            "biometricTime": null,
          };
        }).toList(),
      };

      final response = await repository.saveAttendance(body);

      if (response != null &&
          (response.statusCode == 200 || response.statusCode == 201)) {
        Get.snackbar(
          "Success",
          "Attendance Saved Successfully",
          snackPosition: SnackPosition.BOTTOM,
        );

        Get.back(result: true);
      } else {
        Get.snackbar(
          "Error",
          response?.data?["message"] ?? "Failed to save attendance",
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } finally {
      isSaving.value = false;
    }
  }
}
