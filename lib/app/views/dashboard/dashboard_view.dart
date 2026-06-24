import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_new_app/app/controllers/dashboard/dashboard_controller.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:my_new_app/app/routes/app_routes.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    void _openScanner() {
      final MobileScannerController scannerController =
          MobileScannerController();

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
                  onDetect: (capture) {
                    if (isScanned) return;

                    final barcode = capture.barcodes.first;

                    final String? code = barcode.rawValue;

                    if (code == null) return;

                    isScanned = true;

                    scannerController.dispose();

                    Get.back();

                    Future.delayed(
                      const Duration(milliseconds: 300),
                      () {
                        controller.handleScannedData(code);
                      },
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

    return Scaffold(
      backgroundColor: const Color(0xfff5f7fb),
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.blue,
        title: const Text(
          "Student Attendance Management",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.logout,
              color: Colors.white,
            ),
            onPressed: () {
              Get.defaultDialog(
                title: "Logout",
                middleText: "Are you sure you want to logout?",
                textConfirm: "Logout",
                textCancel: "Cancel",
                confirmTextColor: Colors.white,
                buttonColor: Colors.blue,
                onConfirm: () async {
                  /// Clear saved data
                  // await SharedPrefsHelper.remove("accessToken");
                  // await SharedPrefsHelper.remove("username");
                  // await SharedPrefsHelper.remove("roleName");

                  Get.back();

                  /// Redirect Login Screen
                  Get.offAllNamed(Routes.login);
                },
              );
            },
          ),
        ],
      ),
      // appBar: AppBar(
      //   elevation: 0,
      //   centerTitle: true,
      //   backgroundColor: Colors.blue,
      //   title: const Text(
      //     "Student Attendance Management",
      //     style: TextStyle(
      //       fontWeight: FontWeight.bold,
      //       color: Colors.white,
      //       fontSize: 20,
      //     ),
      //   ),
      // ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                /// IMAGE
                Container(
                  height: 220,
                  margin: const EdgeInsets.only(top: 150),
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
                    Icons.qr_code_scanner_outlined,
                    size: 130,
                    color: Colors.blue,
                  ),
                ),

                const SizedBox(height: 40),

                /// HEADING
                const Text(
                  "Scan to Get Classroom Details",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                const Text(
                  "Use the QR scanner to fetch classroom information and mark attendance instantly.",
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
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                // /// BUTTON
                // SizedBox(
                //   width: double.infinity,
                //   height: 55,
                //   child: ElevatedButton.icon(
                //     onPressed: () {
                //       final MobileScannerController scannerController =
                //           MobileScannerController();

                //       bool isScanned = false;

                //       Get.bottomSheet(
                //         StatefulBuilder(
                //           builder: (context, setState) {
                //             return Container(
                //               height: Get.height * 0.85,
                //               decoration: const BoxDecoration(
                //                 color: Colors.black,
                //                 borderRadius: BorderRadius.vertical(
                //                   top: Radius.circular(25),
                //                 ),
                //               ),
                //               child: Stack(
                //                 children: [
                //                   /// CAMERA SCANNER
                //                   MobileScanner(
                //                     controller: scannerController,
                //                     onDetect: (capture) {
                //                       if (isScanned) return;

                //                       final barcode = capture.barcodes.first;

                //                       final String? code = barcode.rawValue;

                //                       if (code == null) return;
                //                       isScanned = true;

                //                       Get.back();

                //                       Future.delayed(
                //                           const Duration(milliseconds: 300),
                //                           () {
                //                         controller.handleScannedData(code);
                //                       });

                //                       // isScanned = true;

                //                       // controller.handleScannedData(code);

                //                       // Get.back();
                //                     },
                //                   ),

                //                   /// SCAN BOX
                //                   Center(
                //                     child: Container(
                //                       width: 260,
                //                       height: 260,
                //                       decoration: BoxDecoration(
                //                         border: Border.all(
                //                           color: Colors.white,
                //                           width: 4,
                //                         ),
                //                         borderRadius: BorderRadius.circular(20),
                //                       ),
                //                     ),
                //                   ),

                //                   /// CLOSE BUTTON
                //                   Positioned(
                //                     top: 40,
                //                     right: 20,
                //                     child: GestureDetector(
                //                       onTap: () {
                //                         Get.back();
                //                       },
                //                       child: Container(
                //                         padding: const EdgeInsets.all(10),
                //                         decoration: BoxDecoration(
                //                           color: Colors.white.withOpacity(0.2),
                //                           shape: BoxShape.circle,
                //                         ),
                //                         child: const Icon(
                //                           Icons.close,
                //                           color: Colors.white,
                //                         ),
                //                       ),
                //                     ),
                //                   ),
                //                 ],
                //               ),
                //             );
                //           },
                //         ),
                //         isScrollControlled: true,
                //       );
                //     },
                //     icon: const Icon(Icons.qr_code_scanner),
                //     label: const Text(
                //       "Scan QR",
                //       style: TextStyle(
                //         fontSize: 18,
                //         fontWeight: FontWeight.bold,
                //       ),
                //     ),
                //     style: ElevatedButton.styleFrom(
                //       backgroundColor: Colors.blue,
                //       foregroundColor: Colors.white,
                //       shape: RoundedRectangleBorder(
                //         borderRadius: BorderRadius.circular(14),
                //       ),
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
