import 'package:dio/dio.dart';
import 'package:my_new_app/app/services/api_service.dart';
import 'package:my_new_app/app/services/endpoints.dart';

class KitchenRepository {
  // /// Today's Meal Counts
  // Future<Response?> getTodayMealCount() async {
  //   final response = await ApiService.get(
  //     "kitchen-dashboard/today-count",
  //   );

  //   return response as Response?;
  // }

  // /// Recent Scanned Students
  // Future<Response?> getRecentScans() async {
  //   final response = await ApiService.get(
  //     "meal-attendance/recent",
  //   );

  //   return response as Response?;
  // }

  Future<Response?> getDashboard() async {
    return await ApiService.get(
      EndPoints.kitchenDashboard,
    );
  }

  Future<Response?> saveMealAttendance(
    Map<String, dynamic> body,
  ) async {
    return await ApiService.post(
      "kitchen-meal-forecast/check-in",
      body,
    );
  }

  Future<Response?> getStudentByQr(
    String studentId,
  ) async {
    return await ApiService.get(
      "${EndPoints.kitchenStudentByQr}$studentId",
    );
  }
}
