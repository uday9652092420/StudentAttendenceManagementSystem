import 'package:get/get.dart';

class MasjidStudentModel {
  final String studentId;
  final String displayStudentId;
  final String studentName;
  final String urduStudentName;

  RxBool isPresent = true.obs;

  MasjidStudentModel({
    required this.studentId,
    required this.displayStudentId,
    required this.studentName,
    required this.urduStudentName,
  });

  String get displayName =>
      Get.locale?.languageCode == "ur" && urduStudentName.isNotEmpty
          ? urduStudentName
          : studentName;

  factory MasjidStudentModel.fromJson(Map<String, dynamic> json) {
    final nameFallback = _firstValue(
      json,
      const ["name", "fullName", "full_name"],
    );
    final explicitUrduName = _firstValue(
      json,
      const [
        "studentNameUrdu",
        "student_name_urdu",
        "studentNameUr",
        "student_name_ur",
        "urduStudentName",
        "urdu_student_name",
        "nameUrdu",
        "name_urdu",
        "nameUr",
        "name_ur",
        "nameInUrdu",
        "name_in_urdu",
        "urduName",
        "urdu_name",
        "studentNameAr",
        "student_name_ar",
        "studentNameArabic",
        "student_name_arabic",
        "studentNameInArabic",
        "student_name_in_arabic",
        "arabicName",
        "arabic_name",
      ],
    );
    final studentName = _firstValue(
      json,
      const ["studentName", "student_name", "name"],
    );
    final urduStudentName = explicitUrduName.isNotEmpty
        ? explicitUrduName
        : _containsUrduScript(nameFallback)
            ? nameFallback
            : _containsUrduScript(studentName)
                ? studentName
                : "";
    final status = (json["attendanceStatus"] ??
            json["attendance_status"] ??
            json["status"] ??
            "")
        .toString()
        .toLowerCase();
    final model = MasjidStudentModel(
      studentId: (json["studentId"] ?? json["student_id"] ?? json["id"] ?? "")
          .toString(),
      displayStudentId: _firstValue(
        json,
        const [
          "displayStudentId",
          "display_student_id",
          "admissionNo",
          "admission_no",
          "studentId",
          "student_id",
          "id",
        ],
      ),
      studentName: studentName,
      urduStudentName: urduStudentName,
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

  static String _firstValue(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key]?.toString().trim() ?? "";
      if (value.isNotEmpty) return value;
    }
    return "";
  }

  static bool _containsUrduScript(String value) =>
      RegExp(r'[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF]').hasMatch(value);
}
