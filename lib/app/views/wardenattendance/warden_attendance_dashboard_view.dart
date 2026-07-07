import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_new_app/app/controllers/warden/warden_attendance_dashboard_controller.dart';
import 'package:my_new_app/app/custome_widgets/logout.dart';
import 'package:my_new_app/app/routes/app_routes.dart';

class WardenAttendanceDashboardView
    extends GetView<WardenAttendanceDashboardController> {
  const WardenAttendanceDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.blue,
        //foregroundColor: Colors.black,
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Warden Dashboard",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            IconButton(
              onPressed: () {
                Get.defaultDialog(
                  title: "Logout",
                  middleText: "Are you sure you want to logout?",
                  textConfirm: "Yes",
                  textCancel: "No",
                  confirmTextColor: Colors.white,
                  buttonColor: Colors.blue,
                  onConfirm: () async {
                    Get.back();
                    await logout();
                  },
                );
              },
              icon: const Icon(
                Icons.logout,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (controller.blocks.isEmpty) {
          return const Center(
            child: Text("No Blocks Found"),
          );
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 6),

              Text(
                "Take and manage daily student attendance by floor.",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 15,
                ),
              ),

              const SizedBox(height: 20),

              /// FILTERS
              _buildFilters(),

              const SizedBox(height: 20),

              // /// SUMMARY
              // GridView.count(
              //   shrinkWrap: true,
              //   physics: const NeverScrollableScrollPhysics(),
              //   crossAxisCount: 2,
              //   crossAxisSpacing: 12,
              //   mainAxisSpacing: 12,
              //   childAspectRatio: 1.4,
              //   children: [
              //     _summaryCard(
              //       "Present",
              //       dashboard.present.toString(),
              //       Colors.green,
              //     ),
              //     _summaryCard(
              //       "Absent",
              //       dashboard.absent.toString(),
              //       Colors.red,
              //     ),
              //     _summaryCard(
              //       "Leave",
              //       dashboard.leave.toString(),
              //       Colors.blue,
              //     ),
              //     _summaryCard(
              //       "Out Pass",
              //       dashboard.outPass.toString(),
              //       Colors.purple,
              //     ),
              //   ],
              // ),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.4,
                children: [
                  _summaryCard(
                    "Present",
                    controller.totalPresent.toString(),
                    Colors.green,
                  ),
                  _summaryCard(
                    "Absent",
                    controller.totalAbsent.toString(),
                    Colors.red,
                  ),
                  _summaryCard(
                    "Leave",
                    controller.totalLeave.toString(),
                    Colors.blue,
                  ),
                  _summaryCard(
                    "Out Pass",
                    controller.totalOutPass.toString(),
                    Colors.purple,
                  ),
                ],
              ),

              const SizedBox(height: 20),

              /// FLOORS
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.floorSummary.length,
                itemBuilder: (context, index) {
                  final summary = controller.floorSummary[index];

                  return Card(
                    margin: const EdgeInsets.only(bottom: 14),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text(
                                "Floor : ",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  summary.floorName,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          // Text(
                          //   floor.floorName,
                          //   style: const TextStyle(
                          //     fontSize: 18,
                          //     fontWeight: FontWeight.bold,
                          //   ),
                          // ),
                          const SizedBox(height: 10),
                          const Divider(),

                          _infoRow(
                            "Total Students",
                            summary.totalStudents.toString(),
                          ),

                          _infoRow(
                            "Present",
                            summary.present.toString(),
                          ),

                          _infoRow(
                            "Absent",
                            summary.absent.toString(),
                          ),

                          _infoRow(
                            "Leave",
                            summary.leave.toString(),
                          ),

                          _infoRow(
                            "Out Pass",
                            summary.outPass.toString(),
                          ),

                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                const Expanded(
                                  flex: 2,
                                  child: Text(
                                    "Session",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    summary.sessionStatus,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: summary.sessionStatus == "locked"
                                          ? Colors.red
                                          : summary.sessionStatus == "submitted"
                                              ? Colors.green
                                              : Colors.orange,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 14),

                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text(
                                "Actions : ",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    Get.toNamed(
                                      Routes.takeAttendance,
                                      arguments: {
                                        "blockId":
                                            controller.selectedBlock.value!.id,
                                        "blockName": controller
                                            .selectedBlock.value!.blockName,
                                        "floorId": summary.floorId,
                                        "floorName": summary.floorName,
                                      },
                                    );
                                  },
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    height: 42,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: Colors.blue,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      "Take Attendance",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildFilters() {
    return Column(
      children: [
        _dateField(),
        const SizedBox(height: 10),
        _hostelDropdown(),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: () {
              Get.toNamed(
                Routes.takeAttendance,
                arguments: {
                  "blockId": controller.selectedBlock.value?.id,
                  "blockName": controller.selectedBlock.value?.blockName,
                },
              );
            },
            icon: const Icon(Icons.add),
            label: const Text(
              "Take Attendance",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _summaryCard(
    String title,
    String value,
    Color color,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(
    String title,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _dateField() {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: Get.context!,
          initialDate: controller.selectedDate.value,
          firstDate: DateTime(2024),
          lastDate: DateTime(2035),
        );

        if (picked != null) {
          controller.selectedDate.value = picked;
          controller.loadFloorAttendanceSummary();
        }
      },
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today),
            const SizedBox(width: 10),
            Obx(() => Text(controller.formattedDate)),
          ],
        ),
      ),
    );
  }

  Widget _hostelDropdown() {
    return Obx(() {
      return InputDecorator(
        decoration: InputDecoration(
          labelText: "Select Hostel / Block",
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: controller.selectedBlockId.value.isEmpty
                ? null
                : controller.selectedBlockId.value,
            isExpanded: true,
            hint: const Text("Select Block"),
            items: controller.blocks.map((block) {
              return DropdownMenuItem(
                value: block.id,
                child: Text(block.blockName),
              );
            }).toList(),
            onChanged: (value) async {
              if (value != null) {
                await controller.changeBlock(value);
              }
            },
          ),
        ),
      );
    });
  }
}
