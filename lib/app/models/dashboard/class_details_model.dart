class ClassDetailsModel {
  String? classId;
  String? courseName;
  String? className;
  int? totalPeriods;
  int? totalStudents;

  /// Current Period
  String? currentPeriodId;
  String? currentPeriodName;

  List<ClassStudentModel> students;

  ClassDetailsModel({
    this.classId,
    this.courseName,
    this.className,
    this.totalPeriods,
    this.totalStudents,
    this.currentPeriodId,
    this.currentPeriodName,
    required this.students,
  });

  factory ClassDetailsModel.fromJson(Map<String, dynamic> json) {
    return ClassDetailsModel(
      classId: json["classId"]?.toString(),
      courseName: json["courseName"]?.toString(),
      className: json["className"]?.toString(),
      totalPeriods: json["totalPeriods"] ?? 0,
      totalStudents: json["totalStudents"] ?? 0,
      currentPeriodId: json["currentPeriodId"]?.toString(),
      currentPeriodName: json["currentPeriodName"]?.toString(),
      students: (json["students"] as List<dynamic>? ?? [])
          .map((e) => ClassStudentModel.fromJson(e))
          .toList(),
    );
  }
}

class ClassStudentModel {
  String? studentId;
  String? studentName;

  ClassStudentModel({
    this.studentId,
    this.studentName,
  });

  factory ClassStudentModel.fromJson(Map<String, dynamic> json) {
    return ClassStudentModel(
      studentId: json["studentId"]?.toString(),
      studentName: json["studentName"]?.toString(),
    );
  }
}
