import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_new_app/app/controllers/dashboard/dashboard_controller.dart';
import 'package:my_new_app/app/routes/app_routes.dart';

class TeacherAttendanceBlockedView extends StatelessWidget {
  const TeacherAttendanceBlockedView({super.key});

  Map<String, dynamic> get _response {
    final arguments = Get.arguments;
    final response = arguments is Map ? arguments["response"] : null;
    return response is Map ? Map<String, dynamic>.from(response) : {};
  }

  String? _value(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = data[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final response = _response;
    final data = response["data"] is Map
        ? Map<String, dynamic>.from(response["data"] as Map)
        : response;
    final arguments = Get.arguments;
    final classroomId =
        arguments is Map ? arguments["classroomId"]?.toString() ?? "" : "";
    final message = _value(response, ["message"]) ??
        "The previous teacher has not checked out of this classroom.";
    final teacherName = _value(data, ["teacherName", "staffName"]);
    final className = _value(data, ["className", "classroomName"]);
    final reviewRequired =
        data["review_required"] == true || data["reviewRequired"] == true;

    return Scaffold(
      backgroundColor: const Color(0xfff5f7fb),
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        centerTitle: true,
        title: const Text("Check In Blocked"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _card(
            color: Colors.red.shade50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Previous teacher has not checked out",
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(message),
                if (teacherName != null) _line("Teacher", teacherName),
                if (className != null) _line("Class", className),
                if (_value(data, ["checkedInAt", "checkInAt"]) case final time?)
                  _line("Check-in", time),
              ],
            ),
          ),
          if (reviewRequired) ...[
            const SizedBox(height: 10),
            _card(
              color: Colors.orange.shade50,
              child: const Text("Management review required."),
            ),
          ],
          const SizedBox(height: 12),
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: classroomId.isEmpty
                  ? null
                  : () async {
                      if (Get.isRegistered<DashboardController>()) {
                        final dashboard = Get.find<DashboardController>();
                        Get.back();
                        await dashboard.retryCheckIn(classroomId);
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text("Retry Check In"),
            ),
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: () => Get.back(),
            child: const Text("Back"),
          ),
          const SizedBox(height: 12),
          Text(
            "The timetable does not release the classroom while a "
            "teacher session is open.",
            style: TextStyle(color: Colors.grey.shade600, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _card({required Widget child, Color color = Colors.white}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }

  Widget _line(String label, String value) => Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Text("$label: $value"),
      );
}
