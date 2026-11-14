import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_new_app/app/helpers/flutter_toast.dart';
import 'package:my_new_app/app/helpers/shared_preferences.dart';
import 'package:my_new_app/app/models/dashboard/login_model.dart';
import 'package:my_new_app/app/repositories/auth_repository.dart';
import '../../routes/app_routes.dart';

class LoginController extends GetxController {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  final AuthRepository authRepository = AuthRepository();

  RxBool isLoading = false.obs;

  Future<void> login() async {
    if (usernameController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty) {
      errorToast("Please enter username and password".tr);
      return;
    }

    try {
      isLoading.value = true;

      final request = LoginModel(
        username: usernameController.text.trim(),
        password: passwordController.text.trim(),
      );

      final response = await authRepository
          .postlogin(request.toJson())
          .timeout(const Duration(seconds: 20));
      if (response.statusCode == 200) {
        final data = response.data;

        final accessToken = data["accessToken"]?.toString() ?? "";
        final roleName = data["roleName"]?.toString() ?? "";
        final username = data["username"]?.toString() ?? "";
        final fullName = data["fullName"]?.toString() ?? "";
        final userId = data["id"]?.toString() ?? "";

        final role = roleName.trim().toLowerCase();
        final responseRoleNames = data["roleNames"];
        final roleNames = responseRoleNames is List
            ? responseRoleNames
                .map((value) => value?.toString().trim() ?? "")
                .where((value) => value.isNotEmpty)
                .toList()
            : <String>[];
        if (roleNames.isEmpty && roleName.trim().isNotEmpty) {
          roleNames.add(roleName.trim());
        }
        await SharedPrefsHelper.setList("roleNames", roleNames);

        // Save Staff Id
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
          await SharedPrefsHelper.remove("staffId");
          print("NO STAFF ID FOUND");
        }

        // Save Token
        await SharedPrefsHelper.setString(
          SharedPrefsHelper.accessToken,
          accessToken,
        );

        print("ACCESS TOKEN SAVED => ${accessToken.isNotEmpty}");

        // Save Common User Details
        await SharedPrefsHelper.setString("username", username);
        await SharedPrefsHelper.setString("fullName", fullName);
        await SharedPrefsHelper.setString("roleName", roleName);

        // Save User Id for modules that require it
        if (role.contains("masjid incharge") ||
            role.contains("sponsor") ||
            (roleNames.length > 1 &&
                roleNames.any((name) {
                  final normalizedName = name.toLowerCase();
                  return normalizedName.contains("masjid incharge") ||
                      normalizedName.contains("sponsor");
                }))) {
          await SharedPrefsHelper.setString(
            "userId",
            userId,
          );

          print("USER ID SAVED => $userId");
        }

        successToast("Login Successful".tr);

        print("ROLE => $roleName");
        print("ROLE => $role");

        if (roleNames.length > 1) {
          Get.offAllNamed(
            Routes.multiRoleUserDashboard,
            arguments: {
              "roleNames": roleNames,
              "fullName": fullName,
            },
          );
          return;
        }

        // Navigate according to role
        if (role.contains("security")) {
          Get.offAllNamed(Routes.securityDashboard);
        } else if (role.contains("warden")) {
          Get.offAllNamed(Routes.WARDEN_ATTENDANCE);
        } else if (role.contains("teacher") || role.contains("lecturer")) {
          Get.offAllNamed(Routes.dashboard);
        } else if (role.contains("kitchen")) {
          Get.offAllNamed(Routes.kitchenDashboard);
        } else if (role.contains("masjid incharge")) {
          Get.offAllNamed(Routes.masjidDashboard);
        } else if (role.contains("sponsor")) {
          Get.offAllNamed(Routes.sponsorDashboard);
        } else {
          errorToast("Role not supported.".tr);
        }
      } else {
        errorToast("Invalid Username or Password".tr);
      }
    } on TimeoutException {
      errorToast(
          "Login request timed out. Please check your connection and try again."
              .tr);
    } catch (e) {
      print("LOGIN ERROR => $e");
      errorToast("Invalid Username or Password".tr);
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
