import 'package:dio/dio.dart';
import 'package:my_new_app/app/services/api_service.dart';
import 'package:my_new_app/app/services/endpoints.dart';

class MasjidRepository {
  /// Get Attendance Sessions By Date
  Future<Response?> getAttendanceByDate(String date) async {
    return await ApiService.get(
      "${EndPoints.saveMasjidAttendance}?date=$date",
    );
  }

  /// Load Students
  Future<Response?> getStudents() async {
    return await ApiService.get(
      EndPoints.getStudents,
    );
  }

  /// Save Attendance
  Future<Response?> saveMasjidAttendance(Map<String, dynamic> body) async {
    return await ApiService.post(
      EndPoints.saveMasjidAttendance,
      body,
    );
  }
}
