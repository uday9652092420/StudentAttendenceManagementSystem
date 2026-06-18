import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:my_new_app/app/models/warden/warden_attendance_dashboard_model.dart';

class WardenAttendanceDashboardController extends GetxController {
  RxBool isLoading = false.obs;

  RxString selectedHostel = "Happy Homes".obs;

  Rx<DateTime> selectedDate = DateTime.now().obs;

  Rxn<WardenAttendanceDashboardModel> dashboard =
      Rxn<WardenAttendanceDashboardModel>();

  @override
  void onInit() {
    super.onInit();

    loadDashboard();
  }

  Future<void> loadDashboard() async {
    isLoading.value = true;

    await Future.delayed(
      const Duration(seconds: 1),
    );

    dashboard.value = WardenAttendanceDashboardModel.fromJson({
      "present": 2,
      "absent": 0,
      "leave": 0,
      "outPass": 0,
      "floors": [
        {
          "floorName": "Level 1",
          "totalStudents": 1,
          "present": 1,
          "absent": 0,
          "leave": 0,
          "outPass": 0,
          "session": "locked"
        },
        {
          "floorName": "Level 2",
          "totalStudents": 1,
          "present": 1,
          "absent": 0,
          "leave": 0,
          "outPass": 0,
          "session": "-"
        }
      ]
    });

    isLoading.value = false;
  }

  String get formattedDate =>
      DateFormat("dd/MM/yyyy").format(selectedDate.value);
}
