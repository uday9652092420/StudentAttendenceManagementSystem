import 'package:dio/dio.dart';
import 'package:my_new_app/app/services/api_service.dart';
import 'package:my_new_app/app/services/endpoints.dart';

class MasjidRepository {
  Future<Response?> getCourses() async {
    return await ApiService.get(EndPoints.masjidAttendanceCourses);
  }

  Future<Response?> getClasses(String courseId) async {
    return await ApiService.get(
      "${EndPoints.masjidAttendanceCourses}/$courseId/classes",
    );
  }

  Future<Response?> loadMasjidAttendance({
    required String date,
    required String prayerType,
    required String classId,
  }) async {
    return await ApiService.get(
      "${EndPoints.saveMasjidAttendance}/load",
      queryParameters: {
        "date": date,
        "prayerType": prayerType,
        "classId": classId,
      },
    );
  }

  Future<Response?> getAttendanceSessions() async {
    return await ApiService.get(EndPoints.masjidAttendanceSessions);
  }

  Future<Response?> getAttendanceSession(String sessionId) async {
    return await ApiService.get(
      "${EndPoints.masjidAttendanceSessions}/$sessionId",
    );
  }

  Future<Response?> saveMasjidAttendance(Map<String, dynamic> body) async {
    return await ApiService.post(
      EndPoints.saveMasjidAttendance,
      body,
    );
  }

  Future<Response?> updateMasjidAttendance(
    String sessionId,
    Map<String, dynamic> body,
  ) async {
    return await ApiService.put(
      "${EndPoints.masjidAttendanceSessions}/$sessionId",
      body,
    );
  }

  Future<Response?> deleteMasjidAttendance(String sessionId) async {
    return await ApiService.delete(
      "${EndPoints.masjidAttendanceSessions}/$sessionId",
    );
  }
}
