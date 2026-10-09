import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_new_app/app/helpers/flutter_toast.dart';
import 'package:my_new_app/app/models/dashboard/class_details_model.dart';
import 'package:my_new_app/app/models/dashboard/student_model.dart';
import 'package:my_new_app/app/helpers/shared_preferences.dart';
import 'package:my_new_app/app/repositories/teacherstundentattendance/attendance_repository.dart';
import 'package:my_new_app/app/routes/app_routes.dart';
import 'package:my_new_app/app/services/endpoints.dart';

class AttendanceController extends GetxController {
  /// TEXT CONTROLLERS
  final TextEditingController courseController = TextEditingController();
  final TextEditingController classController = TextEditingController();

  /// REPOSITORY
  final AttendanceRepository repository = AttendanceRepository();

  /// CLASS DETAILS
  Rxn<ClassDetailsModel> classDetails = Rxn<ClassDetailsModel>();

  RxString classId = "".obs;
  RxString classroomId = "".obs;
  RxString sessionId = "".obs;
  RxString timetableScheduleItemId = "".obs;
  RxString periodId = "".obs;

  final TextEditingController periodController = TextEditingController();

  /// COUNTS
  RxInt presentCount = 0.obs;
  RxInt absentCount = 0.obs;
  RxInt sickCount = 0.obs;
  RxInt lateCount = 0.obs;
  RxInt totalStudents = 0.obs;

  static const List<String> _statusOrder = ["P", "A", "S", "L"];

  RxBool isLoading = false.obs;
  RxBool isSaving = false.obs;
  RxBool studentAttendanceReadOnly = false.obs;
  String? _pendingSaveRequestId;
  String? _pendingSavePayload;

  /// STUDENTS
  RxList<StudentModel> students = <StudentModel>[].obs;

  /// Hostel Block
  RxString hostelName = "".obs;

  RxString courseId = "".obs;
  RxString period = "".obs;
  RxString academicYear = "".obs;
  RxBool locked = false.obs;

  @override
  void onInit() {
    super.onInit();
    print("GET ARGUMENTS : ${Get.arguments}");

    final Map<String, dynamic> args =
        (Get.arguments as Map<String, dynamic>?) ?? {};

    final String classroomId = args["classroomId"]?.toString() ?? "";

    sessionId.value = args["sessionId"]?.toString() ?? "";
    timetableScheduleItemId.value =
        args["timetableScheduleItemId"]?.toString() ?? "";

    print("CLASSROOM ID = $classroomId");
    print("SESSION ID = ${sessionId.value}");

    if (classroomId.isNotEmpty) {
      loadAttendanceData(classroomId);
    }
  }

