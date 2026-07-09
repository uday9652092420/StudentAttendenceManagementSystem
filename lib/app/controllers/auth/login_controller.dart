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

        final username = data["username"]?.toString() ?? "";

        final fullName = data["fullName"]?.toString() ?? "";

        final dynamic staffIdData = data["staffId"];

        if (staffIdData != null &&
            staffIdData.toString().trim().isNotEmpty &&
            staffIdData.toString().toLowerCase() != "null") {
          await SharedPrefsHelper.setString(
            "staffId",
            staffIdData.toString(),
          );

          print("STAFF ID SAVED => ${staffIdData.toString()}");
        } else {
          // Remove any previously saved teacher staffId
          await SharedPrefsHelper.remove("staffId");

          print("NO STAFF ID FOUND");
        }
        await SharedPrefsHelper.setString(
          SharedPrefsHelper.accessToken,
          accessToken,
        );

        await SharedPrefsHelper.setString(
          "username",
          username,
        );

        await SharedPrefsHelper.setString(
          "fullName",
          fullName,
        );

        await SharedPrefsHelper.setString(
          "roleName",
          roleName,
        );

        successToast("Login Successful");

        print("ROLE => $roleName");

        final role = roleName.trim().toLowerCase();

        print("ROLE => $role");

        if (role.contains("security")) {
          Get.offAllNamed(Routes.securityDashboard);
        } else if (role.contains("warden")) {
          Get.offAllNamed(Routes.WARDEN_ATTENDANCE);
        } else if (role.contains("teacher") || role.contains("lecturer")) {
          Get.offAllNamed(Routes.dashboard);
        } else if (role.contains("kitchen")) {
          Get.offAllNamed(Routes.messDashboard);
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
