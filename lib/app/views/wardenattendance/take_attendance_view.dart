import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_new_app/app/controllers/warden/take_attendance_controller.dart';

class TakeAttendanceView extends GetView<TakeAttendanceController> {
  const TakeAttendanceView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FB),
      appBar: AppBar(
        backgroundColor: Colors.blue,
        centerTitle: true,
        title: Obx(
          () => Text(
            "Take Attendance - ${controller.floorName.value}",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Get.back(),
                child: const Text("Cancel"),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: controller.saveAttendance,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  "Save Attendance",
                ),
              ),
            ),
          ],
        ),
      ),
      body: Obx(
        () => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              /// FILTER SECTION
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    children: [
                      _field(
                        "Date",
                        "18/06/2026",
                      ),
                      const SizedBox(height: 12),
                      _field(
                        "Hostel Block",
                        controller.hostelName.value,
                      ),
                      const SizedBox(height: 12),
                      _field(
                        "Floor",
                        controller.floorName.value,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              /// COUNTS
              Wrap(
                spacing: 12,
                runSpacing: 10,
                children: [
                  _countText(
                    "Total Students",
                    controller.totalStudents.toString(),
                    Colors.black,
                  ),
                  _countText(
                    "Present",
                    controller.presentCount.toString(),
                    Colors.green,
                  ),
                  _countText(
                    "Absent",
                    controller.absentCount.toString(),
                    Colors.red,
                  ),
                  _countText(
                    "Leave",
                    controller.leaveCount.toString(),
                    Colors.blue,
                  ),
                  _countText(
                    "Out Pass",
                    controller.outPassCount.toString(),
                    Colors.purple,
                  ),
                ],
              ),

              const SizedBox(height: 18),

              /// SEARCH
              TextField(
                decoration: InputDecoration(
                  hintText: "Search by Name / ID",
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// STUDENTS
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.students.length,
                itemBuilder: (_, index) {
                  final student = controller.students[index];

                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(
                      bottom: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            student.studentName,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Divider(),
                          _detailRow(
                            "Roll No",
                            student.rollNo,
                          ),
                          _detailRow(
                            "Student ID",
                            student.studentId,
                          ),
                          _detailRow(
                            "Room No",
                            student.roomNo,
                          ),
                          _detailRow(
                            "Bed No",
                            student.bedNo,
                          ),
                          _detailRow(
                            "Biometric",
                            student.biometric,
                          ),
                          _detailRow(
                            "Time",
                            student.biometricTime,
                          ),
                          const SizedBox(height: 14),
                          DropdownButtonFormField<String>(
                            value: student.status,
                            decoration: const InputDecoration(
                              labelText: "Status",
                              border: OutlineInputBorder(),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: "Present",
                                child: Text("Present"),
                              ),
                              DropdownMenuItem(
                                value: "Absent",
                                child: Text("Absent"),
                              ),
                              DropdownMenuItem(
                                value: "Leave",
                                child: Text("Leave"),
                              ),
                              DropdownMenuItem(
                                value: "Out Pass",
                                child: Text("Out Pass"),
                              ),
                            ],
                            onChanged: (value) {
                              student.status = value ?? "Present";

                              controller.students.refresh();
                            },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            initialValue: student.remarks,
                            decoration: const InputDecoration(
                              labelText: "Remarks",
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) {
                              student.remarks = value;
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(
    String title,
    String value,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(value),
        ),
      ],
    );
  }

  Widget _countText(
    String title,
    String value,
    Color color,
  ) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(
          fontSize: 14,
          color: Colors.black,
        ),
        children: [
          TextSpan(
            text: "$title : ",
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
          TextSpan(
            text: value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(
    String title,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 4,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 95,
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
