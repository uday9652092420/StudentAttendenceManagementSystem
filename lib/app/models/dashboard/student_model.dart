import 'package:get/get.dart';

class StudentModel {
  String studentId;
  String displayStudentId;
  String name;
  String studentNameUrdu;
  String status;

  StudentModel({
    required this.studentId,
    required this.displayStudentId,
    required this.name,
    this.studentNameUrdu = "",
    required this.status,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      studentId: (json["studentId"] ?? json["student_id"] ?? json["id"] ?? "")
          .toString(),
      displayStudentId: (json["displayStudentId"] ??
              json["display_student_id"] ??
              json["admissionNo"] ??
              json["admission_no"] ??
              json["studentId"] ??
              json["student_id"] ??
              json["id"] ??
              "")
          .toString(),
      name: (json["studentName"] ?? json["student_name"] ?? json["name"] ?? "")
          .toString(),
      studentNameUrdu:
          (json["studentNameUrdu"] ?? json["student_name_urdu"] ?? "")
              .toString(),
      status: (json["status"] ?? json["attendanceStatus"] ?? "P").toString(),
    );
  }

  String get displayName =>
      Get.locale?.languageCode == "ur" && studentNameUrdu.trim().isNotEmpty
          ? studentNameUrdu
          : name;
}
