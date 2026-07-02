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

  /// Save Attendance
  Future<Response?> saveAttendance(
    Map<String, dynamic> body,
  ) async {
    final response = await ApiService.post(
      "attendance/periodwise/save",
      body,
    );

    return response as Response?;
  }
}
