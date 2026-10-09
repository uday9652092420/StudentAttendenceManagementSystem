class TeacherAttendanceSessionDetails {
  const TeacherAttendanceSessionDetails({
    required this.sessionId,
    required this.staffId,
    required this.classId,
    required this.className,
    required this.courseName,
    required this.teacherName,
    required this.attendanceDate,
    required this.status,
    required this.checkedInAt,
    required this.checkedOutAt,
    required this.currentPeriod,
    required this.roomId,
    required this.periods,
    required this.savedStudentAttendance,
    required this.hasSavedStudentAttendance,
    required this.canCheckOut,
    required this.rawData,
  });

  final String sessionId;
  final String? staffId;
  final String? classId;
  final String? className;
  final String? courseName;
  final String? teacherName;
  final String? attendanceDate;
  final String? status;
  final String? checkedInAt;
  final String? checkedOutAt;
  final Object? currentPeriod;
  final String? roomId;
  final List<Map<String, dynamic>> periods;
  final List<Map<String, dynamic>> savedStudentAttendance;
  final bool hasSavedStudentAttendance;
  final bool? canCheckOut;
  final Map<String, dynamic> rawData;

  factory TeacherAttendanceSessionDetails.fromResponse(
    dynamic response, {
    required String requestedSessionId,
  }) {
    if (response is! Map) {
      throw const FormatException(
        "Session details response must be a JSON object.",
      );
    }

    if (response["success"] == false) {
      throw SessionDetailsApiException(
        _readMessage(response) ?? "The server rejected the session request.",
      );
    }

    dynamic session = response["data"] is Map ? response["data"] : response;
    if (session is Map && session["data"] is Map) {
      session = session["data"];
    }
    if (session is Map && session["session"] is Map) {
      session = session["session"];
    }
    if (session is! Map || session.isEmpty) {
      throw const FormatException(
        "Session details response did not contain a session object.",
      );
    }

    final data = Map<String, dynamic>.from(session);
    final periods = _mapList(data["periods"]);
    final savedValue = data["savedStudentAttendance"];

    return TeacherAttendanceSessionDetails(
      sessionId: _string(data["sessionId"]) ?? requestedSessionId,
      staffId: _string(data["staffId"]),
      classId: _string(data["classId"]),
      className: _string(data["className"]),
      courseName: _string(data["courseName"] ?? data["subjectName"]),
      teacherName: _string(data["teacherName"] ?? data["staffName"]),
      attendanceDate: _string(data["attendanceDate"]),
      status: _string(data["status"]),
      checkedInAt: _string(data["checkedInAt"]),
      checkedOutAt: _string(data["checkedOutAt"]),
      currentPeriod: data["currentPeriod"],
      roomId: _string(data["roomId"]),
      periods: periods,
      savedStudentAttendance: _mapList(savedValue),
      hasSavedStudentAttendance: savedValue is List,
      canCheckOut: data["canCheckOut"] is bool ? data["canCheckOut"] : null,
      rawData: data,
    );
  }

  static String? _string(dynamic value) {
    if (value == null || value.toString().trim().isEmpty) return null;
    return value.toString();
  }

  static List<Map<String, dynamic>> _mapList(dynamic value) {
    if (value is! List) return const [];
    return value
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  static String? _readMessage(Map response) {
    final value = response["message"] ?? response["error"];
    if (value != null && value.toString().trim().isNotEmpty) {
      return value.toString();
    }
    final nested = response["data"];
    if (nested is Map) return _readMessage(nested);
    return null;
  }
}

class SessionDetailsApiException implements Exception {
  const SessionDetailsApiException(this.message);

  final String message;

  @override
  String toString() => message;
}
