import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:my_new_app/app/models/warden/HostelBlockModel.dart';
import 'package:my_new_app/app/models/warden/dashboardmodel.dart';
import 'package:my_new_app/app/repositories/wardenattendance/warden_repository.dart';

class WardenAttendanceDashboardController extends GetxController {
  RxBool isLoading = false.obs;

  final WardenRepository repository = WardenRepository();

  RxList<FloorAttendanceSummary> floorSummary = <FloorAttendanceSummary>[].obs;

  RxList<HostelBlockModel> blocks = <HostelBlockModel>[].obs;

  Rx<HostelBlockModel?> selectedBlock = Rx<HostelBlockModel?>(null);

  RxString selectedBlockId = "".obs;

  int get totalPresent => floorSummary.fold(0, (sum, e) => sum + e.present);

  int get totalAbsent => floorSummary.fold(0, (sum, e) => sum + e.absent);

  int get totalLeave => floorSummary.fold(0, (sum, e) => sum + e.leave);

  int get totalOutPass => floorSummary.fold(0, (sum, e) => sum + e.outPass);

  int get totalStudents =>
      floorSummary.fold(0, (sum, e) => sum + e.totalStudents);
  Rx<DateTime> selectedDate = DateTime.now().obs;

  @override
  void onInit() {
    super.onInit();
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    try {
      isLoading.value = true;

      final response = await repository.getBlocksStructure();

      if (response != null && response.statusCode == 200) {
        final List<dynamic> jsonList = response.data as List<dynamic>;

        print(response.data);
        blocks.assignAll(
          jsonList.map((e) => HostelBlockModel.fromJson(e)).toList(),
        );

        if (blocks.isNotEmpty) {
          selectedBlock.value = blocks.first;
          selectedBlockId.value = blocks.first.id;
          await loadFloorAttendanceSummary();
        }
      }
    } catch (e) {
      print("LOAD BLOCK ERROR : $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadFloorAttendanceSummary() async {
    floorSummary.clear();

    if (selectedBlock.value == null) return;

    final date = DateFormat("yyyy-MM-dd").format(selectedDate.value);

    for (final floor in selectedBlock.value!.floors) {
      print("==================================");
      print("DATE      : $date");
      print("BLOCK     : ${selectedBlock.value!.blockName}");
      print("FLOOR     : ${floor.floorLabel}");
      print("FLOOR ID  : ${floor.id}");

      final response = await repository.getFloorAttendanceSummary(
        buildingId: selectedBlock.value!.id,
        floorId: floor.id,
        date: date,
      );
      print("API RESPONSE : ${response?.data}");

      if (response != null && response.statusCode == 200) {
        if (response.data == null) {
          floorSummary.add(
            FloorAttendanceSummary(
              floorId: floor.id,
              floorName: floor.floorLabel,
              totalStudents: 0,
              present: 0,
              absent: 0,
              leave: 0,
              outPass: 0,
              sessionStatus: "Not Taken",
            ),
          );

          continue;
        }

        final Map<String, dynamic> data = response.data as Map<String, dynamic>;

        final List entries = data["entries"] ?? [];

        final present =
            entries.where((e) => e["attendance_status"] == "present").length;

        final absent =
            entries.where((e) => e["attendance_status"] == "absent").length;

        final leave =
            entries.where((e) => e["attendance_status"] == "leave").length;

        final outPass =
            entries.where((e) => e["attendance_status"] == "outpass").length;

        floorSummary.add(
          FloorAttendanceSummary(
            floorId: floor.id,
            floorName: floor.floorLabel,
            totalStudents: entries.length,
            present: present,
            absent: absent,
            leave: leave,
            outPass: outPass,
            sessionStatus: data["session_status"] ?? "-",
          ),
        );
      }
    }
  }

  Future<void> changeBlock(String id) async {
    selectedBlockId.value = id;

    selectedBlock.value = blocks.firstWhere(
      (e) => e.id == id,
    );

    await loadFloorAttendanceSummary();
  }

  String get formattedDate =>
      DateFormat("dd/MM/yyyy").format(selectedDate.value);
}
