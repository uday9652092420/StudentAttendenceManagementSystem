import 'package:get/get.dart';
import 'package:intl/intl.dart';

class RecentStudent {
  final String studentId;
  final String studentName;

  RecentStudent({
    required this.studentId,
    required this.studentName,
  });
}

class MasjidDashboardController extends GetxController {
  /// Date
  RxString currentDate = "".obs;

  /// Time
  RxString currentTime = "".obs;

  /// Prayer
  RxString selectedPrayer = "Fajr".obs;

  final List<String> prayers = [
    "Fajr",
    "Zohar",
    "Asar",
    "Maghrib",
    "Isha",
  ];

  /// Today's Present Count
  RxInt presentCount = 0.obs;

  /// Recent Students
  RxList<RecentStudent> recentStudents = <RecentStudent>[].obs;

  @override
  void onInit() {
    super.onInit();

    loadDateTime();
    autoPrayer();

    // Dummy data
    presentCount.value = 0;

    recentStudents.assignAll([]);
  }

  void loadDateTime() {
    final now = DateTime.now();

    currentDate.value = DateFormat("dd MMM yyyy").format(now);

    currentTime.value = DateFormat("hh:mm a").format(now);
  }

  void autoPrayer() {
    final hour = DateTime.now().hour;

    if (hour >= 4 && hour < 8) {
      selectedPrayer.value = "Fajr";
    } else if (hour >= 12 && hour < 15) {
      selectedPrayer.value = "Zohar";
    } else if (hour >= 15 && hour < 18) {
      selectedPrayer.value = "Asar";
    } else if (hour >= 18 && hour < 20) {
      selectedPrayer.value = "Maghrib";
    } else {
      selectedPrayer.value = "Isha";
    }
  }

  void scanStudent() {
    // TODO
  }

  void uploadQr() {
    // TODO
  }

  void openStudentSearch() {
    // TODO
  }
}
