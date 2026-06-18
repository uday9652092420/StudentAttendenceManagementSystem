class WardenAttendanceDashboardModel {
  final int present;
  final int absent;
  final int leave;
  final int outPass;

  final List<FloorAttendanceModel> floors;

  WardenAttendanceDashboardModel({
    required this.present,
    required this.absent,
    required this.leave,
    required this.outPass,
    required this.floors,
  });

  factory WardenAttendanceDashboardModel.fromJson(Map<String, dynamic> json) {
    return WardenAttendanceDashboardModel(
      present: json["present"] ?? 0,
      absent: json["absent"] ?? 0,
      leave: json["leave"] ?? 0,
      outPass: json["outPass"] ?? 0,
      floors: (json["floors"] as List<dynamic>? ?? [])
          .map((e) => FloorAttendanceModel.fromJson(e))
          .toList(),
    );
  }
}

class FloorAttendanceModel {
  final String floorName;
  final int totalStudents;
  final int present;
  final int absent;
  final int leave;
  final int outPass;
  final String session;

  FloorAttendanceModel({
    required this.floorName,
    required this.totalStudents,
    required this.present,
    required this.absent,
    required this.leave,
    required this.outPass,
    required this.session,
  });

  factory FloorAttendanceModel.fromJson(Map<String, dynamic> json) {
    return FloorAttendanceModel(
      floorName: json["floorName"] ?? "",
      totalStudents: json["totalStudents"] ?? 0,
      present: json["present"] ?? 0,
      absent: json["absent"] ?? 0,
      leave: json["leave"] ?? 0,
      outPass: json["outPass"] ?? 0,
      session: json["session"] ?? "",
    );
  }
}
