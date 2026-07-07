class EndPoints {
  // Auth
  static const apipostlogin = 'user-master/auth/login';

  // Gate Pass
  static const getGatePassDetails = 'hostel-in-out-movements/gate-pass-id/';

  // Create Movement
  static const saveMovement = 'hostel-in-out-movements';

  // Get/Update Movement
  static const updateMovement = 'hostel-in-out-movements';

  static const classroomdetails = "attendance/periodwise/context/";
  static const classroomstudentsdetails = "attendance/periodwise/students/";

  static const hostelblocksstructure = "hostel-rooms/blocks-structure";
  static const hostelFloorAttendance =
      "hostel-night-attendance/session/by-filter";

  static const floorwisestudents = "hostel-night-attendance/session/";
  static const saveAttendance = "hostel-night-attendance";
}
