import 'sponsor_kitchen_model.dart';
import 'sponsor_model.dart';
import 'sponsor_student_model.dart';
import 'sponsor_summary_model.dart';

class SponsorDashboardResponse {
  final bool success;
  final SponsorModel sponsor;
  final SponsorSummaryModel summary;
  final List<SponsorStudentModel> students;
  final SponsorKitchenModel kitchen;

  SponsorDashboardResponse({
    required this.success,
    required this.sponsor,
    required this.summary,
    required this.students,
    required this.kitchen,
  });

  factory SponsorDashboardResponse.fromJson(Map<String, dynamic> json) {
    final data = json["data"] ?? {};

    return SponsorDashboardResponse(
      success: json["success"] ?? false,
      sponsor: SponsorModel.fromJson(data["sponsor"] ?? {}),
      summary: SponsorSummaryModel.fromJson(data["summary"] ?? {}),
      students: (data["students"] as List? ?? [])
          .map((e) => SponsorStudentModel.fromJson(e))
          .toList(),
      kitchen: SponsorKitchenModel.fromJson(data["kitchen"] ?? {}),
    );
  }
}
