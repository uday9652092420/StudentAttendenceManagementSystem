class GatePassDetailsModel {
  String? gatePassId;
  String? hostelAdmissionId;
  String? studentId;

  String? outConfirmedAt;
  String? returnConfirmedAt;
  String? studentName;
  String? roomNo;
  String? courseName;
  String? gatePassNo;
  String? reason;
  String? approvedBy;
  String? issueDate;
  String? returnTime;

  String? photoPath;

  bool? movementExists;
  String? movementId;

  bool? outConfirmed;
  String? outSecurityGuard;

  bool? returnConfirmed;
  String? returnSecurityGuard;

  GatePassDetailsModel({
    this.gatePassId,
    this.hostelAdmissionId,
    this.studentId,
    this.studentName,
    this.roomNo,
    this.courseName,
    this.gatePassNo,
    this.reason,
    this.approvedBy,
    this.issueDate,
    this.returnTime,
    this.photoPath,
    this.movementExists,
    this.movementId,
    this.outConfirmed,
    this.outSecurityGuard,
    this.returnConfirmed,
    this.returnSecurityGuard,
    this.outConfirmedAt,
    this.returnConfirmedAt,
  });

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

    movementExists = json["movement_exists"] ?? false;
    movementId = json["movement_id"]?.toString();

    outConfirmed = json["out_confirmed"] ?? json["outConfirmed"] ?? false;

    returnConfirmed =
        json["return_confirmed"] ?? json["returnConfirmed"] ?? false;

    outSecurityGuard = json["out_security_guard"] ?? json["outSecurityGuard"];

    returnSecurityGuard =
        json["return_security_guard"] ?? json["returnSecurityGuard"];

    outConfirmedAt = json["out_confirmed_at"] ?? json["outConfirmedAt"];

    returnConfirmedAt =
        json["return_confirmed_at"] ?? json["returnConfirmedAt"];
  }
}
