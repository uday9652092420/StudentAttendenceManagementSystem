import 'package:dio/dio.dart';
import 'package:my_new_app/app/services/api_service.dart';
import 'package:my_new_app/app/services/endpoints.dart';

class AttendanceRepository {
  /// Get Classroom Context
  Future<Response?> getAttendanceContext({
    required String classroomId,
    required String teacherId,
  }) async {
    final response = await ApiService.get(
      "${EndPoints.classroomdetails}$classroomId",
      queryParameters: {
        "teacherId": teacherId,
      },
    );

    return response as Response?;
  }

  /// Get Students
  Future<Response?> getAttendanceStudents({
    required String classroomId,
  }) async {
    final response = await ApiService.get(
      "${EndPoints.classroomstudentsdetails}$classroomId",
    );

    return response as Response?;
  }

  Future<Response?> checkInStaffAttendance({
    required String classroomId,
    required String requestId,
  }) async {
    final response = await ApiService.post(
      EndPoints.staffAttendanceCheckIn,
      {
        "classroomId": classroomId,
        "requestId": requestId,
      },
    );

    return response as Response?;
  }

  Future<Response?> getStaffAttendanceSessionStudents({
    required String sessionId,
  }) async {
    final response = await ApiService.get(
      "${EndPoints.staffAttendanceSessions}/$sessionId/students",
    );

    return response as Response?;
  }

  Future<Response?> saveAttendance({
    required String sessionId,
    required String requestId,
    required String timetableScheduleItemId,
    required List<Map<String, String>> students,
  }) async {
    final response = await ApiService.post(
      "${EndPoints.staffAttendanceStudentAttendance}/$sessionId/student-attendance",
      {
        "requestId": requestId,
        "timetableScheduleItemId": timetableScheduleItemId,
        "students": students,
      },
    );

    return response as Response?;
  }

  Future<Response?> recordStaffQrScan({
    required String classroomId,
    required String staffId,
  }) async {
    final response = await ApiService.post(
      EndPoints.staffPeriodAttendanceQrScan,
      {
        "classroomId": classroomId,
        "staffId": staffId,
      },
    );

    return response as Response?;
  }

  /// Get Teacher Attendance Session
  Future<Response?> getStaffAttendanceSession({
    required String sessionId,
  }) async {
    final response = await ApiService.get(
      "${EndPoints.staffAttendanceSessions}/$sessionId",
    );

    return response as Response?;
  }

  /// Teacher Check Out
  Future<Response?> checkOutStaffAttendance({
    required String sessionId,
    required String requestId,
  }) async {
    final response = await ApiService.post(
      "${EndPoints.staffAttendanceSessions}/$sessionId/check-out",
      {
        "requestId": requestId,
      },
    );

    return response as Response?;
  }

  /// Teacher Attendance History
  Future<Response?> getStaffAttendanceHistory({
    int page = 1,
    int limit = 20,
  }) async {
    final response = await ApiService.get(
      EndPoints.staffAttendanceSessionHistory,
      queryParameters: {
        "page": page,
        "limit": limit,
      },
    );

    return response as Response?;
  }
}
