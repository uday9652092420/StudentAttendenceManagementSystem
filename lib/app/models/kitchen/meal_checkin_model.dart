class MealCheckinModel {
  String studentId;
  String studentName;
  String rollNo;
  String roomNo;
  String mealType;
  String date;
  String time;

  MealCheckinModel({
    required this.studentId,
    required this.studentName,
    required this.rollNo,
    required this.roomNo,
    required this.mealType,
    required this.date,
    required this.time,
  });

  Map<String, dynamic> toJson() {
    return {
      "studentId": studentId,
      "mealType": mealType,
      "date": date,
      "time": time,
    };
  }
}
