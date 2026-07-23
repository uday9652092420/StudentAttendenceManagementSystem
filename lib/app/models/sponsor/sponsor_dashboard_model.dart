class SponsorDashboardModel {
  final int totalStudents;
  final int averageAttendance;
  final int averageExamScore;
  final int kitchenUtilization;
  final String mealsServed;
  final String costCovered;
  final String teacherRemarks;
  final String healthSummary;
  final String overallRemarks;

  SponsorDashboardModel({
    required this.totalStudents,
    required this.averageAttendance,
    required this.averageExamScore,
    required this.kitchenUtilization,
    required this.mealsServed,
    required this.costCovered,
    required this.teacherRemarks,
    required this.healthSummary,
    required this.overallRemarks,
  });

  factory SponsorDashboardModel.fromJson(Map<String, dynamic> json) {
    return SponsorDashboardModel(
      totalStudents: json["totalStudents"] ?? 0,
      averageAttendance: json["averageAttendance"] ?? 0,
      averageExamScore: json["averageExamScore"] ?? 0,
      kitchenUtilization: json["kitchenUtilization"] ?? 0,
      mealsServed: json["mealsServed"] ?? "",
      costCovered: json["costCovered"] ?? "",
      teacherRemarks: json["teacherRemarks"] ?? "",
      healthSummary: json["healthSummary"] ?? "",
      overallRemarks: json["overallRemarks"] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
        "totalStudents": totalStudents,
        "averageAttendance": averageAttendance,
        "averageExamScore": averageExamScore,
        "kitchenUtilization": kitchenUtilization,
        "mealsServed": mealsServed,
        "costCovered": costCovered,
        "teacherRemarks": teacherRemarks,
        "healthSummary": healthSummary,
        "overallRemarks": overallRemarks,
      };
}

class SponsoredStudentModel {
  final String id;
  final String name;
  final String program;
  final int attendance;
  final int examScore;
  final String discipline;
  final String hostel;

  SponsoredStudentModel({
    required this.id,
    required this.name,
    required this.program,
    required this.attendance,
    required this.examScore,
    required this.discipline,
    required this.hostel,
  });

  factory SponsoredStudentModel.fromJson(Map<String, dynamic> json) {
    return SponsoredStudentModel(
      id: json["id"] ?? "",
      name: json["name"] ?? "",
      program: json["program"] ?? "",
      attendance: json["attendance"] ?? 0,
      examScore: json["examScore"] ?? 0,
      discipline: json["discipline"] ?? "",
      hostel: json["hostel"] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "program": program,
        "attendance": attendance,
        "examScore": examScore,
        "discipline": discipline,
        "hostel": hostel,
      };
}
