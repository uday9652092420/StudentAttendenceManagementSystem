class SponsorKitchenModel {
  final bool hasKitchenSponsorship;
  final int activePlans;
  final int totalPlans;
  final double costCovered;
  final double mealsServed;
  final double utilizationPercentage;
  final String certificationMessage;

  SponsorKitchenModel({
    required this.hasKitchenSponsorship,
    required this.activePlans,
    required this.totalPlans,
    required this.costCovered,
    required this.mealsServed,
    required this.utilizationPercentage,
    required this.certificationMessage,
  });

  factory SponsorKitchenModel.fromJson(Map<String, dynamic> json) {
    return SponsorKitchenModel(
      hasKitchenSponsorship: json["hasKitchenSponsorship"] ?? false,
      activePlans: json["activePlans"] ?? 0,
      totalPlans: json["totalPlans"] ?? 0,
      costCovered: (json["costCovered"] ?? 0).toDouble(),
      mealsServed: (json["mealsServed"] ?? 0).toDouble(),
      utilizationPercentage: (json["utilizationPercentage"] ?? 0).toDouble(),
      certificationMessage: json["certificationMessage"] ?? "",
    );
  }
}
