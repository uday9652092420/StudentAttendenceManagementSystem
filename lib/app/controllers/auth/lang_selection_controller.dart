import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../helpers/shared_preferences.dart';

class LangSelectionController extends GetxController {
  var selectedValue = 'en'.obs;

  Future<void> changeLanguage() async {
    if (selectedValue.value == 'en') {
      await SharedPrefsHelper.setString(SharedPrefsHelper.languageCode, 'en');
      await SharedPrefsHelper.setString(SharedPrefsHelper.countryCode, 'US');
      Get.updateLocale(const Locale('en', 'US'));
    } else {
      await SharedPrefsHelper.setString(SharedPrefsHelper.languageCode, 'ur');
      await SharedPrefsHelper.setString(SharedPrefsHelper.countryCode, 'PK');
      Get.updateLocale(const Locale('ur', 'PK'));
    }
    Get.offNamed('/login');
  }
}
