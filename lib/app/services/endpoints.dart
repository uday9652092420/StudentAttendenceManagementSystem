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

  // Hostel
  static const hostelblocksstructure = "hostel-rooms/blocks-structure";
  static const hostelFloorAttendance =
      "hostel-night-attendance/session/by-filter";
  static const floorwisestudents = "hostel-night-attendance/session/";

  // Students
  static const getStudents = "students/master";

  // Masjid Attendance
  static const saveMasjidAttendance = "masjid-attendance";
}
