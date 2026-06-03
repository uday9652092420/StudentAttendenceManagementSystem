import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_new_app/app/models/dashboard/login_model.dart';
import 'package:my_new_app/app/repositories/auth_repository.dart';
import 'package:my_new_app/app/helpers/shared_preferences.dart';
import '../../routes/app_routes.dart';

class LoginController extends GetxController {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  final AuthRepository authRepository = AuthRepository();

  RxBool isLoading = false.obs;

  Future<void> login() async {
    if (usernameController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty) {
      Get.snackbar(
        "Validation",
        "Please enter username and password",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isLoading.value = true;

      final request = LoginModel(
        username: usernameController.text.trim(),
        password: passwordController.text.trim(),
      );

      final response = await authRepository.postlogin(request.toJson());

      if (response == null) {
        Get.snackbar(
          "Error",
          "Unable to connect to server",
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      print("STATUS => ${response.statusCode}");
      print("BODY => ${response.data}");

      if (response.statusCode == 200) {
        final data = response.data;

        final accessToken = data["accessToken"]?.toString() ?? "";

        if (accessToken.isEmpty) {
          Get.snackbar(
            "Login Failed",
            "Token not received",
            snackPosition: SnackPosition.BOTTOM,
          );
          return;
        }

        await SharedPrefsHelper.setString(
          SharedPrefsHelper.accessToken,
          accessToken,
        );

        await SharedPrefsHelper.setString(
          "username",
          data["username"]?.toString() ?? "",
        );

        await SharedPrefsHelper.setString(
          "roleName",
          data["roleName"]?.toString() ?? "",
        );

        print("TOKEN SAVED => $accessToken");

        Get.snackbar(
          "Success",
          "Login Successful",
          snackPosition: SnackPosition.BOTTOM,
        );

        Get.offAllNamed(Routes.dashboard);
      } else {
        Get.snackbar(
          "Login Failed",
          "Invalid Username or Password",
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      print("LOGIN ERROR => $e");

      Get.snackbar(
        "Error",
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    usernameController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
