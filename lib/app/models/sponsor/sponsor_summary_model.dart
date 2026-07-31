class SponsorSummaryModel {
  final int totalSponsoredStudents;
  final int activeSponsoredStudents;
  final double averageAttendance;
  final double averageExamScore;
  final double kitchenUtilization;
  final double totalKitchenBudget;

  SponsorSummaryModel({
    required this.totalSponsoredStudents,
    required this.activeSponsoredStudents,
    required this.averageAttendance,
    required this.averageExamScore,
    required this.kitchenUtilization,
    required this.totalKitchenBudget,
  });

  factory SponsorSummaryModel.fromJson(Map<String, dynamic> json) {
    return SponsorSummaryModel(
      totalSponsoredStudents: json["totalSponsoredStudents"] ?? 0,
      activeSponsoredStudents: json["activeSponsoredStudents"] ?? 0,
      averageAttendance: (json["averageAttendance"] ?? 0).toDouble(),
      averageExamScore: (json["averageExamScore"] ?? 0).toDouble(),
      kitchenUtilization: (json["kitchenUtilization"] ?? 0).toDouble(),
      totalKitchenBudget: (json["totalKitchenBudget"] ?? 0).toDouble(),
    );
  }
}
