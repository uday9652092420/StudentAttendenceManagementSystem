import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:my_new_app/app/models/kitchen/meal_forecast_student_model.dart';
import 'package:my_new_app/app/models/kitchen/meal_scan_model.dart';

void main() {
  testWidgets('maps forecast Urdu name and display student ID', (tester) async {
    final student = MealForecastStudentModel.fromJson({
      'student_id': 77,
      'display_student_id': '990010',
      'student_name': 'Ayaan Qureshi',
      'student_name_urdu': 'ایان قریشی',
    });

    await tester.pumpWidget(
      GetMaterialApp(
        locale: const Locale('ur', 'PK'),
        home: Builder(
          builder: (_) =>
              Text('${student.displayName} ${student.displayStudentId}'),
        ),
      ),
    );

    expect(find.text('ایان قریشی 990010'), findsOneWidget);
  });

  testWidgets('maps kitchen recent scan Urdu name and uses English fallback',
      (tester) async {
    final student = MealScanModel.fromJson({
      'student_id': 77,
      'student_name': 'Ayaan Qureshi',
      'student_name_urdu': '',
      'display_student_id': '990010',
      'student_code': 'RND-001',
      'class_name': 'Class 1',
      'course_name': 'Course',
      'meal_type': 'lunch',
      'room_no': '12',
      'created_at': '2026-11-14T09:00:00Z',
    });

    await tester.pumpWidget(
      GetMaterialApp(
        locale: const Locale('ur', 'PK'),
        home: Builder(
          builder: (_) => Text('${student.displayName} ${student.displayId}'),
        ),
      ),
    );

    expect(find.text('Ayaan Qureshi 990010'), findsOneWidget);
  });
}
