import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../controllers/securitycontrollers/security_dashboard_controller.dart';
import '../../custome_widgets/logout.dart';
import '../../routes/app_routes.dart';

class SecurityDashboard extends StatelessWidget {
  SecurityDashboard({super.key});

  final SecurityDashboardController controller =
      Get.put(SecurityDashboardController(), permanent: true);

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
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 80),
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
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await controller.pickQrFromGallery();
                    },
                    icon: const Icon(Icons.photo_library),
                    label: const Text(
                      "Upload QR Image",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
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
      SizedBox(
        height: Get.height * 0.85,
        child: Container(
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
                onDetect: (capture) async {
                  if (isScanned) return;

                  final barcode = capture.barcodes.first;

                  final String? code = barcode.rawValue;

                  if (code == null || code.isEmpty) return;

                  isScanned = true;

                  String gatePassId = "";

                  try {
                    final qrData = jsonDecode(code);

                    if (qrData is Map<String, dynamic>) {
                      gatePassId = qrData["gatePassId"]?.toString() ?? "";
                    }
                  } catch (_) {
                    gatePassId = code;
                  }

                  print("QR FROM CAMERA => $code");
                  print("EXTRACTED GATEPASS ID => $gatePassId");

                  if (gatePassId.isEmpty) {
                    Get.snackbar(
                      "Error",
                      "Gate Pass ID not found in QR",
                    );
                    isScanned = false;
                    return;
                  }

                  scannerController.dispose();

                  Get.back();

                  await controller.processScan(code);

                  Get.toNamed(
                    Routes.addMovement,
                    arguments: gatePassId,
                  );
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
                  onTap: () {
                    scannerController.dispose();
                    Get.back();
                  },
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
        ),
      ),
      isScrollControlled: true,
    );
  }
}
