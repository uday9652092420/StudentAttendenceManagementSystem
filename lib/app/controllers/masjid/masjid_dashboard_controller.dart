import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:my_new_app/app/helpers/flutter_toast.dart';
import 'package:my_new_app/app/models/masjid/studentmodel.dart';
import 'package:my_new_app/app/repositories/masjidattendance/masjid_attendance_repository.dart';

class MasjidAttendanceOption {
  final String id;
  final String name;

  const MasjidAttendanceOption({
    required this.id,
    required this.name,
  });

  factory MasjidAttendanceOption.fromJson(
    Map<String, dynamic> json, {
    required List<String> idKeys,
    required List<String> nameKeys,
  }) {
    return MasjidAttendanceOption(
      id: _firstValue(json, idKeys),
      name: _firstValue(json, nameKeys),
    );
  }

  static String _firstValue(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }
    return "";
  }
}

class MasjidDashboardController extends GetxController {
  final MasjidRepository repository = MasjidRepository();

  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;
  final RxBool attendanceTaken = false.obs;
  final RxBool isEditing = false.obs;
  final RxBool showSavedAttendanceSummary = false.obs;

  final RxString currentDate = "".obs;
  final RxString currentTime = "".obs;
  final RxString savedAttendanceDate = "".obs;
  final RxString selectedPrayer = "Fajr".obs;
  final RxString selectedCourseId = "".obs;
  final RxString selectedClassId = "".obs;
  final RxString sessionId = "".obs;

  final RxList<MasjidAttendanceOption> courses = <MasjidAttendanceOption>[].obs;
  final RxList<MasjidAttendanceOption> classes = <MasjidAttendanceOption>[].obs;
  final RxList<MasjidStudentModel> students = <MasjidStudentModel>[].obs;
  final RxList<MasjidStudentModel> filteredStudents =
      <MasjidStudentModel>[].obs;

  final searchController = TextEditingController();

  final List<String> prayers = [
    "Fajr",
    "Zohar",
    "Asar",
    "Maghrib",
    "Isha",
  ];

  String get attendanceDate => DateFormat("yyyy-MM-dd").format(DateTime.now());
  int get presentStudentCount =>
      students.where((student) => student.isPresent.value).length;

  @override
  void onInit() {
    super.onInit();
    loadDateTime();
    autoPrayer();
    loadCourses();
  }

