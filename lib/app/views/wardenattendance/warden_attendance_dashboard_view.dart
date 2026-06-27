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
              "Warden Attendance",
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

        final dashboard = controller.dashboard.value;

        if (dashboard == null) {
          return const Center(
            child: Text("No Data Found"),
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

              /// SUMMARY
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
                    dashboard.present.toString(),
                    Colors.green,
                  ),
                  _summaryCard(
                    "Absent",
                    dashboard.absent.toString(),
                    Colors.red,
                  ),
                  _summaryCard(
                    "Leave",
                    dashboard.leave.toString(),
                    Colors.blue,
                  ),
                  _summaryCard(
                    "Out Pass",
                    dashboard.outPass.toString(),
                    Colors.purple,
                  ),
                ],
              ),

              const SizedBox(height: 20),

              /// FLOORS
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: dashboard.floors.length,
                itemBuilder: (context, index) {
                  final floor = dashboard.floors[index];

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
                                  floor.floorName,
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
                            floor.totalStudents.toString(),
                          ),
                          _infoRow(
                            "Present",
                            floor.present.toString(),
                          ),
                          _infoRow(
                            "Absent",
                            floor.absent.toString(),
                          ),
                          _infoRow(
                            "Leave",
                            floor.leave.toString(),
                          ),
                          _infoRow(
                            "Out Pass",
                            floor.outPass.toString(),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const Text(
                                "Session",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: floor.session == "locked"
                                      ? Colors.white
                                      : Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  floor.session,
                                  style: TextStyle(
                                    color: floor.session == "locked"
                                        ? Colors.red
                                        : Colors.green,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
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
                                        "hostelName":
                                            controller.selectedHostel.value,
                                        "floorName": floor.floorName,
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
                  "hostelName": controller.selectedHostel.value,
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
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade300,
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_today),
          const SizedBox(width: 10),
          Obx(
            () => Text(
              controller.formattedDate,
            ),
          ),
        ],
      ),
    );
  }

  Widget _hostelDropdown() {
    return Obx(
      () => InputDecorator(
        decoration: InputDecoration(
          labelText: "Select Hostel / Block",
          labelStyle: const TextStyle(
            color: Colors.black,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 4,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Colors.grey.shade300,
            ),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.blue,
            ),
            borderRadius: BorderRadius.all(
              Radius.circular(12),
            ),
          ),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: controller.selectedHostel.value,
            isExpanded: true,
            icon: const Icon(Icons.keyboard_arrow_down),
            items: const [
              DropdownMenuItem(
                value: "Happy Homes",
                child: Text("Happy Homes"),
              ),
              DropdownMenuItem(
                value: "Hostel A",
                child: Text("Hostel A"),
              ),
              DropdownMenuItem(
                value: "Hostel B",
                child: Text("Hostel B"),
              ),
            ],
            onChanged: (value) {
              if (value != null) {
                controller.selectedHostel.value = value;
              }
            },
          ),
        ),
      ),
    );
  }
}
