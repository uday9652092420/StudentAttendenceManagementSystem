import 'package:get/get.dart';

class MasjidStudentModel {
  final String studentId;
  final String studentName;

  RxBool isPresent = true.obs;

  MasjidStudentModel({
    required this.studentId,
    required this.studentName,
  });

  factory MasjidStudentModel.fromJson(Map<String, dynamic> json) {
    final status = (json["attendanceStatus"] ??
            json["attendance_status"] ??
            json["status"] ??
            "")
        .toString()
        .toLowerCase();
    final model = MasjidStudentModel(
      studentId: (json["studentId"] ?? json["student_id"] ?? json["id"] ?? "")
          .toString(),
      studentName:
          (json["studentName"] ?? json["student_name"] ?? json["name"] ?? "")
              .toString(),
    );

    final presence = json["isPresent"] ?? json["is_present"];
    if (presence is bool) {
      model.isPresent.value = presence;
    } else {
      final normalizedPresence = presence?.toString().toLowerCase();
      model.isPresent.value = normalizedPresence == "present" ||
          normalizedPresence == "p" ||
          normalizedPresence == "true" ||
          normalizedPresence == "1" ||
          (normalizedPresence == null &&
              (status.isEmpty || status == "present" || status == "p"));
    }

    return model;
  }
}
