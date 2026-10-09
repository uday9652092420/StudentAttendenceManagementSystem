import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:my_new_app/app/controllers/dashboard/teacherattendance_controller.dart';
import 'package:my_new_app/app/helpers/flutter_toast.dart';
import 'package:my_new_app/app/models/dashboard/teacher_attendance_session_details_model.dart';
import 'package:my_new_app/app/repositories/teacherstundentattendance/attendance_repository.dart';

class TeacherAttendanceDetailsController extends GetxController {
  final AttendanceRepository repository = AttendanceRepository();

  final Rxn<TeacherAttendanceSessionDetails> details =
      Rxn<TeacherAttendanceSessionDetails>();
  final RxList<Map<String, dynamic>> studentAttendance =
      <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isCheckingOut = false.obs;
  final RxString errorMessage = "".obs;
  final RxString studentAttendanceError = "".obs;

  String sessionId = "";

  @override
  void onInit() {
    super.onInit();
    final arguments = Get.arguments;
    if (arguments is Map) {
      sessionId = arguments["sessionId"]?.toString().trim() ?? "";
    }

    debugPrint("Opening Attendance Details screen");
    debugPrint("Attendance Details sessionId: $sessionId");
    if (sessionId.isEmpty) {
      errorMessage.value =
          "Attendance session ID is missing. Return to the active session and try again.";
      return;
    }

    loadSessionDetails();
  }

  Future<void> loadSessionDetails() async {
    if (sessionId.isEmpty) {
      errorMessage.value = "Attendance session ID is missing.";
      return;
    }

    isLoading.value = true;
    errorMessage.value = "";
    studentAttendanceError.value = "";
    details.value = null;
    studentAttendance.clear();

    try {
      final response = await repository.getStaffAttendanceSession(
        sessionId: sessionId,
        rethrowErrors: true,
      );

      final body = response?.data;
      debugPrint("Attendance Details HTTP status: ${response?.statusCode}");
      debugPrint(
        "Attendance Details response keys: "
        "${body is Map ? body.keys.toList() : body.runtimeType}",
      );

      if (response == null) {
        throw const FormatException(
          "No response was received from the attendance service.",
        );
      }
      if (response.statusCode != 200) {
        throw SessionDetailsApiException(
          _readBackendMessage(body) ??
              "Failed to load attendance session details (HTTP ${response.statusCode}).",
        );
      }

      final parsed = TeacherAttendanceSessionDetails.fromResponse(
        body,
        requestedSessionId: sessionId,
      );
      details.value = parsed;
      debugPrint(
        "Attendance Details parsed: class=${parsed.className}, "
        "status=${parsed.status}, periods=${parsed.periods.length}, "
        "savedStudentAttendance=${parsed.savedStudentAttendance.length}",
      );

      if (parsed.hasSavedStudentAttendance) {
        studentAttendance.assignAll(parsed.savedStudentAttendance);
      } else {
        await _loadSavedStudentAttendance();
      }
    } on DioException catch (error) {
      final backendMessage = _readBackendMessage(error.response?.data);
      debugPrint(
        "Attendance Details DioException: type=${error.type}, "
        "statusCode=${error.response?.statusCode}, "
        "message=${_sanitize(backendMessage ?? error.message ?? error.toString())}",
      );
      errorMessage.value = backendMessage ??
          error.message ??
          "Unable to load attendance details. Check your connection and retry.";
    } catch (error) {
      final message = error is SessionDetailsApiException
          ? error.message
          : error.toString().replaceFirst("FormatException: ", "");
      debugPrint(
        "Attendance Details parsing/request error: ${_sanitize(message)}",
      );
      errorMessage.value = message;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadSavedStudentAttendance() async {
    try {
      final response = await repository.getStaffAttendanceSessionStudents(
        sessionId: sessionId,
      );
      debugPrint(
          "Saved student attendance HTTP status: ${response?.statusCode}");

      if (response == null || response.statusCode != 200) {
        studentAttendanceError.value = _readBackendMessage(response?.data) ??
            "Saved student attendance is not available from the server.";
        return;
      }

      if (response.data is Map && response.data["success"] == false) {
        studentAttendanceError.value = _readBackendMessage(response.data) ??
            "Saved student attendance is not available from the server.";
        return;
      }

      final rows = _findStudentRows(response.data);
      if (rows != null) {
        studentAttendance.assignAll(rows);
        debugPrint("Saved student attendance rows: ${rows.length}");
      }
    } on DioException catch (error) {
      final message = _readBackendMessage(error.response?.data) ??
          error.message ??
          "Saved student attendance is not available from the server.";
      studentAttendanceError.value = message;
      debugPrint(
        "Saved student attendance DioException: type=${error.type}, "
        "statusCode=${error.response?.statusCode}, "
        "message=${_sanitize(message)}",
      );
    } catch (error) {
      studentAttendanceError.value =
          "Unable to parse saved student attendance.";
      debugPrint(
        "Saved student attendance parsing error: ${_sanitize(error)}",
      );
    }
  }

  List<Map<String, dynamic>>? _findStudentRows(dynamic value) {
    if (value is List) {
      return value
          .whereType<Map>()
          .map((row) => Map<String, dynamic>.from(row))
          .toList();
    }
    if (value is Map) {
      for (final key in [
        "savedStudentAttendance",
        "students",
        "studentAttendance",
        "attendance",
      ]) {
        if (value[key] is List) {
          return (value[key] as List)
              .whereType<Map>()
              .map((row) => Map<String, dynamic>.from(row))
              .toList();
        }
      }
      final nested = value["data"];
      if (nested is Map || nested is List) {
        return _findStudentRows(nested);
      }
    }
    return null;
  }

  Future<void> checkOut() async {
    if (sessionId.isEmpty ||
        !Get.isRegistered<StaffAttendanceSessionController>()) {
      errorToast("The active attendance session is not available.");
      return;
    }

    isCheckingOut.value = true;
    try {
      await Get.find<StaffAttendanceSessionController>().checkOut();
      await loadSessionDetails();
    } finally {
      isCheckingOut.value = false;
    }
  }

  String? _readBackendMessage(dynamic value) {
    if (value is String && value.trim().isNotEmpty) return value.trim();
    if (value is Map) {
      for (final key in ["message", "error", "detail"]) {
        final message = value[key];
        if (message is String && message.trim().isNotEmpty) return message;
      }
      for (final key in ["data", "errors"]) {
        final nested = _readBackendMessage(value[key]);
        if (nested != null) return nested;
      }
    }
    return null;
  }

  String _sanitize(Object value) {
    return value
        .toString()
        .replaceAll(
          RegExp(
            r'(authorization|token|password)\s*[:=]\s*\S+',
            caseSensitive: false,
          ),
          '[REDACTED]',
        )
        .replaceAll(
          RegExp(r'\beyJ[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\b'),
          '[REDACTED]',
        );
  }
}
