class EndPoints {
  // Auth
  static const apipostlogin = 'user-master/auth/login';

  // Gate Pass
  static const getGatePassDetails = 'hostel-in-out-movements/gate-pass-id/';

  // Create Movement
  static const saveMovement = 'hostel-in-out-movements';

  // Get/Update Movement
  static const updateMovement = 'hostel-in-out-movements';

  // Teacher Attendance
  static const classroomdetails = "attendance/periodwise/context/";
  static const classroomstudentsdetails = "attendance/periodwise/students/";
  static const saveAttendance = "attendance/periodwise";
  static const staffPeriodAttendanceQrScan = "staff-period-attendance/qr-scan";

  // Hostel
  static const hostelblocksstructure = "hostel-rooms/blocks-structure";
  static const hostelFloorAttendance =
      "hostel-night-attendance/session/by-filter";
  static const floorwisestudents = "hostel-night-attendance/session/";

  // Students
  static const getStudents = "students/master";

  // Masjid Attendance
  static const saveMasjidAttendance = "masjid-attendance";

  // Kitchen
  static const kitchenStudentByQr = "kitchen-meal-forecast/qr/student/";

  static const kitchenDashboard = "kitchen-meal-forecast/dashboard";

  static const sponsorDashboard = "sponsor-dashboard";
  static const String staffAttendanceSessions =
      "staff-period-attendance/sessions";
  static const String staffAttendanceStudentAttendance =
      "staff-period-attendance/sessions";

  static const String staffAttendanceCheckIn =
      "staff-period-attendance/sessions/check-in";
  static const String staffAttendanceSessionHistory =
      "staff-period-attendance/sessions/history";
}
