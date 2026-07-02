import 'package:get/get.dart';

import '../../models/mess/mess_dashboard_model.dart';

class MessDashboardController extends GetxController {
  RxString selectedHostel = "Happy Homes".obs;

  Rx<DateTime> selectedDate = DateTime.now().obs;

  final hostels = [
    "Happy Homes",
    "Hostel A",
    "Hostel B",
  ];

  RxInt breakfast = 180.obs;
  RxInt lunch = 185.obs;
  RxInt dinner = 175.obs;
  RxInt sickDiet = 8.obs;

  RxInt totalAttendance = 190.obs;
  RxInt outPass = 10.obs;
  RxInt sickStudents = 8.obs;

  RxList<ForecastRecord> forecastRecords = <ForecastRecord>[].obs;

  @override
  void onInit() {
    super.onInit();

    loadDummyData();
  }

  void loadDummyData() {
    forecastRecords.assignAll([
      ForecastRecord(
        hostelName: "Happy Homes",
        breakfast: 180,
        lunch: 185,
        dinner: 175,
      ),
      ForecastRecord(
        hostelName: "Hostel A",
        breakfast: 90,
        lunch: 95,
        dinner: 88,
      ),
    ]);
  }

  void recalculateMeals() {
    Get.snackbar(
      "Success",
      "Meals recalculated successfully",
    );
  }

  void printForecast() {
    Get.snackbar(
      "Print",
      "Printing Forecast...",
    );
  }

  void sendKitchen() {
    Get.snackbar(
      "Success",
      "Forecast sent to Kitchen",
    );
  }
}
