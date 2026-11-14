import 'package:get/get.dart';

class MealForecastStudentModel {
  final String studentId;
  final String displayStudentId;
  final String studentName;
  final String studentNameUrdu;

  const MealForecastStudentModel({
    required this.studentId,
    required this.displayStudentId,
    required this.studentName,
    required this.studentNameUrdu,
  });

  factory MealForecastStudentModel.fromJson(Map<String, dynamic> json) {
    return MealForecastStudentModel(
      studentId: (json["student_id"] ?? json["studentId"] ?? "").toString(),
      displayStudentId: (json["display_student_id"] ??
              json["displayStudentId"] ??
              json["student_code"] ??
              json["studentCode"] ??
              json["student_id"] ??
              json["studentId"] ??
              "")
          .toString(),
      studentName:
          (json["student_name"] ?? json["studentName"] ?? json["name"] ?? "")
              .toString(),
      studentNameUrdu:
          (json["student_name_urdu"] ?? json["studentNameUrdu"] ?? "")
              .toString(),
    );
  }

  String get displayName =>
      Get.locale?.languageCode == "ur" && studentNameUrdu.trim().isNotEmpty
          ? studentNameUrdu
          : studentName;
}
