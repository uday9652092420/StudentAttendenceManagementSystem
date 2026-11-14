import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:my_new_app/app/helpers/shared_preferences.dart';
import 'package:my_new_app/app/localization/localization.dart';
import 'package:my_new_app/app/views/multiroleuser/mutliroleuser_dashboard_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('translates the welcome label into Urdu', (tester) async {
    await tester.pumpWidget(
      GetMaterialApp(
        translations: Localization(),
        locale: Localization.localeUrdu,
        home: Builder(
          builder: (_) => Text('Welcome'.tr),
        ),
      ),
    );

    expect(find.text('خوش آمدید'), findsOneWidget);
  });

  testWidgets('restores and maps all supported roles from login', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'roleNames': [
        'Lecturer',
        'Hostel Warden',
        'Kitchen Supervisor',
        'Masjid Incharge',
      ],
    });
    await SharedPrefsHelper.init();

    await tester.pumpWidget(
      GetMaterialApp(
        translations: Localization(),
        locale: Localization.localeEnglishUS,
        home: const MultiRoleUserDashboardView(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.language), findsOneWidget);
    expect(
      find.text('No supported modules were found for this account.'),
      findsNothing,
    );

    final dropdown = tester.widget<DropdownButtonFormField<String>>(
      find.byType(DropdownButtonFormField<String>),
    );
    expect(dropdown.onChanged, isNotNull);

    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();

    expect(find.text('Lecturer'), findsOneWidget);
    expect(find.text('Hostel Warden'), findsOneWidget);
    expect(find.text('Kitchen Supervisor'), findsOneWidget);
    expect(find.text('Masjid Incharge'), findsOneWidget);
  });
}
