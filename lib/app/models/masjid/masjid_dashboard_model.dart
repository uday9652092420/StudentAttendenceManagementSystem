class MasjidDashboardModel {
  final String date;
  final String time;
  final String prayer;

  MasjidDashboardModel({
    required this.date,
    required this.time,
    required this.prayer,
  });

  factory MasjidDashboardModel.fromJson(Map<String, dynamic> json) {
    return MasjidDashboardModel(
      date: json["date"] ?? "",
      time: json["time"] ?? "",
      prayer: json["prayer"] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "date": date,
      "time": time,
      "prayer": prayer,
    };
  }
}
