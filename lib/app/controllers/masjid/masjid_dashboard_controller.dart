import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:my_new_app/app/models/masjid/studentmodel.dart';
import 'package:my_new_app/app/repositories/masjidattendance/masjid_attendance_repository.dart';

class RecentStudent {
  final String studentId;
  final String studentName;

  RecentStudent({
    required this.studentId,
    required this.studentName,
  });
}

class MasjidDashboardController extends GetxController {
  final MasjidRepository repository = MasjidRepository();
  RxBool isLoading = false.obs;

  /// Date
  RxString currentDate = "".obs;

  /// Time
  RxString currentTime = "".obs;

  /// Prayer
  RxString selectedPrayer = "Fajr".obs;

  final searchController = TextEditingController();

  RxList<MasjidStudentModel> students = <MasjidStudentModel>[].obs;

  RxList<MasjidStudentModel> filteredStudents = <MasjidStudentModel>[].obs;

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

    getStudents();
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

  Future<void> getStudents() async {
    try {
      isLoading.value = true;

      final response = await repository.getStudents();

      if (response != null && response.statusCode == 200) {
        final List data = response.data["data"];

        students.assignAll(
          data.map((e) {
            final student = MasjidStudentModel.fromJson(e);

            // Select all students by default
            student.isPresent.value = true;

            return student;
          }).toList(),
        );

        filteredStudents.assignAll(students);
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to load students",
      );
      print(e);
    } finally {
      isLoading.value = false;
    }
  }

  void searchStudent(String value) {
    if (value.isEmpty) {
      filteredStudents.assignAll(students);
      return;
    }

    filteredStudents.assignAll(
      students.where(
        (e) =>
            e.studentName.toLowerCase().contains(value.toLowerCase()) ||
            e.studentId.toLowerCase().contains(value.toLowerCase()),
      ),
    );
  }

  Future<void> saveAttendance() async {
    final selected = students.where((e) => e.isPresent.value).toList();

    if (selected.isEmpty) {
      Get.snackbar(
        "Error",
        "Select at least one student",
      );
      return;
    }

    final body = {
      "attendanceDate": DateFormat("yyyy-MM-dd").format(DateTime.now()),
      "attendanceTime": currentTime.value,
      "prayerType": selectedPrayer.value,
      "students": selected
          .map(
            (e) => {
              "studentId": e.studentId,
              "studentName": e.studentName,
            },
          )
          .toList(),
    };

    final response = await repository.saveMasjidAttendance(body);

    if (response != null &&
        (response.statusCode == 200 || response.statusCode == 201)) {
      Get.snackbar(
        "Success",
        "Attendance Saved",
      );

      for (var s in students) {
        s.isPresent.value = false;
      }
    }
  }

  // void scanStudent() {
  //   // TODO
  // }

  // void uploadQr() {
  //   // TODO
  // }
}
