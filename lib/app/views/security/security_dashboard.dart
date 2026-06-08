import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../helpers/shared_preferences.dart';
import '../../routes/app_routes.dart';

class SecurityDashboard extends StatelessWidget {
  const SecurityDashboard({super.key});

  Future<void> logout() async {
    await SharedPrefsHelper.remove("username");
    await SharedPrefsHelper.remove("roleName");
    await SharedPrefsHelper.remove(
      SharedPrefsHelper.accessToken,
    );

    Get.offAllNamed(Routes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f7fb),
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.blue,
        title: const Text(
          "Security Management",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Get.defaultDialog(
                title: "Logout",
                middleText: "Are you sure you want to logout?",
                textConfirm: "Yes",
                textCancel: "No",
                confirmTextColor: Colors.white,
                buttonColor: Colors.blue,
                onConfirm: () async {
                  Get.back();
                  await logout();
                },
              );
            },
            icon: const Icon(
              Icons.logout,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 100),

                /// QR CARD
                Container(
                  height: 220,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.qr_code_scanner,
                    size: 120,
                    color: Colors.blue,
                  ),
                ),

                const SizedBox(height: 40),

                const Text(
                  "Scan to Validate Gatepass",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                const Text(
                  "Use the QR scanner to verify gatepass details and validate student or visitor entry instantly.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.black87,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 50),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _openScanner();
                    },
                    icon: const Icon(Icons.qr_code_scanner),
                    label: const Text(
                      "Scan QR",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openScanner() {
    final MobileScannerController scannerController = MobileScannerController();

    bool isScanned = false;

    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setState) {
          return Container(
            height: Get.height * 0.85,
            decoration: const BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(25),
              ),
            ),
            child: Stack(
              children: [
                MobileScanner(
                  controller: scannerController,
                  onDetect: (capture) {
                    if (isScanned) return;

                    final barcode = capture.barcodes.first;
                    final String? code = barcode.rawValue;

                    if (code == null) return;

                    isScanned = true;

                    Get.back();

                    Get.snackbar(
                      "Gatepass Scanned",
                      code,
                      snackPosition: SnackPosition.BOTTOM,
                    );

                    /// TODO:
                    /// Call Gatepass Validation API here
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
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                Positioned(
                  top: 40,
                  right: 20,
                  child: GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      isScrollControlled: true,
    );
  }
}
