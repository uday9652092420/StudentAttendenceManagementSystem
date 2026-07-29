class MealCheckinModel {
  String studentId;
  String studentName;
  String courseName;
  String className;
  String mealType;
  String date;
  String time;

  MealCheckinModel({
    required this.studentId,
    required this.studentName,
    required this.courseName,
    required this.className,
    required this.mealType,
    required this.date,
    required this.time,
  });

  Map<String, dynamic> toJson() {
    return {
      "studentId": studentId,
      "studentName": studentName,
      "courseName": courseName,
      "className": className,
      "mealType": mealType,
      "date": date,
      "time": time,
    };
  }
}