  Future<void> loadCourses() async {
    try {
      isLoading.value = true;
      final response = await repository.getCourses();
      if (response == null || response.statusCode != 200) {
        errorToast("Unable to load courses.".tr);
        return;
      }

      courses.assignAll(
        _extractRows(response.data, const ["courses", "items"])
            .map(
              (row) => MasjidAttendanceOption.fromJson(
                row,
                idKeys: const ["courseId", "course_id", "id"],
                nameKeys: const [
                  "courseName",
                  "course_name",
                  "name",
                  "title",
                ],
              ),
            )
            .where((option) => option.id.isNotEmpty)
            .toList(),
      );

      if (courses.isEmpty) {
        errorToast("No courses found.".tr);
        return;
      }

      selectedCourseId.value = courses.first.id;
      await loadClasses();
    } catch (error) {
      errorToast("Unable to load courses.".tr);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> selectCourse(String courseId) async {
    if (courseId == selectedCourseId.value) return;
    selectedCourseId.value = courseId;
    selectedClassId.value = "";
    classes.clear();
    _clearAttendance();
    await loadClasses();
  }

  Future<void> loadClasses() async {
    if (selectedCourseId.value.isEmpty) return;
    try {
      isLoading.value = true;
      final response = await repository.getClasses(selectedCourseId.value);
      if (response == null || response.statusCode != 200) {
        errorToast("Unable to load classes.".tr);
        return;
      }

      classes.assignAll(
        _extractRows(response.data, const ["classes", "items"])
            .map(
              (row) => MasjidAttendanceOption.fromJson(
                row,
                idKeys: const ["classId", "class_id", "id"],
                nameKeys: const [
                  "className",
                  "class_name",
                  "name",
                  "title",
                ],
              ),
            )
            .where((option) => option.id.isNotEmpty)
            .toList(),
      );

      if (classes.isEmpty) {
        selectedClassId.value = "";
        _clearAttendance();
        errorToast("No classes found for this course.".tr);
        return;
      }

      selectedClassId.value = classes.first.id;
      await loadAttendanceForSelection();
    } catch (error) {
      errorToast("Unable to load classes.".tr);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> selectClass(String classId) async {
    if (classId == selectedClassId.value) return;
    selectedClassId.value = classId;
    await loadAttendanceForSelection();
  }

  Future<void> selectPrayer(String prayer) async {
    if (prayer == selectedPrayer.value) return;
    selectedPrayer.value = prayer;
    await loadAttendanceForSelection();
  }

  Future<void> loadAttendanceForSelection() async {
    if (selectedCourseId.value.isEmpty || selectedClassId.value.isEmpty) {
      _clearAttendance();
      return;
    }

    try {
      isLoading.value = true;
      _clearAttendance();

      final loadResponse = await repository.loadMasjidAttendance(
        date: attendanceDate,
        prayerType: selectedPrayer.value,
        classId: selectedClassId.value,
      );
      if (loadResponse == null || loadResponse.statusCode != 200) {
        errorToast("Unable to load students for this class.".tr);
        return;
      }

      final loadRoot = _asMap(loadResponse.data);
      final loadData = _unwrapData(loadResponse.data);
      final roster = _extractRows(
        loadResponse.data,
        const ["students", "attendanceStudents", "roster"],
      );

      final sessionsResponse = await repository.getAttendanceSessions();
      if (sessionsResponse == null || sessionsResponse.statusCode != 200) {
        errorToast("Unable to check existing attendance.".tr);
        return;
      }

      final matchingSession = _extractRows(
        sessionsResponse.data,
        const ["sessions", "attendanceSessions", "attendance", "items"],
      ).cast<Map<String, dynamic>?>().firstWhere(
            (session) => session != null && _matchesSelection(session),
            orElse: () => null,
          );
      final sessionIdFromLoad = _findSessionId(_asMap(loadData));
      var existingSessionId =
          matchingSession == null ? "" : _findSessionId(matchingSession);
      if (existingSessionId.isEmpty) {
        existingSessionId = sessionIdFromLoad.isNotEmpty
            ? sessionIdFromLoad
            : _findSessionId(loadRoot);
      }
      final hasAttendance = matchingSession != null ||
          _reportsAttendance(loadRoot) ||
          _reportsAttendance(_asMap(loadData)) ||
          existingSessionId.isNotEmpty;

      if (hasAttendance) {
        if (existingSessionId.isEmpty) {
          errorToast("Existing attendance session could not be identified.".tr);
          return;
        }

        final detailResponse =
            await repository.getAttendanceSession(existingSessionId);
        if (detailResponse == null || detailResponse.statusCode != 200) {
          errorToast("Unable to load saved attendance.".tr);
          return;
        }

        final detailStudents = _extractRows(
          detailResponse.data,
          const ["students", "attendanceStudents", "roster"],
        );
        sessionId.value = existingSessionId;
        attendanceTaken.value = true;
        isEditing.value = false;
        savedAttendanceDate.value = _displayDate(
          _firstValue(_asMap(_unwrapData(detailResponse.data)), const [
            "attendanceDate",
            "attendance_date",
            "date",
          ]),
        );
        _assignStudents(detailStudents.isEmpty ? roster : detailStudents);
        showSavedAttendanceSummary.value = true;
        if (students.isEmpty) {
          errorToast("No students found for this attendance session.".tr);
        }
        return;
      }

      _assignStudents(roster);
      if (students.isEmpty) {
        errorToast("No students found for this class.".tr);
      }
    } catch (error) {
      errorToast("Unable to load attendance.".tr);
    } finally {
      isLoading.value = false;
    }
  }

  void loadDateTime() {
    final now = DateTime.now();
    currentDate.value = DateFormat("dd MMM yyyy").format(now);
    currentTime.value = DateFormat("hh:mm a").format(now);
  }

  void autoPrayer() {
    final hour = DateTime.now().hour;

    if (hour >= 4 && hour < 8) {
      selectedPrayer.value = "Fajr";
    } else if (hour >= 12 && hour < 15) {
      selectedPrayer.value = "Zohar";
    } else if (hour >= 15 && hour < 18) {
      selectedPrayer.value = "Asar";
    } else if (hour >= 18 && hour < 20) {
      selectedPrayer.value = "Maghrib";
    } else {
      selectedPrayer.value = "Isha";
    }
  }

  void searchStudent(String value) {
    if (value.isEmpty) {
      filteredStudents.assignAll(students);
      return;
    }

    filteredStudents.assignAll(
      students.where(
        (student) =>
            student.studentName.toLowerCase().contains(value.toLowerCase()) ||
            student.studentId.toLowerCase().contains(value.toLowerCase()),
      ),
    );
  }

  void _assignStudents(List<Map<String, dynamic>> rows) {
    students.assignAll(rows.map(MasjidStudentModel.fromJson));
    searchStudent(searchController.text);
  }

  void _clearAttendance() {
    sessionId.value = "";
    attendanceTaken.value = false;
    isEditing.value = false;
    showSavedAttendanceSummary.value = false;
    savedAttendanceDate.value = "";
    students.clear();
    filteredStudents.clear();
  }

  void startEditingAttendance() {
    isEditing.value = true;
    showSavedAttendanceSummary.value = false;
  }

  Map<String, dynamic> _attendanceBody() {
    return {
      "attendanceDate": attendanceDate,
      "prayerType": selectedPrayer.value,
      "courseId": selectedCourseId.value,
      "classId": selectedClassId.value,
      "students": students
          .map(
            (student) => {
              "studentId": student.studentId,
              "studentName": student.studentName,
              "attendanceStatus":
                  student.isPresent.value ? "Present" : "Absent",
            },
          )
          .toList(),
    };
  }

  Future<void> saveAttendance() async {
    if (students.isEmpty) {
      errorToast("No students are available to save.".tr);
      return;
    }
    if (selectedCourseId.value.isEmpty || selectedClassId.value.isEmpty) {
      errorToast("Select a course and class first.".tr);
      return;
    }

    try {
      isSaving.value = true;
      final response = await repository.saveMasjidAttendance(_attendanceBody());
      if (response == null ||
          (response.statusCode != 200 && response.statusCode != 201)) {
        errorToast("Unable to save attendance.".tr);
        return;
      }

      attendanceTaken.value = true;
      isEditing.value = false;
      sessionId.value = _findSessionId(_asMap(_unwrapData(response.data)));
      if (sessionId.value.isEmpty) {
        await _findSavedSessionId();
      }
      savedAttendanceDate.value = currentDate.value;
      showSavedAttendanceSummary.value = true;
      successToast("Attendance saved successfully.".tr);
    } catch (error) {
      errorToast("Unable to save attendance.".tr);
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> _findSavedSessionId() async {
    final response = await repository.getAttendanceSessions();
    if (response == null || response.statusCode != 200) {
      errorToast("Attendance saved, but its session could not be loaded.".tr);
      return;
    }
    final match = _extractRows(
      response.data,
      const ["sessions", "attendanceSessions", "attendance", "items"],
    ).where(_matchesSelection);
    if (match.isNotEmpty) {
      sessionId.value = _findSessionId(match.first);
    }
    if (sessionId.value.isEmpty) {
      errorToast(
          "Attendance saved, but its session could not be identified.".tr);
    }
  }

  Future<void> updateAttendance() async {
    if (sessionId.value.isEmpty) {
      errorToast("Attendance session not found.".tr);
      return;
    }
    if (students.isEmpty) {
      errorToast("No students are available to update.".tr);
      return;
    }

    try {
      isSaving.value = true;
      final response = await repository.updateMasjidAttendance(
        sessionId.value,
        _attendanceBody(),
      );
      if (response == null ||
          (response.statusCode != 200 &&
              response.statusCode != 201 &&
              response.statusCode != 204)) {
        errorToast("Unable to update attendance.".tr);
        return;
      }

      isEditing.value = false;
      showSavedAttendanceSummary.value = true;
      successToast("Attendance updated successfully.".tr);
    } catch (error) {
      errorToast("Unable to update attendance.".tr);
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> cancelEditing() async {
    isEditing.value = false;
    await loadAttendanceForSelection();
  }

  String _displayDate(String value) {
    if (value.isEmpty) return currentDate.value;
    try {
      return DateFormat("dd MMM yyyy").format(DateTime.parse(value));
    } on FormatException {
      return value;
    }
  }

  Future<void> deleteAttendance() async {
    if (sessionId.value.isEmpty) {
      errorToast("Attendance session not found.".tr);
      return;
    }

    try {
      isSaving.value = true;
      final response = await repository.deleteMasjidAttendance(sessionId.value);
      if (response == null ||
          (response.statusCode != 200 &&
              response.statusCode != 202 &&
              response.statusCode != 204)) {
        errorToast("Unable to delete attendance.".tr);
        return;
      }

      successToast("Attendance deleted successfully.".tr);
      _clearAttendance();
      await loadAttendanceForSelection();
    } catch (error) {
      errorToast("Unable to delete attendance.".tr);
    } finally {
      isSaving.value = false;
    }
  }

  bool _matchesSelection(Map<String, dynamic> session) {
    final sessionDate = _firstValue(session, const [
      "attendanceDate",
      "attendance_date",
      "date",
    ]);
    final sessionPrayer = _firstValue(session, const [
      "prayerType",
      "prayer_type",
      "prayer",
    ]);
    final sessionClassId = _firstValue(session, const [
      "classId",
      "class_id",
    ]);
    final sessionCourseId =
        _firstValue(session, const ["courseId", "course_id"]);

    return sessionDate.startsWith(attendanceDate) &&
        sessionPrayer.toLowerCase() == selectedPrayer.value.toLowerCase() &&
        sessionClassId == selectedClassId.value &&
        (sessionCourseId.isEmpty || sessionCourseId == selectedCourseId.value);
  }

  bool _reportsAttendance(Map<String, dynamic> value) {
    for (final key in const [
      "attendanceTaken",
      "hasAttendance",
      "alreadyTaken",
    ]) {
      final status = value[key];
      if (status == true || status?.toString().toLowerCase() == "true") {
        return true;
      }
    }
    return false;
  }

  String _findSessionId(Map<String, dynamic> value) {
    return _firstValue(value, const [
      "sessionId",
      "session_id",
      "attendanceSessionId",
      "attendance_session_id",
      "attendanceId",
      "attendance_id",
      "id",
    ]);
  }

  String _firstValue(Map<String, dynamic> value, List<String> keys) {
    for (final key in keys) {
      final item = value[key];
      if (item != null && item.toString().trim().isNotEmpty) {
        return item.toString();
      }
    }
    return "";
  }

  dynamic _unwrapData(dynamic value) {
    var current = value;
    for (var depth = 0; depth < 4; depth++) {
      if (current is Map && current["data"] != null) {
        current = current["data"];
      } else if (current is Map && current["session"] != null) {
        current = current["session"];
      } else {
        break;
      }
    }
    return current;
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return {};
  }

  List<Map<String, dynamic>> _extractRows(
    dynamic value,
    List<String> listKeys,
  ) {
    final unwrapped = _unwrapData(value);
    if (unwrapped is List) {
      return unwrapped.whereType<Map>().map(_asMap).toList();
    }
    if (unwrapped is! Map) return [];

    final map = _asMap(unwrapped);
    for (final key in listKeys) {
      final rows = map[key];
      if (rows is List) {
        return rows.whereType<Map>().map(_asMap).toList();
      }
    }
    return [];
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
