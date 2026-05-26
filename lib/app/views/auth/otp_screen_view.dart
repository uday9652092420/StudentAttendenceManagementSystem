import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_new_app/app/controllers/auth/otp_controller.dart';
import 'package:my_new_app/app/routes/app_routes.dart';

class OtpScreenView extends GetView<OtpController> {
  const OtpScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OTP Verification'),
      ),
      body: Center(
        child: TextButton(
          onPressed: () {
            Get.toNamed(Routes.langeSelection);
          },
          child: const Text('OTP Screen - Under Construction'),
        ),
      ),
    );
  }
}
