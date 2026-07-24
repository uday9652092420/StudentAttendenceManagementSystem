import 'package:get/get.dart';

class MasjidStudentModel {
  final String studentId;
  final String studentName;

  RxBool isPresent = true.obs;

  MasjidStudentModel({
    required this.studentId,
    required this.studentName,
  });

  factory MasjidStudentModel.fromJson(Map<String, dynamic> json) {
    final model = MasjidStudentModel(
      studentId: (json["id"] ?? "").toString(),
      studentName: (json["studentName"] ?? "").toString(),
    );

    model.isPresent.value = json["isPresent"] ?? true;

    return model;
  }
}
