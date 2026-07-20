import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:intl/intl.dart';
import 'package:my_new_app/app/helpers/shared_preferences.dart';
import 'package:my_new_app/app/routes/app_routes.dart';

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
        title: const Text(
          "Kitchen Supervisor Dashboard",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            color: Colors.white,
            onPressed: () async {
              final logout = await Get.dialog<bool>(
                AlertDialog(
                  title: const Text("Logout"),
                  content: const Text("Are you sure you want to logout?"),
                  actions: [
                    TextButton(
                      onPressed: () => Get.back(result: false),
                      child: const Text("Cancel"),
                    ),
                    ElevatedButton(
                      onPressed: () => Get.back(result: true),
                      child: const Text("Logout"),
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
                        const Text(
                          "Today's Date",
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

              /// Meal Dropdown
              DropdownButtonFormField<String>(
                initialValue: controller.selectedMeal.value,
                decoration: InputDecoration(
                  labelText: "Meal Type",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: controller.mealTypes
                    .map(
                      (e) => DropdownMenuItem(
                        value: e,
                        child: Text(e),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  controller.selectedMeal.value = value!;
                },
              ),

              const SizedBox(height: 25),

              /// Scan Button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.qr_code_scanner),
                  label: const Text(
                    "Scan Student QR",
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
                  label: const Text(
                    "Upload QR Image",
                    style: TextStyle(fontSize: 18),
                  ),
                  onPressed: () {
                    controller.pickQrFromGallery();
                  },
                ),
              ),

              const SizedBox(height: 25),

              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Recent Scans",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              controller.recentScans.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Text("No Records Found"),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controller.recentScans.length,
                      itemBuilder: (_, index) {
                        final student = controller.recentScans[index];

                        return Card(
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
                            title: Text(student.studentName),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Roll No : ${student.rollNo}"),
                                Text("Meal : ${student.mealType}"),
                                Text("Room : ${student.roomNo}"),
                              ],
                            ),
                            trailing: Text(
                              student.scannedTime,
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
