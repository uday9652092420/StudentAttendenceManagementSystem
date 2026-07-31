class SponsorStudentModel {
  final String mappingId;
  final String studentId;
  final String admissionId;
  final String admissionNo;
  final String studentName;
  final String courseName;
  final String hostel;
  final String studentType;
  final double monthlyCost;
  final String sponsorshipStartDate;
  final String sponsorshipEndDate;
  final String sponsorshipStatus;
  final bool autoStop;
  final double attendancePercentage;
  final double lastExamScore;
  final String discipline;

  SponsorStudentModel({
    required this.mappingId,
    required this.studentId,
    required this.admissionId,
    required this.admissionNo,
    required this.studentName,
    required this.courseName,
    required this.hostel,
    required this.studentType,
    required this.monthlyCost,
    required this.sponsorshipStartDate,
    required this.sponsorshipEndDate,
    required this.sponsorshipStatus,
    required this.autoStop,
    required this.attendancePercentage,
    required this.lastExamScore,
    required this.discipline,
  });

  factory SponsorStudentModel.fromJson(Map<String, dynamic> json) {
    return SponsorStudentModel(
      mappingId: json["mappingId"] ?? "",
      studentId: json["studentId"] ?? "",
      admissionId: json["admissionId"] ?? "",
      admissionNo: json["admissionNo"] ?? "",
      studentName: json["studentName"] ?? "",
      courseName: json["courseName"] ?? "",
      hostel: json["hostel"] ?? "",
      studentType: json["studentType"] ?? "",
      monthlyCost: (json["monthlyCost"] ?? 0).toDouble(),
      sponsorshipStartDate: json["sponsorshipStartDate"] ?? "",
      sponsorshipEndDate: json["sponsorshipEndDate"] ?? "",
      sponsorshipStatus: json["sponsorshipStatus"] ?? "",
      autoStop: json["autoStop"] ?? false,
      attendancePercentage: (json["attendancePercentage"] ?? 0).toDouble(),
      lastExamScore: (json["lastExamScore"] ?? 0).toDouble(),
      discipline: json["discipline"] ?? "",
    );
  }
}
