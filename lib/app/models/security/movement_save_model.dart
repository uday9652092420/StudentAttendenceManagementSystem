class MovementSaveModel {
  String gatePassId;
  String hostelAdmissionId;
  String studentId;
  String studentName;
  String roomNo;
  String courseName;
  String gatePassNo;

  bool outConfirmed;
  String outSecurityGuard;

  bool returnConfirmed;
  String returnSecurityGuard;

  MovementSaveModel({
    required this.gatePassId,
    required this.hostelAdmissionId,
    required this.studentId,
    required this.studentName,
    required this.roomNo,
    required this.courseName,
    required this.gatePassNo,
    required this.outConfirmed,
    required this.outSecurityGuard,
    required this.returnConfirmed,
    required this.returnSecurityGuard,
  });

  Map<String, dynamic> toJson() {
    return {
      "gatePassId": gatePassId,
      "hostelAdmissionId": hostelAdmissionId,
      "studentId": studentId,
      "studentName": studentName,
      "roomNo": roomNo,
      "courseName": courseName,
      "gatePassNo": gatePassNo,
      "outConfirmed": outConfirmed,
      "outSecurityGuard": outSecurityGuard,
      "returnConfirmed": returnConfirmed,
      "returnSecurityGuard": returnSecurityGuard,
    };
  }
}
