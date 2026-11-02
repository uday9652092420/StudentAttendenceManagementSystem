import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_new_app/app/helpers/shared_preferences.dart';

class AppLanguageSwitcher extends StatelessWidget {
  const AppLanguageSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: "Change language".tr,
      icon: const Icon(Icons.language, color: Colors.white),
      onSelected: _changeLanguage,
      itemBuilder: (context) => [
        _languageItem("en", "English"),
        _languageItem("ur", "اردو"),
      ],
    );
  }

  PopupMenuItem<String> _languageItem(String code, String label) {
    return PopupMenuItem<String>(
      value: code,
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Get.locale?.languageCode == code
                ? const Icon(Icons.check, size: 18)
                : null,
          ),
          Text(label),
        ],
      ),
    );
  }

  Future<void> _changeLanguage(String languageCode) async {
    final countryCode = languageCode == "ur" ? "PK" : "US";
    await SharedPrefsHelper.setString(
      SharedPrefsHelper.languageCode,
      languageCode,
    );
    await SharedPrefsHelper.setString(
      SharedPrefsHelper.countryCode,
      countryCode,
    );
    Get.updateLocale(Locale(languageCode, countryCode));
  }
}
