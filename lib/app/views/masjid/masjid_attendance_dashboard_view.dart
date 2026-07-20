import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_new_app/app/controllers/masjid/masjid_dashboard_controller.dart';

class MasjidDashboardView extends GetView<MasjidDashboardController> {
  const MasjidDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.blue,
        centerTitle: true,
        title: const Text(
          "Masjid Attendance",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: Obx(
        () => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              /// Date & Time
              Row(
                children: [
                  Expanded(
                    child: Card(
                      color: Colors.white,
                      elevation: 1,
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
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              controller.currentDate.value,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Card(
                      color: Colors.white,
                      elevation: 1,
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
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              controller.currentTime.value,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              /// Prayer Dropdown
              Card(
                color: Colors.white,
                elevation: 1,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: DropdownButtonFormField<String>(
                    value: controller.selectedPrayer.value,
                    decoration: const InputDecoration(
                      labelText: "Prayer",
                      border: OutlineInputBorder(),
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
                    },
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// Scan QR
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white, // Icon & text color
                    minimumSize: const Size(double.infinity, 55),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.qr_code_scanner),
                  label: const Text(
                    "Scan Student QR",
                    style: TextStyle(fontSize: 17),
                  ),
                  onPressed: controller.scanStudent,
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white, // Icon & text color
                    minimumSize: const Size(double.infinity, 55),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.image),
                  label: const Text(
                    "Upload QR Image",
                    style: TextStyle(fontSize: 17),
                  ),
                  onPressed: controller.uploadQr,
                ),
              ),

              /// Upload QR

              const SizedBox(height: 25),

              /// Today's Attendance
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Today's Attendance",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),

              const SizedBox(height: 12),

              Card(
                elevation: 1,
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          const Text(
                            "Present",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "${controller.presentCount.value}",
                            style: const TextStyle(
                              fontSize: 28,
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        height: 60,
                        width: 1,
                        color: Colors.white,
                      ),
                      Column(
                        children: [
                          const Text(
                            "Prayer",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            controller.selectedPrayer.value,
                            style: const TextStyle(
                              fontSize: 20,
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 25),

              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Recent Attendance",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),

              const SizedBox(height: 10),

              Card(
                elevation: 1,
                color: Colors.white,
                child: SizedBox(
                  height: 250,
                  child: controller.recentStudents.isEmpty
                      ? const Center(
                          child: Text("No attendance recorded"),
                        )
                      : ListView.builder(
                          itemCount: controller.recentStudents.length,
                          itemBuilder: (_, index) {
                            final student = controller.recentStudents[index];

                            return ListTile(
                              leading: const CircleAvatar(
                                child: Icon(Icons.person),
                              ),
                              title: Text(student.studentName),
                              subtitle: Text(student.studentId),
                              trailing: const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                              ),
                            );
                          },
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
