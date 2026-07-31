class MealScanModel {
  final String studentId;
  final String rollNo;
  final String studentName;
  final String className;
  final String courseName;
  final String mealType;
  final String scannedTime;
  final String roomNo;

  MealScanModel({
    required this.studentId,
    required this.rollNo,
    required this.studentName,
    required this.className,
    required this.courseName,
    required this.mealType,
    required this.scannedTime,
    required this.roomNo,
  });

  factory MealScanModel.fromJson(Map<String, dynamic> json) {
    return MealScanModel(
      studentId: json["student_id"]?.toString() ?? "",
      rollNo: json["student_code"]?.toString() ?? "",
      studentName: json["student_name"] ?? "",
      className: json["class_name"] ?? "",
      courseName: json["course_name"] ?? "",
      mealType: json["meal_type"] ?? "",
      roomNo: json["room_no"] ?? "",
      scannedTime: json["created_at"] ?? "",
    );
  }
}
