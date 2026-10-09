import 'dart:convert';

import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';

import 'package:my_new_app/app/helpers/flutter_toast.dart';
import 'package:my_new_app/app/helpers/shared_preferences.dart';
import 'package:my_new_app/app/repositories/teacherstundentattendance/attendance_repository.dart';
import 'package:my_new_app/app/routes/app_routes.dart';

class DashboardController extends GetxController {
  final AttendanceRepository repository = AttendanceRepository();
  String? _pendingCheckInQrCode;
  String? _pendingCheckInRequestId;
  bool _isCheckingIn = false;

  String _getCheckInRequestId(String classroomId) {
    if (_pendingCheckInQrCode != classroomId ||
        _pendingCheckInRequestId == null) {
      _pendingCheckInQrCode = classroomId;
      _pendingCheckInRequestId =
          "checkin-${DateTime.now().microsecondsSinceEpoch}";
    }

    return _pendingCheckInRequestId!;
  }

  Future<void> retryCheckIn(String classroomId) async {
    final normalizedClassroomId = classroomId.trim();
    if (normalizedClassroomId.isEmpty) {
      errorToast("Classroom information is missing.");
      return;
    }
    _pendingCheckInQrCode = normalizedClassroomId;
    _pendingCheckInRequestId = null;
    await handleScannedData(jsonEncode({"id": normalizedClassroomId}));
  }

  String _readBackendMessage(dynamic body, String fallback) {
    if (body is String && body.trim().isNotEmpty) {
      return body.trim();
    }

    if (body is Map) {
      for (final key in ["message", "error", "detail"]) {
        final message = body[key];
        if (message is String && message.trim().isNotEmpty) {
          return message;
        }
      }

      for (final key in ["data", "errors"]) {
        final nestedMessage = _readBackendMessage(body[key], "");
        if (nestedMessage.isNotEmpty) {
          return nestedMessage;
        }
      }
    }

    return fallback;
  }

  Future<void> handleScannedData(String qrData) async {
    if (_isCheckingIn) return;
    _isCheckingIn = true;
    print("QR SCANNED");
    try {
      final Map<String, dynamic> data = jsonDecode(qrData);

      final String classroomId =
          (data["classroomId"] ?? data["classroom_id"] ?? data["id"])
                  ?.toString() ??
              "";

      if (classroomId.isEmpty) {
        errorToast("Invalid QR Code");
        return;
      }

      final String roleName =
          await SharedPrefsHelper.getString("roleName") ?? "";

      final String staffId = await SharedPrefsHelper.getString("staffId") ?? "";

      final role = roleName.toLowerCase();

      /// -------------------------------
      /// Teacher Flow
      /// -------------------------------
      if (role.contains("teacher") || role.contains("lecturer")) {
        if (staffId.isEmpty) {
          errorToast("Teacher information not found.");
          return;
        }
        await _checkInTeacher(classroomId);
        return;
      }

      /// -------------------------------
      /// Other Roles
      /// -------------------------------
      successToast("Successfully Scanned");

      Get.toNamed(
        Routes.studentAttendance,
        arguments: {
          "classroomId": classroomId,
        },
      );
    } catch (e) {
      print("QR ERROR => $e");
      errorToast("Invalid QR Code");
    } finally {
      _isCheckingIn = false;
    }
  }

