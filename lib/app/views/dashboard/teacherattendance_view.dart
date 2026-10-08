import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_new_app/app/controllers/dashboard/teacherattendance_controller.dart';

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
    if (value.isEmpty) {
      return "--";
    }

    try {
      final dateTime = DateTime.parse(value).toLocal();

      final hour = dateTime.hour;
      final minute = dateTime.minute;

      final period = hour >= 12 ? "PM" : "AM";
      final displayHour = hour % 12 == 0 ? 12 : hour % 12;

      return "$displayHour:"
          "${minute.toString().padLeft(2, '0')} $period";
    } catch (_) {
      return value;
    }
  }

  String _getPeriodText(Map<String, dynamic> session) {
    final value = _readValue(
      session,
      [
        "periodNumber",
        "period",
        "periodNo",
        "period_number",
      ],
      defaultValue: "1",
    );

    if (value.toLowerCase().startsWith("period")) {
      return value;
    }

    return "Period $value";
  }

  String _getClassName(Map<String, dynamic> session) {
    return _readValue(
      session,
      [
        "className",
        "classroomName",
        "classroom",
        "class_name",
        "class",
      ],
      defaultValue: "Class A",
    );
  }

  String _getSubjectName(Map<String, dynamic> session) {
    return _readValue(
      session,
      [
        "subjectName",
        "subject",
        "courseName",
        "course",
        "subject_name",
      ],
      defaultValue: "Arabic",
    );
  }

  String _getStartTime(Map<String, dynamic> session) {
    return _readValue(
      session,
      [
        "startTime",
        "periodStartTime",
        "start_time",
        "period_start_time",
      ],
      defaultValue: "09:00",
    );
  }

  String _getEndTime(Map<String, dynamic> session) {
    return _readValue(
      session,
      [
        "endTime",
        "periodEndTime",
        "end_time",
        "period_end_time",
      ],
      defaultValue: "09:40",
    );
  }

  String _getCheckIn(Map<String, dynamic> session) {
    return _readValue(
      session,
      [
        "checkInAt",
        "checkInTime",
        "check_in_at",
        "check_in_time",
      ],
    );
  }

  String _getCheckOut(Map<String, dynamic> session) {
    return _readValue(
      session,
      [
        "checkOutAt",
        "checkOutTime",
        "check_out_at",
        "check_out_time",
      ],
    );
  }

  int _getCount(
    Map<String, dynamic> session,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = session[key];

      if (value is int) {
        return value;
      }

      if (value != null) {
        final parsed = int.tryParse(value.toString());

        if (parsed != null) {
          return parsed;
        }
      }
    }

    return 0;
  }

  Map<String, int> _getAttendanceCounts(
    Map<String, dynamic> session,
  ) {
    int present = _getCount(
      session,
      [
        "presentCount",
        "present",
        "present_count",
      ],
    );

    int absent = _getCount(
      session,
      [
        "absentCount",
        "absent",
        "absent_count",
      ],
    );

    /*
     * If backend returns student attendance list,
     * calculate counts from it.
     */
    dynamic students;

    if (session["students"] is List) {
      students = session["students"];
    } else if (session["attendance"] is List) {
      students = session["attendance"];
    } else if (session["studentAttendance"] is List) {
      students = session["studentAttendance"];
    }

    if (students is List && students.isNotEmpty) {
      present = 0;
      absent = 0;

      for (final item in students) {
        if (item is! Map) {
          continue;
        }

        final status = (item["status"] ?? "").toString().trim().toUpperCase();

        if (status == "P" || status == "PRESENT") {
          present++;
        } else if (status == "A" || status == "ABSENT") {
          absent++;
        }
      }
    }

    return {
      "present": present,
      "absent": absent,
    };
  }

  Widget _borderCard({
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: Colors.blue.shade200,
          width: 1.5,
        ),
      ),
      child: child,
    );
  }

  Future<void> _checkOut() async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: const Text(
          "Check Out",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          "Are you sure you want to check out from this session?",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back(result: false);
            },
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back(result: true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text("Check Out"),
          ),
        ],
      ),
    );

    if (result == true) {
      await controller.checkOut();
    }
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
        title: Obx(() {
          final session = _getSession(
            controller.sessionData,
          );

          final className = _getClassName(session);

          return Text(
            "$className • Active Session",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 20,
            ),
          );
        }),
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

        final startTime = _getStartTime(session);
        final endTime = _getEndTime(session);

        final checkIn = _getCheckIn(session);
        final checkOut = _getCheckOut(session);

        final counts = _getAttendanceCounts(session);

        final present = counts["present"] ?? 0;
        final absent = counts["absent"] ?? 0;

        final bool checkedOut = checkOut.trim().isNotEmpty;

        String periodTime;

        if (startTime.contains(":") && endTime.contains(":")) {
          periodTime = "${_formatTime(startTime)}–${_formatTime(endTime)}";
        } else {
          periodTime = "$startTime–$endTime";
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
                        "Attendance saved",
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "$periodText • "
                        "$present Present, $absent Absent",
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // -------------------------------------------------
                // PERIOD CARD
                // -------------------------------------------------
                _borderCard(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "$periodText • $subjectName",
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 7),
                            Text(
                              "$periodTime • $subjectName",
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "Saved",
                        style: TextStyle(
                          color: Colors.green.shade600,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // -------------------------------------------------
                // EDIT PERIOD ATTENDANCE
                // -------------------------------------------------
                SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: OutlinedButton(
                    onPressed: () {
                      /*
                       * Connect this to the existing
                       * Student Attendance screen.
                       *
                       * We should pass:
                       *   classroomId
                       *   sessionId
                       *   period information
                       *
                       * once the backend response structure
                       * is confirmed.
                       */
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
                    child: Text(
                      "Edit $periodText Attendance",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // -------------------------------------------------
                // CONTINUE TO PERIOD 2
                // -------------------------------------------------
                SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: ElevatedButton(
                    onPressed: () {
                      /*
                       * Do not create the next period locally.
                       *
                       * The backend controls the active
                       * timetable period.
                       *
                       * We will connect this after confirming
                       * the /sessions/current response.
                       */
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      "Continue to ${_nextPeriodText(periodText)}",
                      style: const TextStyle(
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
                    onPressed: checkedOut ? null : _checkOut,
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
                    "Edit attendance anytime. Check Out records "
                    "your exit without scanning QR again.",
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

  String _nextPeriodText(String periodText) {
    final match = RegExp(
      r'(\d+)',
    ).firstMatch(periodText);

    if (match == null) {
      return "Period 2";
    }

    final current = int.tryParse(match.group(1)!) ?? 1;

    return "Period ${current + 1}";
  }
}
