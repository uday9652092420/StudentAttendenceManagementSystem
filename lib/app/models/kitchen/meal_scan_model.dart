class MealScanModel {
  final String studentId;
  final String rollNo;
  final String studentName;
  final String mealType;
  final String hostelName;
  final String roomNo;
  final String scannedTime;

  MealScanModel({
    required this.studentId,
    required this.rollNo,
    required this.studentName,
    required this.mealType,
    required this.hostelName,
    required this.roomNo,
    required this.scannedTime,
  });

  factory MealScanModel.fromJson(Map<String, dynamic> json) {
    return MealScanModel(
      studentId: json["studentId"]?.toString() ?? "",
      rollNo: json["rollNo"]?.toString() ?? "",
      studentName: json["studentName"] ?? "",
      mealType: json["mealType"] ?? "",
      hostelName: json["hostelName"] ?? "",
      roomNo: json["roomNo"] ?? "",
      scannedTime: json["scannedTime"] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "studentId": studentId,
      "rollNo": rollNo,
      "studentName": studentName,
      "mealType": mealType,
      "hostelName": hostelName,
      "roomNo": roomNo,
      "scannedTime": scannedTime,
    };
  }
}
