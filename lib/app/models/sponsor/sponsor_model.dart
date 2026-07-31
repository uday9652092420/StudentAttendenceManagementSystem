class SponsorModel {
  final String id;
  final String userId;
  final String sponsorCode;
  final String sponsorName;
  final String sponsorType;
  final String email;
  final String phone;
  final String sponsorshipCategory;
  final String billingCycle;
  final double amountPerCycle;
  final bool activePlan;

  SponsorModel({
    required this.id,
    required this.userId,
    required this.sponsorCode,
    required this.sponsorName,
    required this.sponsorType,
    required this.email,
    required this.phone,
    required this.sponsorshipCategory,
    required this.billingCycle,
    required this.amountPerCycle,
    required this.activePlan,
  });

  factory SponsorModel.fromJson(Map<String, dynamic> json) {
    return SponsorModel(
      id: json["id"] ?? "",
      userId: json["userId"] ?? "",
      sponsorCode: json["sponsorCode"] ?? "",
      sponsorName: json["sponsorName"] ?? "",
      sponsorType: json["sponsorType"] ?? "",
      email: json["email"] ?? "",
      phone: json["phone"] ?? "",
      sponsorshipCategory: json["sponsorshipCategory"] ?? "",
      billingCycle: json["billingCycle"] ?? "",
      amountPerCycle: (json["amountPerCycle"] ?? 0).toDouble(),
      activePlan: json["activePlan"] ?? false,
    );
  }
}
