class StudentAttendanceModel {
  final String rollNo;
  final String studentId;
  final String studentName;
  final String roomNo;
  final String bedNo;

  String biometric;
  String biometricTime;
  String status;
  String remarks;

  StudentAttendanceModel({
    required this.rollNo,
    required this.studentId,
    required this.studentName,
    required this.roomNo,
    required this.bedNo,
    this.biometric = "manual",
    this.biometricTime = "--",
    this.status = "Present",
    this.remarks = "",
  });
}
