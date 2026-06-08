import 'package:get/get.dart';

import '../../helpers/shared_preferences.dart';
import '../../models/security/secuity_dashboardmodel.dart';
import '../../services/api_service.dart';

class SecurityDashboardController extends GetxController {
  final ApiService apiService = ApiService();

  RxBool isLoading = false.obs;

  Future<void> processScan(String qrCode) async {
    try {
      isLoading.value = true;

      final username =
          await SharedPrefsHelper.getString("username") ?? "Security";

      final scanModel = GatepassScanModel(
        qrCode: qrCode,
        securityName: username,
        scanTime: DateTime.now().toIso8601String(),
      );

      print("SCAN DATA => ${scanModel.toJson()}");

      /// API CALL
      await apiService.validateGatepass(
        scanModel.toJson(),
      );

      Get.snackbar(
        "Success",
        "Gatepass scanned successfully",
      );

      /// Navigate to details screen later
      // Get.toNamed(Routes.gatepassDetails);
    } catch (e) {
      Get.snackbar(
        "Error",
        e.toString(),
      );
    } finally {
      isLoading.value = false;
    }
  }
}
