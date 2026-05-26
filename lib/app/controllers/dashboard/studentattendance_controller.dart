import 'package:get/get.dart';
import 'package:my_new_app/app/helpers/flutter_toast.dart';
import 'package:my_new_app/app/models/dashboard/student_model.dart';

class StudentAttendanceController extends GetxController {
  var selectedPeriod = "Period 1".obs;

  List<String> periods = [
    "Period 1",
    "Period 2",
    "Period 3",
    "Period 4",
  ];

  var courseName = "(Aalimiyat) عالميت".obs;

  var className = "@2".obs;

  var students = <StudentModel>[].obs;

  var presentCount = 0.obs;

  var absentCount = 0.obs;

  @override
  void onInit() {
    super.onInit();

    loadStudents();
  }

  void loadStudents() {
    students.value = [
      StudentModel(
        rollNo: "101",
        name: "Ahmed Ali",
      ),
      StudentModel(
        rollNo: "102",
        name: "Mohammed Salman",
      ),
      StudentModel(
        rollNo: "103",
        name: "Abdul Rahman",
      ),
      StudentModel(
        rollNo: "104",
        name: "Yusuf Khan",
      ),
    ];

    calculateCounts();
  }

  /// TOGGLE P/A
  void toggleAttendance(int index) {
    if (students[index].status == "P") {
      students[index].status = "A";
    } else {
      students[index].status = "P";
    }

    students.refresh();

    calculateCounts();
  }

  /// COUNTS
  void calculateCounts() {
    presentCount.value = students.where((e) => e.status == "P").length;

    absentCount.value = students.where((e) => e.status == "A").length;
  }

  void saveAttendance() {
    for (var student in students) {
      print(
        "${student.name} => ${student.status}",
      );
    }
    successToast("Successfully Student Attendance Posted.");
    // Get.snackbar(
    //   "Success",
    //   "Attendance Saved Successfully",
    // );
  }
}
