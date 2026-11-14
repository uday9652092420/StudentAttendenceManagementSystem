import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:intl/intl.dart';
import 'package:my_new_app/app/helpers/shared_preferences.dart';
import 'package:my_new_app/app/custome_widgets/app_language_switcher.dart';
import 'package:my_new_app/app/routes/app_routes.dart';
import 'package:my_new_app/app/theme/app_theme.dart';

import 'package:my_new_app/app/controllers/kitchen/kitchen_dashboard_controller.dart';

class KitchenDashboardView extends GetView<KitchenDashboardController> {
  const KitchenDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Kitchen Supervisor Dashboard".tr,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          AppLanguageSwitcher(
            onLanguageChanged: (_) async => controller.refreshLocalizedNames(),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            color: Colors.white,
            onPressed: () async {
              final logout = await Get.dialog<bool>(
                AlertDialog(
                  backgroundColor: AppColors.bgLight,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  title: Text(
                    "Logout".tr,
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                  content: Text(
                    "Are you sure you want to logout?".tr,
                    style: TextStyle(color: Colors.black87),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Get.back(result: false),
                      child: Text(
                        "Cancel".tr,
                        style: TextStyle(color: Colors.black87),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => Get.back(result: true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text("Logout".tr),
                    ),
                  ],
                ),
              );

              if (logout == true) {
                await SharedPrefsHelper.remove(SharedPrefsHelper.accessToken);
                await SharedPrefsHelper.remove("username");
                await SharedPrefsHelper.remove("roleName");
                await SharedPrefsHelper.remove("staffId");

                Get.offAllNamed(Routes.login);
              }
            },
          ),
        ],
      ),
      body: Obx(
        () => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.black,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      color: Colors.black,
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Today's Date".tr,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat("EEEE, dd MMMM yyyy")
                              .format(DateTime.now()),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              /// Today's Meal Count
              Row(
                children: [
                  Expanded(
                    child: _mealCard(
                      "Breakfast",
                      controller.breakfastCount.value,
                      Colors.orange,
                      Icons.free_breakfast,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _mealCard(
                      "Lunch",
                      controller.lunchCount.value,
                      Colors.green,
                      Icons.lunch_dining,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _mealCard(
                      "Dinner",
                      controller.dinnerCount.value,
                      Colors.deepPurple,
                      Icons.dinner_dining,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              Obx(
                () => DropdownButtonFormField<String>(
                  initialValue: controller.selectedMeal.value,
                  decoration: InputDecoration(
                    labelText: "Meal Type".tr,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: controller.mealTypes
                      .map(
                        (e) => DropdownMenuItem<String>(
                          value: e,
                          child: Text(e),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      controller.changeMeal(value);
                    }
                  },
                ),
              ),

              const SizedBox(height: 25),

              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Meal Forecast Students".tr,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Obx(() {
                if (controller.isForecastLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (controller.forecastStudents.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text("No Forecast Students Found".tr),
                    ),
                  );
                }
                return Column(
                  children: controller.forecastStudents.map((student) {
                    return Card(
                      child: ListTile(
                        title: Text(
                          student.displayName,
                          textDirection: Get.locale?.languageCode == "ur"
                              ? ui.TextDirection.rtl
                              : ui.TextDirection.ltr,
                          textAlign: Get.locale?.languageCode == "ur"
                              ? TextAlign.right
                              : TextAlign.left,
                        ),
                        subtitle: Text(
                          "${"Student ID".tr}: ${student.displayStudentId}",
                        ),
                      ),
                    );
                  }).toList(),
                );
              }),

              const SizedBox(height: 25),

              /// Scan Button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.qr_code_scanner),
                  label: Text(
                    "Scan Student QR".tr,
                    style: TextStyle(fontSize: 18),
                  ),
                  onPressed: () {
                    _openScanner();
                  },
                ),
              ),

              const SizedBox(height: 15),

              /// Upload QR
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  icon: const Icon(Icons.photo_library),
                  label: Text(
                    "Upload QR Image".tr,
                    style: TextStyle(fontSize: 18),
                  ),
                  onPressed: () {
                    controller.pickQrFromGallery();
                  },
                ),
              ),

              const SizedBox(height: 25),

              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Recent Scans".tr,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              controller.recentScans.isEmpty
                  ? Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Text("No Records Found".tr),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controller.recentScans.length,
                      itemBuilder: (_, index) {
                        final student = controller.recentScans[index];

                        return Card(
                          color: Colors.white,
                          elevation: 3,
                          margin: const EdgeInsets.only(bottom: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.blue,
                              child: Text(
                                student.rollNo.isEmpty
                                    ? "-"
                                    : student.rollNo.substring(0, 1),
                                style: const TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            title: Text(
                              student.displayName,
                              textDirection: Get.locale?.languageCode == "ur"
                                  ? ui.TextDirection.rtl
                                  : ui.TextDirection.ltr,
                              textAlign: Get.locale?.languageCode == "ur"
                                  ? TextAlign.right
                                  : TextAlign.left,
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${"Student ID".tr} ${student.displayId}",
                                ),
                                Text("${"Roll No :".tr} ${student.rollNo}"),
                                Text("${"Meal :".tr} ${student.mealType}"),
                                Text("${"Room :".tr} ${student.roomNo}"),
                              ],
                            ),
                            trailing: Text(
                              DateFormat("dd MMM yyyy hh:mm a").format(
                                DateTime.parse(student.scannedTime).toLocal(),
                              ),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }

  void _openScanner() {
    bool scanned = false;

    Get.bottomSheet(
      Container(
        height: Get.height * .85,
        decoration: const BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(25),
          ),
        ),
        child: Stack(
          children: [
            MobileScanner(
              controller: controller.scannerController,
              onDetect: (capture) {
                if (scanned) return;

                scanned = true;

                final barcode = capture.barcodes.first;

                final code = barcode.rawValue;

                if (code == null) return;

                Get.back();

                controller.handleScannedData(code);
              },
            ),
            Center(
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white,
                    width: 4,
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: const Icon(
                  Icons.close,
                  color: Colors.white,
                ),
                onPressed: () {
                  Get.back();
                },
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _mealCard(
    String title,
    int value,
    Color color,
    IconData icon,
  ) {
    return Card(
      elevation: 5,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(9),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 18,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 34,
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value.toString(),
              style: TextStyle(
                fontSize: 30,
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
