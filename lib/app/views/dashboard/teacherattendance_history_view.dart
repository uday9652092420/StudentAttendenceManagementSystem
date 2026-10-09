import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_new_app/app/controllers/dashboard/teacherattendance_history_controller.dart';
import 'package:my_new_app/app/routes/app_routes.dart';

class TeacherAttendanceHistoryView
    extends GetView<TeacherAttendanceHistoryController> {
  const TeacherAttendanceHistoryView({super.key});

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

  String _time(dynamic value) {
    if (value == null || value.toString().isEmpty) return "Pending";
    try {
      final date = DateTime.parse(value.toString())
          .toUtc()
          .add(const Duration(hours: 5, minutes: 30));
      final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
      final suffix = date.hour >= 12 ? "PM" : "AM";
      return "$hour:${date.minute.toString().padLeft(2, '0')} $suffix";
    } catch (_) {
      return value.toString();
    }
  }

  String _date(dynamic value) {
    if (value == null || value.toString().isEmpty) return "--";
    final text = value.toString();
    if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(text)) return text;
    try {
      final date = DateTime.parse(text)
          .toUtc()
          .add(const Duration(hours: 5, minutes: 30));
      return "${date.day.toString().padLeft(2, '0')} "
          "${_month(date.month)} ${date.year}";
    } catch (_) {
      return text;
    }
  }

  String _month(int month) => const [
        "Jan",
        "Feb",
        "Mar",
        "Apr",
        "May",
        "Jun",
        "Jul",
        "Aug",
        "Sep",
        "Oct",
        "Nov",
        "Dec",
      ][month - 1];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f7fb),
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        centerTitle: true,
        title: const Text("Attendance History"),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.sessions.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.sessions.isEmpty &&
            controller.errorMessage.value.isNotEmpty) {
          return _emptyError(controller.errorMessage.value);
        }
        if (controller.sessions.isEmpty) {
          return const Center(child: Text("No attendance history found."));
        }

        return NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification.metrics.pixels >=
                    notification.metrics.maxScrollExtent - 160 &&
                !controller.isLoadingMore.value &&
                controller.hasMore) {
              controller.loadHistory();
            }
            return false;
          },
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              for (final session in controller.sessions) _sessionCard(session),
              if (controller.isLoadingMore.value)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                ),
              if (controller.errorMessage.value.isNotEmpty)
                TextButton(
                  onPressed: () => controller.loadHistory(),
                  child: Text(controller.errorMessage.value),
                ),
              const SizedBox(height: 8),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: () => Get.offAllNamed(Routes.dashboard),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("Check In to Another Class"),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _sessionCard(Map<String, dynamic> session) {
    final teacher = _value(session, ["teacherName", "staffName"]);
    final className = _value(session, ["className", "classroomName"]);
    final date = _date(session["attendanceDate"] ?? session["date"]);
    final checkIn = _time(session["checkedInAt"] ?? session["checkInAt"]);
    final checkedOutValue = session["checkedOutAt"] ?? session["checkOutAt"];
    final checkedOut =
        checkedOutValue == null || checkedOutValue.toString().isEmpty
            ? "Pending"
            : _time(checkedOutValue);
    final periods = session["periods"];

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$className • ${_value(session, [
                  "periodSummary"
                ], fallback: "Teacher Attendance")}",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 5),
          if (teacher != "--") Text("Teacher: $teacher"),
          Text("Date: $date"),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: Text("Check-in: $checkIn")),
              Expanded(child: Text("Check-out: $checkedOut")),
            ],
          ),
          if (periods is List)
            for (final period in periods.whereType<Map>()) ...[
              const Divider(height: 18),
              Text(
                "${period["period"] ?? "Period"} • "
                "${period["subject"] ?? period["subjectName"] ?? "Subject unavailable"}",
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(
                "Entry ${_time(period["entry_time"] ?? period["entryTime"])}"
                " • Exit ${_time(period["exit_time"] ?? period["exitTime"])}",
                style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
              ),
              if (period["review_required"] == true ||
                  period["reviewRequired"] == true)
                const Text(
                  "Management review required",
                  style: TextStyle(
                    color: Colors.deepOrange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
        ],
      ),
    );
  }

  Widget _emptyError(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => controller.loadHistory(reset: true),
              icon: const Icon(Icons.refresh),
              label: const Text("Retry"),
            ),
          ],
        ),
      ),
    );
  }
}
