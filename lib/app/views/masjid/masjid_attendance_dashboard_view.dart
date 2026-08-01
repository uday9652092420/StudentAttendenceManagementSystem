import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_new_app/app/controllers/masjid/masjid_dashboard_controller.dart';
import 'package:my_new_app/app/routes/app_routes.dart';
import 'package:my_new_app/app/theme/app_theme.dart';

class MasjidDashboardView extends GetView<MasjidDashboardController> {
  const MasjidDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        centerTitle: true,
        elevation: 0,
        title: const Text(
          "Masjid Attendance",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: const Icon(Icons.logout_rounded, color: Colors.white),
              onPressed: () async {
                final result = await Get.dialog<bool>(
                  AlertDialog(
                    backgroundColor: AppColors.bgLight,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    title: const Text(
                      'Logout',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    content: const Text(
                      'Are you sure you want to logout?',
                      style: TextStyle(color: Colors.black87),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Get.back(result: false),
                        child: const Text(
                          'No',
                          style: TextStyle(color: Colors.black87),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => Get.back(result: true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Yes'),
                      ),
                    ],
                  ),
                );

                if (result == true) {
                  Get.offAllNamed(Routes.login);
                }
              },
            ),
          ),
        ],
      ),
      body: Obx(
        () => Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              /// Date & Time
              Row(
                children: [
                  Expanded(
                    child: Card(
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              color: Colors.blue,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "Date",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 5),
                            Text(controller.currentDate.value),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Card(
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.access_time,
                              color: Colors.green,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "Time",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 5),
                            Text(controller.currentTime.value),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              /// Prayer Dropdown
              DropdownButtonFormField<String>(
                initialValue: controller.selectedPrayer.value,
                decoration: InputDecoration(
                  labelText: "Prayer",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                items: controller.prayers
                    .map(
                      (e) => DropdownMenuItem(
                        value: e,
                        child: Text(e),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  controller.selectedPrayer.value = value!;
                  controller.checkAttendance();
                },
              ),

              const SizedBox(height: 15),

              /// Search
              TextField(
                controller: controller.searchController,
                decoration: InputDecoration(
                  hintText: "Search Student",
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onChanged: controller.searchStudent,
              ),

              const SizedBox(height: 15),

              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Students",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),

              const SizedBox(height: 10),

              Expanded(
                child: controller.isLoading.value
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : controller.filteredStudents.isEmpty
                        ? const Center(
                            child: Text("No Students Found"),
                          )
                        : ListView.builder(
                            itemCount: controller.filteredStudents.length,
                            itemBuilder: (_, index) {
                              final student =
                                  controller.filteredStudents[index];

                              return Obx(
                                () => Card(
                                  color: Colors.white,
                                  margin: const EdgeInsets.only(bottom: 8),
                                  child: CheckboxListTile(
                                    value: student.isPresent.value,
                                    onChanged: controller.attendanceTaken.value
                                        ? null
                                        : (value) {
                                            student.isPresent.value =
                                                value ?? false;
                                          },
                                    activeColor: Colors.blue,
                                    controlAffinity:
                                        ListTileControlAffinity.trailing,
                                    secondary: CircleAvatar(
                                      backgroundColor: Colors.blue,
                                      child: Text(
                                        student.studentName
                                            .substring(0, 1)
                                            .toUpperCase(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      student.studentName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    subtitle: Text(
                                      "ID : ${student.studentId}",
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
              ),
              const SizedBox(height: 15),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: Obx(
                  () => ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.save),
                    label: Text(
                      controller.attendanceTaken.value
                          ? "Attendance Taken"
                          : "Save Attendance",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: controller.attendanceTaken.value
                        ? null
                        : controller.saveAttendance,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
