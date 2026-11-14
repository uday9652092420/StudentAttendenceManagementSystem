import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:my_new_app/app/models/masjid/studentmodel.dart';

void main() {
  testWidgets('shows the Urdu student name when Urdu is selected',
      (tester) async {
    final student = MasjidStudentModel.fromJson({
      'studentId': '77',
      'displayStudentId': '990010',
      'studentName': 'Ayaan Qureshi',
      'studentNameUrdu': 'ایان قریشی',
    });

    await tester.pumpWidget(
      GetMaterialApp(
        locale: const Locale('ur', 'PK'),
        home: Builder(
          builder: (_) => Text(student.displayName),
        ),
      ),
    );

    expect(find.text('ایان قریشی'), findsOneWidget);
    expect(student.studentId, '77');
    expect(student.displayStudentId, '990010');
  });

  testWidgets('falls back to the English student name when Urdu is absent',
      (tester) async {
    final student = MasjidStudentModel.fromJson({
      'studentId': '77',
      'studentName': 'Ayaan Qureshi',
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
  });

  testWidgets('recognizes an Urdu value in the API name field', (tester) async {
    final student = MasjidStudentModel.fromJson({
      'studentId': '77',
      'studentName': 'Ayaan Qureshi',
      'name': 'ایان قریشی',
    });

    await tester.pumpWidget(
      GetMaterialApp(
        locale: const Locale('ur', 'PK'),
        home: Builder(
          builder: (_) => Text(student.displayName),
        ),
      ),
    );

    expect(find.text('ایان قریشی'), findsOneWidget);
  });
}
