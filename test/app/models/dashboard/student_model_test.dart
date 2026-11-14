import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:my_new_app/app/models/dashboard/student_model.dart';

void main() {
  const response = {
    'studentId': 77,
    'admissionNo': '990010',
    'studentName': 'Ayaan Qureshi',
    'displayStudentId': '990010',
    'studentNameUrdu': 'ایان قریشی',
    'status': 'present',
  };

  testWidgets('maps and displays Urdu name and display student ID',
      (tester) async {
    final student = StudentModel.fromJson(response);

    await tester.pumpWidget(
      GetMaterialApp(
        locale: const Locale('ur', 'PK'),
        home: Builder(
          builder: (_) => Text(
            '${student.displayName} ${student.displayStudentId}',
          ),
        ),
      ),
    );

    expect(find.text('ایان قریشی 990010'), findsOneWidget);
    expect(student.studentId, '77');
  });

  testWidgets('uses English name in English and falls back when Urdu is empty',
      (tester) async {
    final student = StudentModel.fromJson({
      ...response,
      'studentNameUrdu': '',
    });

    await tester.pumpWidget(
      GetMaterialApp(
        locale: const Locale('ur', 'PK'),
        home: Builder(
          builder: (_) => Text(student.displayName),
        ),
      ),
    );
    expect(find.text('Ayaan Qureshi'), findsOneWidget);

    await tester.pumpWidget(
      GetMaterialApp(
        locale: const Locale('en', 'US'),
        home: Builder(
          builder: (_) => Text(student.displayName),
        ),
      ),
    );
    expect(find.text('Ayaan Qureshi'), findsOneWidget);
  });

  test('uses admission number when displayStudentId is missing', () {
    final student = StudentModel.fromJson({
      'studentId': 77,
      'admissionNo': '990010',
      'studentName': 'Ayaan Qureshi',
    });

    expect(student.displayStudentId, '990010');
  });

  testWidgets('maps the Student Master response fields', (tester) async {
    final student = StudentModel.fromJson({
      'studentId': 77,
      'admissionNo': '990010',
      'studentName': 'Ayaan Qureshi',
      'studentNameUrdu': 'ایان قریشی',
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
}
