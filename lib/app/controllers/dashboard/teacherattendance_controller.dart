import 'package:get/get.dart';
import 'package:my_new_app/app/helpers/flutter_toast.dart';
import 'package:my_new_app/app/repositories/teacherstundentattendance/attendance_repository.dart';

class StaffAttendanceSessionController extends GetxController {
  final AttendanceRepository repository = AttendanceRepository();

  final RxBool isLoading = false.obs;

  final RxMap<String, dynamic> sessionData = <String, dynamic>{}.obs;

  String sessionId = "";

  @override
  void onInit() {
    super.onInit();

    final Map<String, dynamic> args =
        (Get.arguments as Map<String, dynamic>?) ?? {};

    sessionId = args["sessionId"]?.toString() ?? "";

    if (sessionId.isEmpty) {
      errorToast("Attendance session not found.");
      return;
    }

    loadSession();
  }

  Future<void> loadSession() async {
    try {
      isLoading.value = true;

      final response = await repository.getStaffAttendanceSession(
        sessionId: sessionId,
      );

      print("SESSION STATUS = ${response?.statusCode}");
      print("SESSION BODY = ${response?.data}");

      if (response != null && response.statusCode == 200) {
        final data = response.data;

        if (data is Map<String, dynamic>) {
          sessionData.assignAll(data);
        } else {
          errorToast("Invalid attendance session response.");
        }
      } else {
        errorToast(
          _getErrorMessage(
            response?.data,
            "Failed to load attendance session",
          ),
        );
      }
    } catch (e) {
      print("SESSION ERROR = $e");
      errorToast(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> checkOut() async {
    if (sessionId.isEmpty) {
      errorToast("Attendance session not found.");
      return;
    }

    try {
      isLoading.value = true;

      final requestId = "checkout-${DateTime.now().millisecondsSinceEpoch}";

      final response = await repository.checkOutStaffAttendance(
        sessionId: sessionId,
        requestId: requestId,
      );

      print("CHECKOUT STATUS = ${response?.statusCode}");
      print("CHECKOUT BODY = ${response?.data}");

      if (response != null &&
          (response.statusCode == 200 || response.statusCode == 201)) {
        successToast("Checked out successfully");

        await loadSession();
      } else {
        errorToast(
          _getErrorMessage(
            response?.data,
            "Failed to check out",
          ),
        );
      }
    } catch (e) {
      print("CHECKOUT ERROR = $e");
      errorToast(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  String _getErrorMessage(
    dynamic data,
    String defaultMessage,
  ) {
    if (data is Map) {
      final message = data["message"];

      if (message != null && message.toString().trim().isNotEmpty) {
        return message.toString();
      }
    }

    return defaultMessage;
  }
}
