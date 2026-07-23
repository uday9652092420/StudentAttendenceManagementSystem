import 'package:get/get.dart';
import 'package:my_new_app/app/models/sponsor/sponsor_dashboard_model.dart';
import 'package:my_new_app/app/routes/app_routes.dart';

class SponsorDashboardController extends GetxController {
  /// Dashboard Summary
  final dashboard = SponsorDashboardModel(
    totalStudents: 4,
    averageAttendance: 93,
    averageExamScore: 87,
    kitchenUtilization: 96,
    mealsServed: "4,320",
    costCovered: "₹1,28,500",
    teacherRemarks:
        "Students are showing steady improvement in memorization and academic performance.",
    healthSummary:
        "All sponsored students are healthy and attending classes regularly.",
    overallRemarks:
        "Your sponsorship is making a significant positive impact in students' education and welfare.",
  ).obs;

  /// Sponsored Students
  final students = <SponsoredStudentModel>[
    SponsoredStudentModel(
      id: "STD001",
      name: "Ahmed Khan",
      program: "Hifz Program",
      attendance: 95,
      examScore: 89,
      discipline: "Excellent",
      hostel: "Resident",
    ),
    SponsoredStudentModel(
      id: "STD002",
      name: "Mohd Yusuf",
      program: "Alim Course",
      attendance: 91,
      examScore: 84,
      discipline: "Good",
      hostel: "Resident",
    ),
    SponsoredStudentModel(
      id: "STD003",
      name: "Salman Shaikh",
      program: "Nazra Program",
      attendance: 92,
      examScore: 86,
      discipline: "Good",
      hostel: "Day Scholar",
    ),
    SponsoredStudentModel(
      id: "STD004",
      name: "Ibrahim Ali",
      program: "Hifz Program",
      attendance: 94,
      examScore: 90,
      discipline: "Excellent",
      hostel: "Resident",
    ),
  ].obs;

  @override
  void onInit() {
    super.onInit();
    loadDashboard();
  }

  /// Future API Call
  void loadDashboard() {
    // TODO:
    // Call Sponsor Dashboard API
    // Update dashboard.value
    // Update students list
  }

  /// Download PDF
  void downloadReport() {
    Get.snackbar(
      "Download",
      "Sponsor report downloaded successfully.",
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  /// View Student
  void viewStudent(SponsoredStudentModel student) {
    Get.snackbar(
      student.name,
      "Profile screen will be available soon.",
      snackPosition: SnackPosition.BOTTOM,
    );

    // Future
    // Get.toNamed(
    //   Routes.sponsorStudentProfile,
    //   arguments: student,
    // );
  }

  /// Logout
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
