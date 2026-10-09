import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:my_new_app/app/helpers/flutter_toast.dart';
import 'package:my_new_app/app/repositories/teacherstundentattendance/attendance_repository.dart';
import 'package:my_new_app/app/routes/app_routes.dart';

class StaffAttendanceSessionController extends GetxController
    with WidgetsBindingObserver {
  final AttendanceRepository repository = AttendanceRepository();

  final RxBool isLoading = false.obs;
  final RxBool missingCheckout = false.obs;
  final RxBool studentAttendanceSaved = false.obs;

  final RxMap<String, dynamic> sessionData = <String, dynamic>{}.obs;

  String sessionId = "";
  String classroomId = "";
  String _currentScheduleItemId = "";
  bool _isCheckingOut = false;
  String? _checkoutRequestId;
  Timer? _refreshTimer;
  bool _isRefreshing = false;

  @override
  void onInit() {
    super.onInit();

    final Map<String, dynamic> args =
        (Get.arguments as Map<String, dynamic>?) ?? {};

    sessionId = args["sessionId"]?.toString() ?? "";
    classroomId = args["classroomId"]?.toString() ?? "";
    _currentScheduleItemId = args["timetableScheduleItemId"]?.toString() ?? "";
    missingCheckout.value = args["missingCheckout"] == true;
    studentAttendanceSaved.value = args["studentAttendanceSaved"] == true;

    if (sessionId.isEmpty) {
      WidgetsBinding.instance.addObserver(this);
      restoreCurrentSession();
      return;
    }

    WidgetsBinding.instance.addObserver(this);
    loadSession();
    _startRefreshTimer();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && sessionId.isNotEmpty) {
      loadSession(showErrors: false);
    }
  }

  Future<void> loadSession({bool showErrors = true}) async {
    if (_isRefreshing || sessionId.isEmpty) return;
    _isRefreshing = true;
    try {
      isLoading.value = true;

      final response = await repository.getStaffAttendanceSession(
        sessionId: sessionId,
      );

      if (response != null &&
          response.statusCode == 200 &&
          !(response.data is Map && response.data["success"] == false)) {
        final data = _unwrapSession(response.data);
        if (data != null) {
          sessionData.assignAll(data);
          missingCheckout.value = data["missingCheckout"] == true;
          if (_hasSavedStudentAttendance(data)) {
            studentAttendanceSaved.value = true;
          }
          if (data["checkedOutAt"] != null &&
                  data["checkedOutAt"].toString().isNotEmpty ||
              data["status"]?.toString().toUpperCase() == "CLOSED") {
            _refreshTimer?.cancel();
          }
          _maybeAdvanceToCurrentPeriod(data);
        } else {
          if (showErrors) errorToast("Invalid attendance session response.");
        }
      } else {
        if (showErrors) {
          errorToast(
            _getErrorMessage(
              response?.data,
              "Failed to load attendance session",
            ),
          );
        }
      }
    } catch (e) {
      if (showErrors) errorToast(e.toString());
    } finally {
      isLoading.value = false;
      _isRefreshing = false;
    }
  }

  Future<void> restoreCurrentSession() async {
    if (_isRefreshing) return;
    _isRefreshing = true;
    isLoading.value = true;
    try {
      final response = await repository.getCurrentStaffAttendanceSession(
        rethrowErrors: true,
      );
      final data = _unwrapSession(response?.data);
      if (response?.statusCode != 200 || data == null) {
        errorToast(
          _getErrorMessage(
              response?.data, "No active attendance session found."),
        );
        return;
      }
      sessionData.assignAll(data);
      sessionId = data["sessionId"]?.toString() ?? "";
      classroomId = (data["classroomId"] ?? data["classId"] ?? "").toString();
      _currentScheduleItemId = _readScheduleItemId(data["currentPeriod"]) ?? "";
      missingCheckout.value = data["missingCheckout"] == true;
      studentAttendanceSaved.value = _hasSavedStudentAttendance(data);
      if (sessionId.isEmpty) {
        errorToast("Current session response did not include a session ID.");
        return;
      }
      _startRefreshTimer();
      _maybeAdvanceToCurrentPeriod(data);
    } on DioException catch (error) {
      errorToast(
        _getErrorMessage(
          error.response?.data,
          error.message ?? "Unable to restore the active attendance session.",
        ),
      );
    } catch (error) {
      errorToast(error.toString());
    } finally {
      isLoading.value = false;
      _isRefreshing = false;
    }
  }

  void _startRefreshTimer() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 60),
      (_) => loadSession(showErrors: false),
    );
  }

  bool _hasSavedStudentAttendance(Map<String, dynamic> data) {
    for (final key in ["savedStudentAttendance", "studentAttendance"]) {
      if (data[key] is List && (data[key] as List).isNotEmpty) return true;
    }
    return false;
  }

  Future<bool> checkOut() async {
    if (sessionId.isEmpty) {
      errorToast("Attendance session not found.");
      return false;
    }
    if (_isCheckingOut) return false;

    _isCheckingOut = true;
    try {
      isLoading.value = true;

      _checkoutRequestId ??=
          "checkout-${DateTime.now().microsecondsSinceEpoch}";

      final response = await repository.checkOutStaffAttendance(
        sessionId: sessionId,
        requestId: _checkoutRequestId!,
      );

      if (response != null &&
          (response.statusCode == 200 || response.statusCode == 201) &&
          !(response.data is Map && response.data["success"] == false)) {
        _checkoutRequestId = null;
        _refreshTimer?.cancel();
        successToast("Checked out successfully");
        await loadSession();
        Get.offNamed(Routes.staffAttendanceHistory);
        return true;
      } else {
        errorToast(
          _getErrorMessage(
            response?.data,
            "Failed to check out",
          ),
        );
        return false;
      }
    } on DioException catch (error) {
      if (error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.sendTimeout ||
          error.type == DioExceptionType.connectionTimeout) {
        await loadSession();
        final checkedOutAt = sessionData["checkedOutAt"];
        if (checkedOutAt != null && checkedOutAt.toString().isNotEmpty) {
          _checkoutRequestId = null;
          _refreshTimer?.cancel();
          successToast("Checked out successfully");
          Get.offNamed(Routes.staffAttendanceHistory);
          return true;
        }
      }
      errorToast(
        _getErrorMessage(
            error.response?.data, error.message ?? "Failed to check out"),
      );
      return false;
    } catch (e) {
      errorToast(e.toString());
      return false;
    } finally {
      isLoading.value = false;
      _isCheckingOut = false;
    }
  }

  Map<String, dynamic>? _unwrapSession(dynamic response) {
    if (response is! Map) return null;
    dynamic value = response;
    if (value["data"] is Map) value = value["data"];
    if (value is Map && value["session"] is Map) value = value["session"];
    return value is Map ? Map<String, dynamic>.from(value) : null;
  }

  void _maybeAdvanceToCurrentPeriod(Map<String, dynamic> data) {
    final checkedOutAt = data["checkedOutAt"];
    if (classroomId.isEmpty ||
        missingCheckout.value ||
        data["missingCheckout"] == true ||
        data["status"]?.toString().toUpperCase() == "CLOSED" ||
        (checkedOutAt != null && checkedOutAt.toString().isNotEmpty)) {
      return;
    }

    final currentPeriodId = _readScheduleItemId(data["currentPeriod"]) ??
        _readActivePeriodId(data["periods"]);
    if (currentPeriodId == null || currentPeriodId.isEmpty) return;
    if (_currentScheduleItemId.isEmpty) {
      _currentScheduleItemId = currentPeriodId;
      return;
    }
    if (currentPeriodId == _currentScheduleItemId) return;

    _currentScheduleItemId = currentPeriodId;
    Get.offNamed(
      Routes.studentAttendance,
      arguments: {
        "classroomId": classroomId,
        "sessionId": sessionId,
        "timetableScheduleItemId": currentPeriodId,
      },
    );
  }

  String? _readScheduleItemId(dynamic period) {
    if (period is! Map) return null;
    final value = period["timetableScheduleItemId"] ??
        period["timetable_schedule_item_id"];
    if (value == null || value.toString().trim().isEmpty) return null;
    return value.toString();
  }

  String? _readActivePeriodId(dynamic periods) {
    if (periods is! List) return null;
    for (final period in periods) {
      if (period is Map &&
          (period["isCurrent"] == true ||
              period["active"] == true ||
              period["status"]?.toString().toUpperCase() == "ACTIVE")) {
        return _readScheduleItemId(period);
      }
    }
    return null;
  }

  String _getErrorMessage(
    dynamic data,
    String defaultMessage,
  ) {
    if (data is DioException) {
      return _getErrorMessage(
          data.response?.data, data.message ?? defaultMessage);
    }

    if (data is String && data.trim().isNotEmpty) {
      return data.replaceFirst("Exception: ", "").trim();
    }

    if (data is Map) {
      final message = data["message"] ?? data["error"] ?? data["detail"];

      if (message != null && message.toString().trim().isNotEmpty) {
        return message.toString();
      }

      for (final key in ["data", "errors"]) {
        final nestedMessage = _getErrorMessage(data[key], "");
        if (nestedMessage.isNotEmpty) return nestedMessage;
      }
    }

    return defaultMessage;
  }

  @override
  void onClose() {
    _refreshTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }
}
