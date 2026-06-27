import 'package:dio/dio.dart';

class AttendanceRepository {
  final Dio dio = Dio();

  Future<Response?> getClassDetails(
    String classId,
  ) async {
    try {
      final response = await dio.get(
        "http://YOUR_IP:3002/api/classroom/class-details/$classId",
      );

      return response;
    } catch (e) {
      return null;
    }
  }
}
