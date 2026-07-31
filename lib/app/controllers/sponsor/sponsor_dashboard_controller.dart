import 'package:get/get.dart';
import 'package:my_new_app/app/helpers/flutter_toast.dart';
import 'package:my_new_app/app/models/sponsor/sponsor_dashboard_response.dart';
import 'package:my_new_app/app/models/sponsor/sponsor_student_model.dart';
import 'package:my_new_app/app/repositories/sponsor/sponsordashboardrepository.dart';
import 'package:my_new_app/app/routes/app_routes.dart';

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
    Get.defaultDialog(
      title: "Logout",
      middleText: "Are you sure you want to logout?",
      textConfirm: "Logout",
      textCancel: "Cancel",
      confirmTextColor: Get.theme.colorScheme.onPrimary,
      onConfirm: () {
        Get.back();
        Get.offAllNamed(Routes.login);
      },
    );
  }
}
