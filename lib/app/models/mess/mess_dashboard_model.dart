class ForecastRecord {
  final String hostelName;
  final int breakfast;
  final int lunch;
  final int dinner;

  ForecastRecord({
    required this.hostelName,
    required this.breakfast,
    required this.lunch,
    required this.dinner,
  });

  factory ForecastRecord.fromJson(Map<String, dynamic> json) {
    return ForecastRecord(
      hostelName: json["hostelName"] ?? "",
      breakfast: json["breakfast"] ?? 0,
      lunch: json["lunch"] ?? 0,
      dinner: json["dinner"] ?? 0,
    );
  }
}
