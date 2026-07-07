class StudentAttendanceModel {
  final String hostelAdmissionId;
  final String roomId;

  final String studentId;
  final String rollNo;
  final String studentName;

  final String roomNo;
  final String bedNo;

  String status;
  String remarks;

  StudentAttendanceModel({
    required this.hostelAdmissionId,
    required this.roomId,
    required this.studentId,
    required this.rollNo,
    required this.studentName,
    required this.roomNo,
    required this.bedNo,
    this.status = "Present",
    this.remarks = "",
  });
}
