class GatePassDetailsModel {
  String? gatePassId;
  String? hostelAdmissionId;
  String? studentId;
  String? studentName;
  String? roomNo;
  String? courseName;
  String? gatePassNo;
  String? reason;
  String? approvedBy;
  String? issueDate;
  String? returnTime;
  String? photoPath;

  GatePassDetailsModel.fromJson(Map<String, dynamic> json) {
    gatePassId = json["gate_pass_id"];
    hostelAdmissionId = json["hostel_admission_id"];
    studentId = json["student_id"];
    studentName = json["student_name"];
    roomNo = json["room_no"];
    courseName = json["course_name"];
    gatePassNo = json["gate_pass_no"];
    reason = json["reason"];
    approvedBy = json["approved_by"];
    issueDate = json["issue_date"];
    returnTime = json["return_time"];
    photoPath = json["photo_path"];
  }
}
