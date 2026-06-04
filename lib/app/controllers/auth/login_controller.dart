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
      errorToast(
        "Please enter username and password",
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
        errorToast(
          "Unable to connect to server",
        );
        return;
      }

      print("STATUS => ${response.statusCode}");
      print("BODY => ${response.data}");

      if (response.statusCode == 200) {
        final data = response.data;

        final accessToken = data["accessToken"]?.toString() ?? "";

        if (accessToken.isEmpty) {
          errorToast(
            "Login failed: No access token received",
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

        successToast(
          "Login Successful",
        );

        Get.offAllNamed(Routes.dashboard);
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
