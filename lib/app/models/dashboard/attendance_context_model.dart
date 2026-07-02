class AttendanceContextModel {
  final bool success;
  final String message;

  final String? classId;
  final String? className;

  final String? courseId;
  final String? courseName;

  final int? periodNumber;

  final String? subjectId;
  final String? subjectName;

  AttendanceContextModel({
    required this.success,
    required this.message,
    this.classId,
    this.className,
    this.courseId,
    this.courseName,
    this.periodNumber,
    this.subjectId,
    this.subjectName,
  });

  factory AttendanceContextModel.fromJson(Map<String, dynamic> json) {
    return AttendanceContextModel(
      success: json["success"] ?? false,
      message: json["message"] ?? "",
      classId: json["classId"],
      className: json["className"],
      courseId: json["courseId"],
      courseName: json["courseName"],
      periodNumber: json["periodNumber"],
      subjectId: json["subjectId"],
      subjectName: json["subjectName"],
    );
  }
}