  Future<void> _checkInTeacher(String classroomId) async {
    final requestId = _getCheckInRequestId(classroomId);
    try {
      final checkInResponse = await repository.checkInStaffAttendance(
        classroomId: classroomId,
        requestId: requestId,
      );
      final checkInBody = checkInResponse?.data;

      if (checkInResponse?.statusCode == 409 &&
          checkInBody is Map &&
          checkInBody["code"] == "CLASSROOM_SESSION_OPEN") {
        _openBlockedCheckIn(
            classroomId, Map<String, dynamic>.from(checkInBody));
        return;
      }
      if (checkInResponse == null ||
          checkInResponse.statusCode == null ||
          checkInResponse.statusCode! < 200 ||
          checkInResponse.statusCode! >= 300 ||
          checkInBody is! Map ||
          checkInBody["success"] != true) {
        errorToast(
          _readBackendMessage(checkInBody, "Unable to record teacher check-in"),
        );
        return;
      }

      final session = _unwrapMap(checkInBody["data"]);
      final sessionId = session["sessionId"]?.toString() ?? "";
      if (sessionId.isEmpty) {
        errorToast("Check-in response did not include a session ID.");
        return;
      }

      final alreadyCheckedIn = session["alreadyCheckedIn"] == true;
      final missingCheckout = session["missingCheckout"] == true;
      final restoreSession = alreadyCheckedIn || missingCheckout;
      dynamic sessionStudentsBody;
      if (!restoreSession) {
        final studentsResponse =
            await repository.getStaffAttendanceSessionStudents(
          sessionId: sessionId,
        );
        sessionStudentsBody = studentsResponse?.data;
        if (studentsResponse?.statusCode != 200 ||
            (sessionStudentsBody is Map &&
                sessionStudentsBody["success"] == false)) {
          errorToast(
            _readBackendMessage(
              sessionStudentsBody,
              "Unable to load teacher session attendance context.",
            ),
          );
          return;
        }
      }

      final scheduleItemId = _readScheduleItemId(session["currentPeriod"]) ??
          session["initialScheduleItemId"]?.toString() ??
          _readScheduleItemId(session["periods"]) ??
          _readScheduleItemId(sessionStudentsBody) ??
          "";
      if (!restoreSession && scheduleItemId.isEmpty) {
        errorToast("Timetable schedule item not found for this session.");
        return;
      }

      _pendingCheckInQrCode = null;
      _pendingCheckInRequestId = null;
      if (!restoreSession) successToast("Successfully Scanned");
      Get.toNamed(
        restoreSession
            ? Routes.staffAttendanceSession
            : Routes.studentAttendance,
        arguments: {
          "classroomId": classroomId,
          "sessionId": sessionId,
          "timetableScheduleItemId": scheduleItemId,
          "missingCheckout": missingCheckout,
          if (sessionStudentsBody != null)
            "sessionStudentsContext": sessionStudentsBody,
        },
      );
    } on dio.DioException catch (error) {
      final errorBody = error.response?.data;
      if (error.response?.statusCode == 409 &&
          errorBody is Map &&
          errorBody["code"] == "CLASSROOM_SESSION_OPEN") {
        _openBlockedCheckIn(classroomId, Map<String, dynamic>.from(errorBody));
        return;
      }
      errorToast(
        _readBackendMessage(
          errorBody,
          error.message ?? "Unable to record teacher check-in",
        ),
      );
    } catch (error) {
      errorToast(
          _readBackendMessage(error, "Unable to record teacher check-in"));
    }
  }

  Map<String, dynamic> _unwrapMap(dynamic value) {
    if (value is! Map) return {};
    dynamic current = value;
    for (var depth = 0; depth < 3; depth++) {
      if (current is Map && current["data"] is Map) {
        current = current["data"];
      } else if (current is Map && current["session"] is Map) {
        current = current["session"];
      } else {
        break;
      }
    }
    return current is Map ? Map<String, dynamic>.from(current) : {};
  }

  String? _readScheduleItemId(dynamic value) {
    if (value is List) {
      for (final period in value) {
        if (period is Map &&
            (period["isCurrent"] == true ||
                period["active"] == true ||
                period["status"]?.toString().toUpperCase() == "ACTIVE")) {
          final id = period["timetableScheduleItemId"] ??
              period["timetable_schedule_item_id"];
          if (id != null && id.toString().trim().isNotEmpty) {
            return id.toString();
          }
        }
      }
      return null;
    }
    final data = _unwrapMap(value);
    final direct = data["timetableScheduleItemId"] ??
        data["timetable_schedule_item_id"] ??
        data["initialScheduleItemId"];
    if (direct != null && direct.toString().trim().isNotEmpty) {
      return direct.toString();
    }
    final currentPeriod = data["currentPeriod"];
    if (currentPeriod is Map) {
      final id = currentPeriod["timetableScheduleItemId"] ??
          currentPeriod["timetable_schedule_item_id"];
      if (id != null && id.toString().trim().isNotEmpty) return id.toString();
    }
    final periods = data["periods"];
    if (periods is List) {
      for (final period in periods) {
        if (period is Map &&
            (period["isCurrent"] == true ||
                period["active"] == true ||
                period["status"]?.toString().toUpperCase() == "ACTIVE")) {
          final id = period["timetableScheduleItemId"] ??
              period["timetable_schedule_item_id"];
          if (id != null && id.toString().trim().isNotEmpty)
            return id.toString();
        }
      }
    }
    return null;
  }

  void _openBlockedCheckIn(
    String classroomId,
    Map<String, dynamic> response,
  ) {
    Get.toNamed(
      Routes.staffAttendanceBlocked,
      arguments: {
        "classroomId": classroomId,
        "response": response,
      },
    );
  }

  Future<void> pickQrFromGallery() async {
    try {
      final picker = ImagePicker();

      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
      );

      if (image == null) return;

      final inputImage = InputImage.fromFilePath(image.path);

      final barcodeScanner = BarcodeScanner();

      final barcodes = await barcodeScanner.processImage(inputImage);

      await barcodeScanner.close();

      if (barcodes.isEmpty) {
        errorToast("No QR Code found in image");
        return;
      }

      final qrCode = barcodes.first.rawValue;

      if (qrCode == null || qrCode.isEmpty) {
        errorToast("Invalid QR Code");
        return;
      }

      print("QR FROM GALLERY => $qrCode");

      await handleScannedData(qrCode);
    } catch (e) {
      print("QR GALLERY ERROR => $e");

      errorToast("Unable to read QR Code");
    }
  }
}
