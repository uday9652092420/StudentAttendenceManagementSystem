class StudentModel {
  final String rollNo;
  final String name;

  /// P = Present
  /// A = Absent
  String status;

  StudentModel({
    required this.rollNo,
    required this.name,
    this.status = "P",
  });
}