  Future<void> loadAttendanceData(String classroomId) async {
    this.classroomId.value = classroomId;
    if (sessionId.value.isNotEmpty) {
      await _loadSessionAttendanceData();
      return;
    }

    final teacherId = await SharedPrefsHelper.getString("staffId");

    if (teacherId.isEmpty) {
      errorToast("Teacher information not found.");
      return;
    }

    try {
      isLoading.value = true;

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

          courseId.value = data["courseId"] ?? "";

          timetableScheduleItemId.value =
              data["timetableScheduleItemId"]?.toString() ??
                  timetableScheduleItemId.value;

          academicYear.value = data["academicYear"] ?? "";

          locked.value = data["locked"] ?? false;

          period.value = "Period ${data["periodNumber"]}";
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
          sickCount.value = 0;
          lateCount.value = 0;
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

              status: normalizeStatus(e["status"]?.toString() ?? "P"),
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

  Future<void> _loadSessionAttendanceData() async {
    try {
      isLoading.value = true;
      final arguments = Get.arguments is Map ? Get.arguments as Map : {};
      dynamic context = arguments["sessionStudentsContext"];
      if (context == null) {
        final response = await repository.getStaffAttendanceSessionStudents(
          sessionId: sessionId.value,
        );
        if (response == null || response.statusCode != 200) {
          errorToast(_getSaveErrorMessage(response?.data));
          return;
        }
        context = response.data;
      }

      final data = _unwrapSessionContext(context);
      studentAttendanceReadOnly.value = _hasSavedAttendance(data);
      final requestedScheduleId =
          arguments["timetableScheduleItemId"]?.toString().trim() ?? "";
      timetableScheduleItemId.value =
          _findScheduleItemId(data) ?? requestedScheduleId;
      if (timetableScheduleItemId.value.isEmpty) {
        errorToast("Timetable schedule item not found for this session.");
        return;
      }

      classId.value = _findValue(data, ["classId", "class_id"]) ?? "";
      courseId.value = _findValue(data, ["courseId", "subjectId"]) ?? "";
      classController.text =
          _findValue(data, ["className", "classroomName", "class_name"]) ?? "";
      courseController.text =
          _findValue(data, ["subjectName", "courseName", "subject_name"]) ?? "";
      period.value = _findValue(data, ["periodNumber", "period_number"]) ?? "";
      periodController.text = _findPeriodLabel(data);

      final roster = _findSessionStudents(data);
      if (roster == null || roster.isEmpty) {
        students.clear();
        calculateCounts();
        errorToast("No students are available for this attendance session.");
        return;
      }

      final sortedRoster = [...roster]..sort((left, right) =>
          (left["studentName"] ?? left["name"] ?? "")
              .toString()
              .toLowerCase()
              .compareTo((right["studentName"] ?? right["name"] ?? "")
                  .toString()
                  .toLowerCase()));
      students.assignAll(
        List.generate(sortedRoster.length, (index) {
          final row = sortedRoster[index];
          return StudentModel(
            studentId:
                (row["studentId"] ?? row["student_id"] ?? row["id"] ?? "")
                    .toString(),
            rollNo: (row["studentCode"] ??
                    row["rollNo"] ??
                    row["student_code"] ??
                    index + 1)
                .toString(),
            name:
                (row["studentName"] ?? row["name"] ?? row["student_name"] ?? "")
                    .toString(),
            status: normalizeStatus(
              (row["status"] ?? row["attendanceStatus"] ?? "present")
                  .toString(),
            ),
          );
        }),
      );
      calculateCounts();
    } catch (error) {
      errorToast("Unable to load teacher session attendance context.");
    } finally {
      isLoading.value = false;
    }
  }

  Map<String, dynamic> _unwrapSessionContext(dynamic value) {
    dynamic current = value;
    for (var depth = 0; depth < 4; depth++) {
      if (current is Map && current["data"] is Map) {
        current = current["data"];
      } else if (current is Map && current["session"] is Map) {
        current = current["session"];
      } else {
        break;
      }
    }
    if (current is List) return {"students": current};
    return current is Map ? Map<String, dynamic>.from(current) : {};
  }

  bool _hasSavedAttendance(dynamic value) {
    if (value is Map) {
      if (value["attendanceSaved"] == true ||
          value["saved"] == true ||
          (value["savedStudentAttendance"] is List &&
              (value["savedStudentAttendance"] as List).isNotEmpty)) {
        return true;
      }
      return value.values.any(_hasSavedAttendance);
    }
    if (value is List) return value.any(_hasSavedAttendance);
    return false;
  }

  String? _findValue(dynamic value, List<String> keys) {
    if (value is Map) {
      for (final key in keys) {
        final found = value[key];
        if (found != null && found.toString().trim().isNotEmpty) {
          return found.toString();
        }
      }
      for (final nested in value.values) {
        final found = _findValue(nested, keys);
        if (found != null) return found;
      }
    } else if (value is List) {
      for (final nested in value) {
        final found = _findValue(nested, keys);
        if (found != null) return found;
      }
    }
    return null;
  }

  String? _findScheduleItemId(dynamic value) {
    if (value is Map) {
      final direct = value["timetableScheduleItemId"] ??
          value["timetable_schedule_item_id"] ??
          value["initialScheduleItemId"];
      if (direct != null && direct.toString().trim().isNotEmpty) {
        return direct.toString();
      }
      final currentPeriod = value["currentPeriod"];
      if (currentPeriod is Map) {
        final currentId = currentPeriod["timetableScheduleItemId"] ??
            currentPeriod["timetable_schedule_item_id"];
        if (currentId != null && currentId.toString().trim().isNotEmpty) {
          return currentId.toString();
        }
      }
      final periods = value["periods"];
      if (periods is List) {
        for (final periodData in periods) {
          if (periodData is Map &&
              (periodData["isCurrent"] == true ||
                  periodData["active"] == true ||
                  periodData["status"]?.toString().toUpperCase() == "ACTIVE")) {
            final currentId = periodData["timetableScheduleItemId"] ??
                periodData["timetable_schedule_item_id"];
            if (currentId != null && currentId.toString().trim().isNotEmpty) {
              return currentId.toString();
            }
          }
        }
      }
      for (final nested in value.values) {
        final found = _findScheduleItemId(nested);
        if (found != null) return found;
      }
    } else if (value is List) {
      for (final nested in value) {
        final found = _findScheduleItemId(nested);
        if (found != null) return found;
      }
    }
    return null;
  }

  String _findPeriodLabel(Map<String, dynamic> data) {
    final current = data["currentPeriod"];
    if (current is Map) {
      final periodName = current["period"] ??
          current["periodNumber"] ??
          current["period_number"];
      final subject = current["subject"] ?? current["subjectName"];
      if (periodName != null) {
        return "Period $periodName${subject == null ? "" : " • $subject"}";
      }
    }
    final number = _findValue(data, ["periodNumber", "period_number"]);
    final subject = _findValue(data, ["subjectName", "subject_name"]);
    if (number == null) return "Current period unavailable";
    return "Period $number${subject == null ? "" : " • $subject"}";
  }

  List<Map<String, dynamic>>? _findSessionStudents(dynamic value) {
    if (value is Map) {
      for (final key in ["students", "studentRoster", "roster"]) {
        if (value[key] is List) {
          return (value[key] as List)
              .whereType<Map>()
              .map((row) => Map<String, dynamic>.from(row))
              .toList();
        }
      }
      for (final nested in value.values) {
        final rows = _findSessionStudents(nested);
        if (rows != null) return rows;
      }
    } else if (value is List) {
      for (final nested in value) {
        final rows = _findSessionStudents(nested);
        if (rows != null) return rows;
      }
    }
    return null;
  }

  String normalizeStatus(String status) {
    switch (status.trim().toUpperCase()) {
      case "P":
      case "PRESENT":
        return "P";
      case "A":
      case "ABSENT":
        return "A";
      case "S":
      case "SICK":
        return "S";
      case "L":
      case "LATE":
      case "LEAVE":
        return "L";
      default:
        return "P";
    }
  }

  String toApiStatus(String status) {
    switch (normalizeStatus(status)) {
      case "P":
        return "present";
      case "A":
        return "absent";
      case "S":
        return "sick";
      case "L":
        return "leave";
      default:
        return "present";
    }
  }

  void toggleAttendance(int index) {
    final currentStatus = normalizeStatus(students[index].status);
    final currentIndex = _statusOrder.indexOf(currentStatus);
    final nextIndex = (currentIndex + 1) % _statusOrder.length;

    students[index].status = _statusOrder[nextIndex];

    students.refresh();
    calculateCounts();
  }

  void calculateCounts() {
    presentCount.value = students.where((e) => e.status == "P").length;
    absentCount.value = students.where((e) => e.status == "A").length;
    sickCount.value = students.where((e) => e.status == "S").length;
    lateCount.value = students.where((e) => e.status == "L").length;
    totalStudents.value = students.length;
  }

  Future<void> saveAttendance() async {
    if (isSaving.value) return;
    if (studentAttendanceReadOnly.value) {
      errorToast("Attendance for this period has already been saved.");
      return;
    }

    try {
      if (sessionId.value.isEmpty) {
        errorToast("Attendance session not found.");
        return;
      }

      if (timetableScheduleItemId.value.isEmpty) {
        errorToast("Timetable schedule item not found.");
        return;
      }

      if (students.isEmpty) {
        errorToast("No students are available to save.");
        return;
      }

      const allowedStatuses = {"present", "absent", "leave", "sick"};
      final attendanceStudents = <Map<String, String>>[];
      for (final student in students) {
        final studentId = student.studentId.trim();
        final status = toApiStatus(student.status);
        if (studentId.isEmpty || !allowedStatuses.contains(status)) {
          errorToast(
            "Every student must have an ID and valid attendance status.",
          );
          return;
        }

        attendanceStudents.add({
          "studentId": studentId,
          "status": status,
        });
      }

      final savePayload = {
        "timetableScheduleItemId": timetableScheduleItemId.value,
        "students": attendanceStudents,
      };
      final savePayloadKey = jsonEncode(savePayload);
      if (_pendingSaveRequestId == null ||
          _pendingSavePayload != savePayloadKey) {
        _pendingSaveRequestId =
            "attendance-save-${DateTime.now().microsecondsSinceEpoch}";
        _pendingSavePayload = savePayloadKey;
      }
      final requestId = _pendingSaveRequestId!;
      final requestBody = {"requestId": requestId, ...savePayload};
      final endpoint =
          "${EndPoints.staffAttendanceSessions}/${sessionId.value}/student-attendance";

      isSaving.value = true;
      print("SAVE BUTTON CLICKED");
      print("Session ID: ${sessionId.value}");
      print("Timetable schedule item ID: ${timetableScheduleItemId.value}");
      print("POST endpoint: $endpoint");
      print("POST body: ${jsonEncode(requestBody)}");

      final response = await repository.saveAttendance(
        sessionId: sessionId.value,
        requestId: requestId,
        timetableScheduleItemId: timetableScheduleItemId.value,
        students: attendanceStudents,
      );

      final responseBody = response?.data;
      print("Save attendance status: ${response?.statusCode}");
      print("Save attendance response: $responseBody");
      final backendRejected =
          responseBody is Map && responseBody["success"] == false;
      if (response != null &&
          (response.statusCode == 200 || response.statusCode == 201) &&
          !backendRejected) {
        _pendingSaveRequestId = null;
        _pendingSavePayload = null;
        successToast("Attendance Saved Successfully");

        if (sessionId.value.isEmpty) {
          errorToast("Attendance session not found.");
          return;
        }

        Get.offNamed(
          Routes.staffAttendanceSession,
          arguments: {
            "classroomId": classroomId.value,
            "sessionId": sessionId.value,
            "timetableScheduleItemId": timetableScheduleItemId.value,
            "studentAttendanceSaved": true,
          },
        );
      } else {
        errorToast(_getSaveErrorMessage(responseBody));
      }
    } catch (e) {
      print("Save attendance exception: ${e.runtimeType}");
      errorToast("Failed to save attendance. Please retry.");
    } finally {
      isSaving.value = false;
    }
  }

  String _getSaveErrorMessage(dynamic responseBody) {
    if (responseBody is Map) {
      final message = responseBody["message"] ?? responseBody["error"];
      if (message != null && message.toString().trim().isNotEmpty) {
        return message.toString();
      }
    }

    return "Failed to save attendance";
  }

  @override
  void onClose() {
    courseController.dispose();
    classController.dispose();
    super.onClose();
    periodController.dispose();
  }
}
