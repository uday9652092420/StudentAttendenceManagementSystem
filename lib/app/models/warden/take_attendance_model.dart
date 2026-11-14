import 'package:get/get.dart';

class StudentAttendanceModel {
  final String hostelAdmissionId;
  final String roomId;

  final String studentId;
  final String displayStudentId;
  final String rollNo;
  final String studentName;
  final String studentNameUrdu;

  final String roomNo;
  final String bedNo;

  String status;
  String remarks;

  StudentAttendanceModel({
    required this.hostelAdmissionId,
    required this.roomId,
    required this.studentId,
    this.displayStudentId = "",
    required this.rollNo,
    required this.studentName,
    this.studentNameUrdu = "",
    required this.roomNo,
    required this.bedNo,
    this.status = "Present",
    this.remarks = "",
  });

  factory StudentAttendanceModel.fromJson(Map<String, dynamic> json) {
    final apiStatus = (json["attendance_status"] ?? json["status"] ?? "present")
        .toString()
        .toLowerCase();
    return StudentAttendanceModel(
      hostelAdmissionId:
          (json["hostel_admission_id"] ?? json["hostelAdmissionId"] ?? "")
              .toString(),
      roomId: (json["room_id"] ?? json["roomId"] ?? "").toString(),
      studentId: (json["student_id"] ?? json["studentId"] ?? "").toString(),
      displayStudentId:
          (json["display_student_id"] ?? json["displayStudentId"] ?? "")
              .toString(),
      rollNo: (json["student_code"] ?? json["studentCode"] ?? "").toString(),
      studentName:
          (json["student_name"] ?? json["studentName"] ?? "").toString(),
      studentNameUrdu:
          (json["student_name_urdu"] ?? json["studentNameUrdu"] ?? "")
              .toString(),
      roomNo: (json["room_no"] ?? json["roomNo"] ?? "").toString(),
      bedNo: (json["bed_no"] ?? json["bedNo"] ?? "").toString(),
      remarks: (json["remarks"] ?? "").toString(),
      status: switch (apiStatus) {
        "absent" => "Absent",
        "leave" => "Leave",
        "outpass" => "Out Pass",
        _ => "Present",
      },
    );
  }

  String get displayName =>
      Get.locale?.languageCode == "ur" && studentNameUrdu.trim().isNotEmpty
          ? studentNameUrdu
          : studentName;

  String get displayId => displayStudentId.isNotEmpty
      ? displayStudentId
      : rollNo.isNotEmpty
          ? rollNo
          : studentId;
}
