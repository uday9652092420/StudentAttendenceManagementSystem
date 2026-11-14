import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:my_new_app/app/models/warden/take_attendance_model.dart';

void main() {
  testWidgets('maps hostel Urdu name and updates after a locale switch',
      (tester) async {
    final student = StudentAttendanceModel.fromJson({
      'student_id': 77,
      'student_code': '990010',
      'display_student_id': '990010',
      'student_name': 'Ayaan Qureshi',
      'student_name_urdu': 'ایان قریشی',
      'attendance_status': 'present',
    });
    final students = <StudentAttendanceModel>[student].obs;

    await tester.pumpWidget(
      GetMaterialApp(
        locale: const Locale('en', 'US'),
        home: Obx(() => Text(students.first.displayName)),
      ),
    );
    expect(find.text('Ayaan Qureshi'), findsOneWidget);

    Get.updateLocale(const Locale('ur', 'PK'));
    students.refresh();
    await tester.pump();

    expect(find.text('ایان قریشی'), findsOneWidget);
    expect(student.displayId, '990010');
    expect(student.status, 'Present');
  });

  test('falls back to the English name when the Urdu name is empty', () {
    final student = StudentAttendanceModel.fromJson({
      'student_name': 'Ayaan Qureshi',
      'student_name_urdu': '',
    });

    expect(student.studentName, 'Ayaan Qureshi');
    expect(student.studentNameUrdu, '');
    expect(student.displayId, '');
  });
}
