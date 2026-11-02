import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';

import 'app/config/environment.dart';
import 'app/helpers/shared_preferences.dart';
import 'app/localization/localization.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'app/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
      statusBarColor: Colors.white,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );

  runApp(const MyApp(initialLocale: Locale('en', 'US')));
  unawaited(_initializeStartupSettings());
}

Future<void> _initializeStartupSettings() async {
  await Future.wait([
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]),
    SharedPrefsHelper.init(),
  ]);

  final savedLanguageCode = await SharedPrefsHelper.getString(
    SharedPrefsHelper.languageCode,
    defaultValue: 'en',
  );
  final languageCode = savedLanguageCode == 'ur' ? 'ur' : 'en';
  final countryCode = languageCode == 'ur' ? 'PK' : 'US';
  Get.updateLocale(Locale(languageCode, countryCode));
}

class MyApp extends StatelessWidget {
  final Locale initialLocale;

  const MyApp({
    super.key,
    required this.initialLocale,
  });

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: Environment.appName,
      locale: initialLocale,
      translations: Localization(),
      supportedLocales: Localization.supportedLocales,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      fallbackLocale: Localization.fallbackLocale,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,

      // OPEN LOGIN PAGE FIRST
      initialRoute: Routes.login,

      getPages: AppPages.routes,

      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: const TextScaler.linear(1.0),
          ),
          child: child!,
        );
      },
    );
  }
}
