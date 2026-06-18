import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_new_app/app/helpers/flutter_toast.dart';
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
      errorToast("Please enter username and password");
      return;
    }

    try {
      isLoading.value = true;

      /// SECURITY GUARD STATIC LOGIN
      if (usernameController.text.trim() == "security" &&
          passwordController.text.trim() == "security123") {
        await SharedPrefsHelper.setString(
          "username",
          "uday",
        );

        await SharedPrefsHelper.setString(
          "roleName",
          "security",
        );

        successToast("Security Login Successful");

        Get.offAllNamed(
          Routes.securityDashboard,
        );

        return;
      }

      /// WARDEN STATIC LOGIN
      if (usernameController.text.trim() == "warden" &&
          passwordController.text.trim() == "warden123") {
        await SharedPrefsHelper.setString(
          "username",
          "warden",
        );

        await SharedPrefsHelper.setString(
          "roleName",
          "warden",
        );

        successToast("Warden Login Successful");

        Get.offAllNamed(
          Routes.WARDEN_ATTENDANCE,
        );

        return;
      }

      /// TEACHER LOGIN API
      final request = LoginModel(
        username: usernameController.text.trim(),
        password: passwordController.text.trim(),
      );

      final response = await authRepository.postlogin(
        request.toJson(),
      );

      if (response == null) {
        errorToast("Unable to connect to server");
        return;
      }

      if (response.statusCode == 200) {
        final data = response.data;

        final accessToken = data["accessToken"]?.toString() ?? "";

        final roleName = data["roleName"]?.toString() ?? "";

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
          roleName,
        );

        successToast("Login Successful");

        /// ROLE BASED NAVIGATION
        if (roleName.toLowerCase() == "security") {
          Get.offAllNamed(
            Routes.securityDashboard,
          );
        } else {
          Get.offAllNamed(
            Routes.dashboard,
          );
        }
      } else {
        errorToast(
          "Invalid Username or Password",
        );
      }
    } catch (e) {
      print("LOGIN ERROR => $e");
      errorToast(
        "Invalid Username or Password",
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
