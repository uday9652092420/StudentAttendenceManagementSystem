import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_new_app/app/controllers/dashboard/teacherattendance_controller.dart';

class TeacherAttendanceCheckoutView
    extends GetView<StaffAttendanceSessionController> {
  const TeacherAttendanceCheckoutView({super.key});

  String _value(Map<String, dynamic> data, List<String> keys,
      {String fallback = "--"}) {
    for (final key in keys) {
      final value = data[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }
    return fallback;
  }

  String _formatTime(String value) {
    if (value == "--") return value;
    try {
      final date = DateTime.parse(value)
          .toUtc()
          .add(const Duration(hours: 5, minutes: 30));
      final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
      final suffix = date.hour >= 12 ? "PM" : "AM";
      return "$hour:${date.minute.toString().padLeft(2, '0')} $suffix";
    } catch (_) {
      return value;
    }
  }

  Map<String, dynamic> _session(Map<String, dynamic> response) {
    final data = response["data"];
    if (data is Map && data["session"] is Map) {
      return Map<String, dynamic>.from(data["session"] as Map);
    }
    if (data is Map) return Map<String, dynamic>.from(data);
    if (response["session"] is Map) {
      return Map<String, dynamic>.from(response["session"] as Map);
    }
    return response;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f7fb),
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        centerTitle: true,
        title: const Text("Confirm Check Out"),
      ),
      body: Obx(() {
        final session = _session(controller.sessionData);
        final className = _value(
          session,
          ["className", "classroomName", "class_name"],
          fallback: "Class unavailable",
        );
        final teacherName = _value(
          session,
          ["teacherName", "staffName", "teacher_name"],
          fallback: "Teacher",
        );
        final checkIn = _formatTime(
          _value(session, ["checkedInAt", "checkInAt"]),
        );
        final checkedOut = _value(
          session,
          ["checkedOutAt", "checkOutAt"],
          fallback: "Pending",
        );
        final isCheckedOut = checkedOut != "Pending";

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "$className • $teacherName",
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(child: _timeColumn("Check-in", checkIn)),
                      Expanded(
                        child: _timeColumn(
                          "Check-out",
                          isCheckedOut ? _formatTime(checkedOut) : "Pending",
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _card(
              color: Colors.green.shade50,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Ready to check out?",
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Your check-out time is recorded when you confirm.",
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 12),
                  _timeColumn("Check-in", checkIn),
                  const SizedBox(height: 8),
                  _timeColumn("Check-out", "On confirmation"),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _card(
              color: Colors.blue.shade50,
              child: const Text(
                "The classroom will be released after successful check-out. "
                "The next teacher can then check in.",
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: isCheckedOut || controller.isLoading.value
                    ? null
                    : controller.checkOut,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade700,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: controller.isLoading.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text("Confirm Check Out"),
              ),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: Get.back,
              child: const Text("Back"),
            ),
          ],
        );
      }),
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

  Widget _timeColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey.shade600)),
        const SizedBox(height: 3),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }
}
