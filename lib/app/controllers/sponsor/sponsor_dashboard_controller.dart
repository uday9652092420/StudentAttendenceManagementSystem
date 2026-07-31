import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_new_app/app/helpers/flutter_toast.dart';
import 'package:my_new_app/app/models/sponsor/sponsor_dashboard_response.dart';
import 'package:my_new_app/app/models/sponsor/sponsor_student_model.dart';
import 'package:my_new_app/app/repositories/sponsor/sponsordashboardrepository.dart';
import 'package:my_new_app/app/routes/app_routes.dart';
import 'package:my_new_app/app/theme/app_theme.dart';

class SponsorDashboardController extends GetxController {
  final SponsorRepository repository = SponsorRepository();

  final isLoading = false.obs;

  final dashboard = Rxn<SponsorDashboardResponse>();

  final students = <SponsorStudentModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    try {
      isLoading.value = true;

      final response = await repository.getDashboard();

      if (response != null && response.statusCode == 200) {
        dashboard.value = SponsorDashboardResponse.fromJson(response.data);

        students.assignAll(dashboard.value?.students ?? []);
      } else {
        errorToast(
          response?.data["message"]?.toString() ??
              "Failed to load sponsor dashboard.",
        );
      }
    } catch (e) {
      print("Sponsor Dashboard Error => $e");
      errorToast("Something went wrong.");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshDashboard() async {
    await loadDashboard();
  }

  void viewStudent(SponsorStudentModel student) {
    // Future Navigation
    // Get.toNamed(
    //   Routes.sponsorStudentProfile,
    //   arguments: student,
    // );

    successToast("Student profile will be available soon.");
  }

  void downloadReport() {
    successToast("Report download will be available soon.");
  }

  void logout() {
    _showLogoutDialog();
  }

  Future<void> _showLogoutDialog() async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: AppColors.bgLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: const Text(
          'Logout',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(color: Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.black87),
            ),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (result == true) {
      Get.offAllNamed(Routes.login);
    }
  }
}
