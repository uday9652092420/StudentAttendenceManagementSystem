import 'package:get/get.dart';
import 'package:my_new_app/app/helpers/flutter_toast.dart';

import '../../helpers/shared_preferences.dart';
import '../../models/security/secuity_dashboardmodel.dart';
import '../../routes/app_routes.dart';
import '../../services/api_service.dart';

class SecurityDashboardController extends GetxController {
  final ApiService apiService = ApiService();

  RxBool isLoading = false.obs;

//logout
  Future<void> logout() async {
    await SharedPrefsHelper.remove("username");
    await SharedPrefsHelper.remove("roleName");
    await SharedPrefsHelper.remove(
      SharedPrefsHelper.accessToken,
    );

    Get.offAllNamed(Routes.login);
  }

  Future<void> processScan(String qrCode) async {
    try {
      isLoading.value = true;

      final username = await SharedPrefsHelper.getString(
            "username",
          ) ??
          "Security";

      final scanModel = GatepassScanModel(
        qrCode: qrCode,
        securityName: username,
        scanTime: DateTime.now().toIso8601String(),
      );

      print(
        "SCAN DATA => ${scanModel.toJson()}",
      );

      await apiService.validateGatepass(
        scanModel.toJson(),
      );

      successToast(
        "Gatepass scanned successfully",
      );
    } catch (e) {
      print("SCAN ERROR => $e");

      errorToast(e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
