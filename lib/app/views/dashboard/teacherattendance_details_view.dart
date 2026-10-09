import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_new_app/app/controllers/dashboard/teacherattendance_details_controller.dart';
import 'package:my_new_app/app/models/dashboard/teacher_attendance_session_details_model.dart';
import 'package:my_new_app/app/helpers/flutter_toast.dart';
import 'package:my_new_app/app/routes/app_routes.dart';

class TeacherAttendanceDetailsView
    extends GetView<TeacherAttendanceDetailsController> {
  const TeacherAttendanceDetailsView({super.key});

  String _periodName(TeacherAttendanceSessionDetails details) {
    final current = details.currentPeriod;
    if (current is String && current.trim().isNotEmpty) return current;
    if (current is Map) {
      final name =
          current["period"] ?? current["periodName"] ?? current["periodNumber"];
      if (name != null && name.toString().trim().isNotEmpty) {
        return name.toString();
      }
    }
    return "Current period unavailable";
  }

  String _time(String? value) {
    if (value == null || value.isEmpty) return "Pending";
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

  String _studentValue(Map<String, dynamic> student, List<String> keys) {
    for (final key in keys) {
      final value = student[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }
    return "";
  }

  String _status(Map<String, dynamic> student) {
    final value = _studentValue(
      student,
      ["status", "attendanceStatus", "attendance_status"],
    ).trim().toUpperCase();
    switch (value) {
      case "P":
      case "PRESENT":
        return "Present";
      case "A":
      case "ABSENT":
        return "Absent";
      case "L":
      case "LEAVE":
        return "Leave";
      case "S":
      case "SICK":
        return "Sick";
      default:
        return value.isEmpty ? "Not recorded" : value;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case "Present":
        return Colors.green.shade700;
      case "Absent":
        return Colors.red.shade700;
      case "Leave":
        return Colors.blue.shade700;
      case "Sick":
        return Colors.orange.shade800;
      default:
        return Colors.grey.shade700;
    }
  }

  Widget _infoCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f7fb),
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        centerTitle: true,
        title: const Text("Teacher Attendance"),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.value.isNotEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    controller.errorMessage.value,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: controller.loadSessionDetails,
                    icon: const Icon(Icons.refresh),
                    label: const Text("Retry"),
                  ),
                  TextButton(
                    onPressed: Get.back,
                    child: const Text("Back to Attendance"),
                  ),
                ],
              ),
            ),
          );
        }

        final details = controller.details.value;
        if (details == null) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text("Attendance session details are unavailable."),
            ),
          );
        }

        final periodName = _periodName(details);
        final subjectName = details.courseName ?? "Subject unavailable";
        final className = details.className ?? "Class unavailable";
        final checkedOut = details.checkedOutAt?.isNotEmpty == true;
        final students = controller.studentAttendance;

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            _infoCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "$className • $periodName",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (details.teacherName?.isNotEmpty == true) ...[
                    const SizedBox(height: 5),
                    Text(details.teacherName!),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _timeColumn(
                          "Check-in",
                          _time(details.checkedInAt),
                        ),
                      ),
                      Expanded(
                        child: _timeColumn(
                          "Check-out",
                          checkedOut ? _time(details.checkedOutAt) : "Pending",
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _infoCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Teacher Attendance Details",
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  if (details.teacherName?.isNotEmpty == true)
                    _detailLine("Teacher", details.teacherName!),
                  if (details.attendanceDate?.isNotEmpty == true)
                    _detailLine("Date", details.attendanceDate!),
                  _detailLine("Current period", periodName),
                  _detailLine("Subject", subjectName),
                  if (details.roomId?.isNotEmpty == true)
                    _detailLine("Room", details.roomId!),
                ],
              ),
            ),
            if (details.periods.isNotEmpty) ...[
              const SizedBox(height: 12),
              for (final period in details.periods)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _infoCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (period["period"] ?? "Period").toString(),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        if (period["subjectName"] != null ||
                            period["subject"] != null)
                          Text((period["subjectName"] ?? period["subject"])
                              .toString()),
                        if (period["checkedInAt"] != null ||
                            period["checkedOutAt"] != null ||
                            period["entry_time"] != null ||
                            period["exit_time"] != null)
                          Text(
                            "Entry ${_time((period["checkedInAt"] ?? period["entry_time"])?.toString())}"
                            " • Exit ${_time((period["checkedOutAt"] ?? period["exit_time"])?.toString())}",
                            style: TextStyle(color: Colors.grey.shade700),
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
                    ),
                  ),
                ),
            ],
            const SizedBox(height: 12),
            if (students.isNotEmpty) ...[
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Saved Student Register",
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              for (final student in students)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _infoCard(
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _studentValue(
                                  student,
                                  [
                                    "studentName",
                                    "name",
                                    "fullName",
                                    "full_name",
                                  ],
                                ).isEmpty
                                    ? "Student"
                                    : _studentValue(
                                        student,
                                        [
                                          "studentName",
                                          "name",
                                          "fullName",
                                          "full_name",
                                        ],
                                      ),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (_studentValue(student, [
                                "admissionNumber",
                                "admissionNo",
                                "admission_number",
                                "admission_no",
                                "rollNumber",
                                "rollNo",
                              ]).isNotEmpty)
                                Text(
                                  "Admission no: ${_studentValue(student, [
                                        "admissionNumber",
                                        "admissionNo",
                                        "admission_number",
                                        "admission_no",
                                        "rollNumber",
                                        "rollNo",
                                      ])}",
                                ),
                              if (_studentValue(student, ["studentId"])
                                  .isNotEmpty)
                                Text("ID: ${_studentValue(student, [
                                      "studentId"
                                    ])}"),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          _status(student),
                          style: TextStyle(
                            color: _statusColor(_status(student)),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ] else ...[
              _infoCard(
                child: Text(
                  controller.studentAttendanceError.value.isNotEmpty
                      ? controller.studentAttendanceError.value
                      : "No saved student attendance records were returned.",
                  style: TextStyle(color: Colors.grey.shade700),
                ),
              ),
            ],
            const SizedBox(height: 16),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: checkedOut || controller.isCheckingOut.value
                    ? null
                    : () {
                        final sessionId = controller.sessionId.trim();
                        if (sessionId.isEmpty) {
                          errorToast("Attendance session ID is missing.");
                          return;
                        }
                        Get.toNamed(
                          Routes.staffAttendanceConfirmCheckout,
                          arguments: {"sessionId": sessionId},
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade700,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: controller.isCheckingOut.value
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(checkedOut ? "Checked Out" : "Check Out"),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 52,
              child: OutlinedButton(
                onPressed: Get.back,
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.blue,
                  side: BorderSide(color: Colors.blue.shade100),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text("Back to Attendance"),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Check out when you leave the classroom.\n"
              "Your times appear in attendance history.",
              style: TextStyle(color: Colors.grey.shade600, height: 1.4),
            ),
          ],
        );
      }),
    );
  }

  Widget _timeColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey.shade600)),
        const SizedBox(height: 3),
        Text(
          value,
          style: const TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _detailLine(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 7),
      child: Text(
        "$label: $value",
        style: TextStyle(color: Colors.grey.shade700),
      ),
    );
  }
}
