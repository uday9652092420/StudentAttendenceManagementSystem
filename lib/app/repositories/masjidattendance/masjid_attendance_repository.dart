import 'package:dio/dio.dart';
import 'package:my_new_app/app/services/api_service.dart';
import 'package:my_new_app/app/services/endpoints.dart';

class MasjidRepository {
  Future<Response?> getStudents() async {
    return await ApiService.get(
      EndPoints.getStudents,
    );
  }

  Future<Response?> saveMasjidAttendance(Map<String, dynamic> body) async {
    return await ApiService.post(
      EndPoints.saveMasjidAttendance,
      body,
    );
  }
}
