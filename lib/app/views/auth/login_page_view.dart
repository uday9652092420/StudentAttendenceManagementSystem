import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth/login_controller.dart';
import '../../custome_widgets/app_language_switcher.dart';

class LoginPageView extends GetView<LoginController> {
  const LoginPageView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff3f3f3),
      appBar: AppBar(
        backgroundColor: Colors.blue,
        centerTitle: true,
        title: Text(
          "Login".tr,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: const [AppLanguageSwitcher()],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 30,
          ),
          child: Column(
            children: [
              SizedBox(
                height: 140,
                width: 140,
                child: Image.asset(
                  'assets/images/logo.png',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "DARUL ULOOM SABEELUS SALAM".tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                ),
              ),
              const SizedBox(height: 40),
              TextField(
                controller: controller.usernameController,
                decoration: InputDecoration(
                  hintText: "Username".tr,
                  prefixIcon: const Icon(Icons.person),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: controller.passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: "Password".tr,
                  prefixIcon: const Icon(Icons.lock),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Obx(
                () => SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : () => controller.login(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: controller.isLoading.value
                        ? const SizedBox(
                            height: 25,
                            width: 25,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            ),
                          )
                        : Text(
                            "LOGIN".tr,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
