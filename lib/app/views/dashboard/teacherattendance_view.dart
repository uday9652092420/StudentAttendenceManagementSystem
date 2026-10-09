import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_new_app/app/controllers/dashboard/teacherattendance_controller.dart';
import 'package:my_new_app/app/helpers/flutter_toast.dart';
import 'package:my_new_app/app/routes/app_routes.dart';

class StaffAttendanceSessionView
    extends GetView<StaffAttendanceSessionController> {
  const StaffAttendanceSessionView({super.key});

  String _readValue(
    Map<String, dynamic> data,
    List<String> keys, {
    String defaultValue = "",
  }) {
    for (final key in keys) {
      final value = data[key];

      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }

    return defaultValue;
  }

  Map<String, dynamic> _getSession(
    Map<String, dynamic> data,
  ) {
    final session = data["session"];

    if (session is Map) {
      return Map<String, dynamic>.from(session);
    }

    final dataValue = data["data"];

    if (dataValue is Map) {
      if (dataValue["session"] is Map) {
        return Map<String, dynamic>.from(
          dataValue["session"],
        );
      }

      return Map<String, dynamic>.from(dataValue);
    }

    return data;
  }

  String _formatTime(String value) {
    if (value.isEmpty) return "--";
    try {
      final dateTime = DateTime.parse(value)
          .toUtc()
          .add(const Duration(hours: 5, minutes: 30));
      final hour = dateTime.hour;
      final minute = dateTime.minute;
      final suffix = hour >= 12 ? "PM" : "AM";
      final displayHour = hour % 12 == 0 ? 12 : hour % 12;
      return "$displayHour:${minute.toString().padLeft(2, '0')} $suffix";
    } catch (_) {
      return value;
    }
  }

  Map<String, dynamic> _periodData(Map<String, dynamic> session) {
    final period = session["currentPeriod"];
    return period is Map ? Map<String, dynamic>.from(period) : session;
  }

  String _getPeriodText(Map<String, dynamic> session) {
    final currentPeriod = session["currentPeriod"];
    final value = _readValue(
      _periodData(session),
      ["periodNumber", "period", "periodNo", "period_number"],
      defaultValue: currentPeriod is String ? currentPeriod : "",
    );
    if (value.isEmpty) return "Period unavailable";
    return value.toLowerCase().startsWith("period") ? value : "Period $value";
  }

  String _getClassName(Map<String, dynamic> session) => _readValue(
        session,
        ["className", "classroomName", "classroom", "class_name", "class"],
        defaultValue: "Class unavailable",
      );

  String _getSubjectName(Map<String, dynamic> session) {
    final period = _periodData(session);
    final subjectValue = period["subject"];
    final subject = subjectValue is Map
        ? _readValue(
            Map<String, dynamic>.from(subjectValue), ["name", "subjectName"])
        : _readValue(
            period, ["subjectName", "subject", "courseName", "course"]);
    return subject.isEmpty ? "Subject unavailable" : subject;
  }

  String _getTeacherName(Map<String, dynamic> session) => _readValue(
        session,
        ["teacherName", "staffName", "teacher_name", "staff_name"],
      );

  String _getStartTime(Map<String, dynamic> session) => _readValue(
        _periodData(session),
        ["startTime", "periodStartTime", "start_time", "period_start_time"],
      );

  String _getEndTime(Map<String, dynamic> session) => _readValue(
        _periodData(session),
        ["endTime", "periodEndTime", "end_time", "period_end_time"],
      );

  String _getCheckIn(Map<String, dynamic> session) => _readValue(
        session,
        [
          "checkedInAt",
          "checkInAt",
          "checkInTime",
          "check_in_at",
          "check_in_time"
        ],
      );

  String _getCheckOut(Map<String, dynamic> session) => _readValue(
        session,
        [
          "checkedOutAt",
          "checkOutAt",
          "checkOutTime",
          "check_out_at",
          "check_out_time"
        ],
      );

  Widget _borderCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.blue.shade200, width: 1.5),
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f7fb),
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.blue,
        automaticallyImplyLeading: false,
        title: Obx(
          () => Text(
            controller.studentAttendanceSaved.value
                ? "Attendance Saved"
                : "Teacher Attendance",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 20,
            ),
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.sessionData.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (controller.sessionData.isEmpty) {
          return const Center(
            child: Text(
              "Unable to load attendance session.",
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          );
        }

        final session = _getSession(
          controller.sessionData,
        );

        final className = _getClassName(session);
        final periodText = _getPeriodText(session);
        final subjectName = _getSubjectName(session);
        final teacherName = _getTeacherName(session);

        final startTime = _getStartTime(session);
        final endTime = _getEndTime(session);

        final checkIn = _getCheckIn(session);
        final checkOut = _getCheckOut(session);

        final bool checkedOut = checkOut.trim().isNotEmpty;

        String periodTime;

        if (startTime.isNotEmpty && endTime.isNotEmpty) {
          periodTime = "${_formatTime(startTime)}–${_formatTime(endTime)}";
        } else {
          periodTime = "Timetable time unavailable";
        }

        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              20,
              20,
              20,
              30,
            ),
            child: Column(
              children: [
                // -------------------------------------------------
                // CLASS / PERIOD / CHECK-IN / CHECK-OUT
                // -------------------------------------------------
                _borderCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "$className • $periodText",
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "$subjectName • $periodTime",
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                      if (teacherName.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          "Teacher: $teacherName",
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Check in",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black54,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  checkIn.isEmpty ? "--" : _formatTime(checkIn),
                                  style: const TextStyle(
                                    fontSize: 17,
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Check out",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black54,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  checkedOut
                                      ? _formatTime(checkOut)
                                      : "Not checked out",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // -------------------------------------------------
                // ATTENDANCE SAVED
                // -------------------------------------------------
                if (controller.studentAttendanceSaved.value)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      border: Border.all(
                        color: Colors.blue.shade200,
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Student attendance saved",
                          style: TextStyle(
                            color: Colors.green.shade700,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "The saved student register is read-only.",
                          style: TextStyle(
                            color: Colors.green.shade700,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (controller.missingCheckout.value ||
                    session["missingCheckout"] == true) ...[
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    color: Colors.orange.shade50,
                    child: const Text(
                      "This session is missing a checkout from an earlier day. "
                      "It is not recorded as a completed check-in for today.",
                      style: TextStyle(color: Colors.deepOrange),
                    ),
                  ),
                ],

                const SizedBox(height: 10),

                // -------------------------------------------------
                // VIEW SAVED ATTENDANCE
                // -------------------------------------------------
                SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: OutlinedButton(
                    onPressed: () {
                      final sessionId = controller.sessionId.trim();
                      if (sessionId.isEmpty) {
                        errorToast("Attendance session ID is missing.");
                        return;
                      }

                      Get.toNamed(
                        Routes.staffAttendanceDetails,
                        arguments: {"sessionId": sessionId},
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.blue,
                      side: BorderSide(
                        color: Colors.blue.shade200,
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "View Attendance Details",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // -------------------------------------------------
                // CHECK OUT
                // -------------------------------------------------
                SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: ElevatedButton(
                    onPressed: checkedOut
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
                      disabledBackgroundColor: Colors.grey.shade400,
                      foregroundColor: Colors.white,
                      disabledForegroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      checkedOut ? "Checked Out" : "Check Out",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // -------------------------------------------------
                // INFORMATION TEXT
                // -------------------------------------------------
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 2,
                    vertical: 4,
                  ),
                  child: const Text(
                    "Your check-in remains recorded.\n"
                    "Period records follow the timetable automatically.",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
