import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../routes/app_routes.dart';

class LoginController extends GetxController {
  final TextEditingController usernameController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  RxBool isLoading = false.obs;

  void login() {
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      Get.snackbar(
        "Validation",
        "Please enter username and password",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (username == "uday" && password == "uday123") {
      Get.offAllNamed(Routes.dashboard);
    } else {
      Get.snackbar(
        "Login Failed",
        "Invalid Username or Password",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  void onClose() {
    usernameController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
