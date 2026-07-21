import 'package:get/get.dart';

class MasjidStudentModel {
  final String id;
  final String studentId;
  final String studentName;
  final String courseName;

  RxBool isPresent = false.obs;

  MasjidStudentModel({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.courseName,
  });

  factory MasjidStudentModel.fromJson(Map<String, dynamic> json) {
    return MasjidStudentModel(
      id: json["id"].toString(),

      // API studentId is null
      studentId:
          json["studentId"]?.toString() ?? json["admissionNo"].toString(),

      studentName: json["studentName"] ?? "",

      courseName: json["currentCourseName"] ?? "",
    );
  }
}
