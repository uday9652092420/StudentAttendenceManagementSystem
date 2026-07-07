class FloorAttendanceSummary {
  String floorId;
  String floorName;

  int totalStudents;
  int present;
  int absent;
  int leave;
  int outPass;

  String sessionStatus;

  FloorAttendanceSummary({
    required this.floorId,
    required this.floorName,
    required this.totalStudents,
    required this.present,
    required this.absent,
    required this.leave,
    required this.outPass,
    required this.sessionStatus,
  });
}
