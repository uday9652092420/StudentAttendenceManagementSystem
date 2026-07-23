import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:my_new_app/app/helpers/shared_preferences.dart';
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
  RxString loggedUserId = "".obs;

  final MasjidRepository repository = MasjidRepository();

  RxBool isLoading = false.obs;
  RxBool attendanceTaken = false.obs;

  /// Date & Time
  RxString currentDate = "".obs;
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

  RxInt presentCount = 0.obs;

  RxList<RecentStudent> recentStudents = <RecentStudent>[].obs;

  @override
  void onInit() {
    super.onInit();
    init();
  }

  Future<void> init() async {
    await loadLoggedUser();

    loadDateTime();
    autoPrayer();

    await loadAttendance();
  }

  Future<void> loadLoggedUser() async {
    loggedUserId.value = await SharedPrefsHelper.getString("userId");

    print("Logged User ID : ${loggedUserId.value}");
  }

  ///-------------------------------------------------------
  /// CHECK ATTENDANCE STATUS
  ///-------------------------------------------------------
  Future<void> loadAttendance() async {
    try {
      isLoading.value = true;

      final response = await repository.loadMasjidAttendance(
        date: DateFormat("yyyy-MM-dd").format(DateTime.now()),
        prayerType: selectedPrayer.value,
      );

      if (response != null && response.statusCode == 200) {
        print("LOAD RESPONSE => ${response.data}");

        if (response.data["attendanceTaken"] == true) {
          attendanceTaken.value = true;

          students.clear();
          filteredStudents.clear();

          Get.snackbar(
            "Attendance",
            response.data["message"] ?? "Attendance already taken",
          );
        } else {
          attendanceTaken.value = false;

          await getStudents();
        }
      }
    } catch (e) {
      print("LOAD ATTENDANCE ERROR => $e");

      Get.snackbar(
        "Error",
        "Failed to check attendance status",
      );
    } finally {
      isLoading.value = false;
    }
  }

  ///-------------------------------------------------------
  /// LOAD ALL STUDENTS
  ///-------------------------------------------------------
  Future<void> getStudents() async {
    try {
      isLoading.value = true;

      final response = await repository.getStudents();

      print("STUDENT RESPONSE => ${response?.data}");

      if (response != null && response.statusCode == 200) {
        final List data = response.data["data"] ?? [];

        students.assignAll(
          data.map((e) {
            final student = MasjidStudentModel.fromJson(e);

            student.isPresent.value = true;

            return student;
          }).toList(),
        );

        filteredStudents.assignAll(students);

        print("TOTAL STUDENTS LOADED => ${students.length}");
      }
    } catch (e) {
      print("GET STUDENTS ERROR => $e");

      Get.snackbar(
        "Error",
        "Failed to load students",
      );
    } finally {
      isLoading.value = false;
    }
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
      "prayerType": selectedPrayer.value,
      "takenByUserId": loggedUserId.value,
      "students": students
          .map(
            (e) => {
              "studentId": e.studentId,
              "studentName": e.studentName,
              "attendanceStatus": e.isPresent.value ? "Present" : "Absent",
            },
          )
          .toList(),
    };

    final response = await repository.saveMasjidAttendance(body);

    if (response != null &&
        (response.statusCode == 200 || response.statusCode == 201)) {
      attendanceTaken.value = true;

      Get.snackbar(
        "Success",
        "Attendance Saved Successfully",
      );
    }
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
