import 'package:get/get.dart';

class MealScanModel {
  final String studentId;
  final String rollNo;
  final String studentName;
  final String studentNameUrdu;
  final String displayStudentId;
  final String className;
  final String courseName;
  final String mealType;
  final String scannedTime;
  final String roomNo;

  MealScanModel({
    required this.studentId,
    required this.rollNo,
    required this.studentName,
    this.studentNameUrdu = "",
    this.displayStudentId = "",
    required this.className,
    required this.courseName,
    required this.mealType,
    required this.scannedTime,
    required this.roomNo,
  });

  factory MealScanModel.fromJson(Map<String, dynamic> json) {
    return MealScanModel(
      studentId: (json["student_id"] ?? json["studentId"] ?? "").toString(),
      rollNo: (json["student_code"] ?? json["studentCode"] ?? "").toString(),
      studentName:
          (json["student_name"] ?? json["studentName"] ?? json["name"] ?? "")
              .toString(),
      studentNameUrdu:
          (json["student_name_urdu"] ?? json["studentNameUrdu"] ?? "")
              .toString(),
      displayStudentId: (json["display_student_id"] ??
              json["displayStudentId"] ??
              json["admissionNo"] ??
              "")
          .toString(),
      className: (json["class_name"] ?? json["className"] ?? "").toString(),
      courseName: (json["course_name"] ?? json["courseName"] ?? "").toString(),
      mealType: (json["meal_type"] ?? json["mealType"] ?? "").toString(),
      roomNo: (json["room_no"] ?? json["roomNo"] ?? "").toString(),
      scannedTime: (json["created_at"] ?? json["createdAt"] ?? "").toString(),
    );
  }

  String get displayName =>
      Get.locale?.languageCode == "ur" && studentNameUrdu.trim().isNotEmpty
          ? studentNameUrdu
          : studentName;

  String get displayId => displayStudentId.isNotEmpty
      ? displayStudentId
      : rollNo.isNotEmpty
          ? rollNo
          : studentId;
}
