import 'package:dio/dio.dart';
import 'package:my_new_app/app/services/api_service.dart';
import 'package:my_new_app/app/services/endpoints.dart';

class WardenRepository {
  Future<Response?> getBlocksStructure() async {
    return await ApiService.get(
      EndPoints.hostelblocksstructure,
    );
  }

  Future<Response?> getFloorAttendanceSummary({
    required String buildingId,
    required String floorId,
    required String date,
  }) async {
    return await ApiService.get(
      EndPoints.hostelFloorAttendance,
      queryParameters: {
        "buildingId": buildingId,
        "floorId": floorId,
        "date": date,
      },
    );
  }

  Future<Response?> getFloorAttendance({
    required String buildingId,
    required String floorId,
    required String date,
  }) async {
    return await ApiService.get(
      EndPoints.hostelFloorAttendance,
      queryParameters: {
        "buildingId": buildingId,
        "floorId": floorId,
        "date": date,
      },
    );
  }

  Future<Response?> getFloorStudents({
    required String buildingId,
    required String floorId,
  }) async {
    return await ApiService.get(
      "${EndPoints.floorwisestudents}$buildingId/$floorId",
    );
  }

  Future<Response<dynamic>?> saveAttendance(Map<String, dynamic> body) async {
    final response = await ApiService.post(
      EndPoints.saveAttendance,
      body,
    );
    return response;
  }
}
