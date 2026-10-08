import 'dart:convert';

import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';

import 'package:my_new_app/app/helpers/flutter_toast.dart';
import 'package:my_new_app/app/helpers/shared_preferences.dart';
import 'package:my_new_app/app/repositories/teacherstundentattendance/attendance_repository.dart';
import 'package:my_new_app/app/routes/app_routes.dart';
import 'package:my_new_app/app/services/endpoints.dart';

class DashboardController extends GetxController {
  final AttendanceRepository repository = AttendanceRepository();
  String? _pendingCheckInQrCode;
  String? _pendingCheckInRequestId;

  String _getCheckInRequestId(String classroomId) {
    if (_pendingCheckInQrCode != classroomId ||
        _pendingCheckInRequestId == null) {
      _pendingCheckInQrCode = classroomId;
      _pendingCheckInRequestId =
          "checkin-${DateTime.now().microsecondsSinceEpoch}";
    }

    return _pendingCheckInRequestId!;
  }

  String _findStringValue(dynamic value, String key) {
    if (value is Map) {
      final directValue = value[key];
      if (directValue != null && directValue.toString().trim().isNotEmpty) {
        return directValue.toString();
      }

      for (final nestedValue in value.values) {
        final result = _findStringValue(nestedValue, key);
        if (result.isNotEmpty) return result;
      }
    } else if (value is List) {
      for (final nestedValue in value) {
        final result = _findStringValue(nestedValue, key);
        if (result.isNotEmpty) return result;
      }
    }

    return "";
  }

  String _extractSessionId(dynamic value) {
    final sessionId = _findStringValue(value, "sessionId");
    if (sessionId.isNotEmpty) return sessionId;

    if (value is Map) {
      final session = value["session"];
      if (session is Map) {
        final nestedId = session["sessionId"] ?? session["id"];
        if (nestedId != null && nestedId.toString().trim().isNotEmpty) {
          return nestedId.toString();
        }
      }
    }

    return "";
  }

  String _readBackendMessage(dynamic body, String fallback) {
    if (body is Map) {
      final message = body["message"] ?? body["error"];
      if (message != null && message.toString().trim().isNotEmpty) {
        return message.toString();
      }
    }

    return fallback;
  }

  Future<void> handleScannedData(String qrData) async {
    print("QR SCANNED");
    try {
      final Map<String, dynamic> data = jsonDecode(qrData);

      final String classroomId = data["id"]?.toString() ?? "";

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

        final response = await repository.getAttendanceContext(
          classroomId: classroomId,
          teacherId: staffId,
        );

        if (response != null && response.statusCode == 200) {
          final body = response.data;

          if (body["success"] == true) {
            final requestId = _getCheckInRequestId(classroomId);
            final requestBody = {
              "classroomId": classroomId,
              "requestId": requestId,
            };
            print("Teacher check-in started");
            print("Scanned classroomId: $classroomId");
            print(
              "Teacher check-in endpoint: POST ${EndPoints.staffAttendanceCheckIn}",
            );
            print("Teacher check-in body: $requestBody");

            try {
              final checkInResponse = await repository.checkInStaffAttendance(
                classroomId: classroomId,
                requestId: requestId,
              );
              final checkInStatus = checkInResponse?.statusCode;
              final checkInBody = checkInResponse?.data;
              print("Teacher check-in status: $checkInStatus");
              print("Teacher check-in response: $checkInBody");

              if (checkInStatus == null ||
                  checkInStatus < 200 ||
                  checkInStatus >= 300 ||
                  checkInBody is! Map ||
                  checkInBody["success"] != true) {
                errorToast(
                  _readBackendMessage(
                    checkInBody,
                    "Unable to record teacher check-in",
                  ),
                );
                return;
              }

              final sessionId = _extractSessionId(checkInBody);
              if (sessionId.isEmpty) {
                errorToast("Check-in response did not include a session ID.");
                return;
              }
              print("Teacher sessionId: $sessionId");

              final sessionStudentsResponse =
                  await repository.getStaffAttendanceSessionStudents(
                sessionId: sessionId,
              );
              final sessionStudentsBody = sessionStudentsResponse?.data;
              print(
                "Session students status: ${sessionStudentsResponse?.statusCode}",
              );
              print("Session students response: $sessionStudentsBody");

              if (sessionStudentsResponse?.statusCode != 200) {
                errorToast(
                  _readBackendMessage(
                    sessionStudentsBody,
                    "Unable to load teacher session attendance context.",
                  ),
                );
                return;
              }

              final sessionScheduleItemId = _findStringValue(
                sessionStudentsBody,
                "timetableScheduleItemId",
              );

              if (sessionScheduleItemId.isEmpty) {
                errorToast(
                  "Timetable schedule item not found for this session.",
                );
                return;
              }

              _pendingCheckInQrCode = null;
              _pendingCheckInRequestId = null;
              successToast("Successfully Scanned");

              Get.toNamed(
                Routes.studentAttendance,
                arguments: {
                  "classroomId": classroomId,
                  "sessionId": sessionId,
                  "timetableScheduleItemId": sessionScheduleItemId,
                },
              );
            } catch (e) {
              print("TEACHER CHECK-IN ERROR => ${e.runtimeType}");
              errorToast("Unable to record teacher check-in");
            }
          } else {
            errorToast(body["message"] ?? "You are not assigned to this class");
          }
        } else {
          errorToast("Unable to verify classroom");
        }

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
    }
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
