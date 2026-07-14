import 'package:dio/dio.dart';
import 'package:my_new_app/app/services/api_service.dart';

class KitchenRepository {
  /// Today's Meal Counts
  Future<Response?> getTodayMealCount() async {
    final response = await ApiService.get(
      "kitchen-dashboard/today-count",
    );

    return response as Response?;
  }

  /// Recent Scanned Students
  Future<Response?> getRecentScans() async {
    final response = await ApiService.get(
      "meal-attendance/recent",
    );

    return response as Response?;
  }

  /// Save Meal Attendance
  Future<Response?> saveMealAttendance(
    Map<String, dynamic> body,
  ) async {
    final response = await ApiService.post(
      "meal-attendance",
      body,
    );

    return response as Response?;
  }

  /// Get Student Details using QR Code
  Future<Response?> getStudentByQr(
    String qrCode,
  ) async {
    final response = await ApiService.get(
      "meal-attendance/student/$qrCode",
    );

    return response as Response?;
  }
}
