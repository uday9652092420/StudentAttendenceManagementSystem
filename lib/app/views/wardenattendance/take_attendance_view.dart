import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_new_app/app/controllers/warden/take_attendance_controller.dart';
import 'package:intl/intl.dart';

class TakeAttendanceView extends GetView<TakeAttendanceController> {
  const TakeAttendanceView({super.key});

  @override
  Widget build(BuildContext context) {
    final String currentDate = DateFormat('dd MMM yyyy').format(DateTime.now());
    return Scaffold(
      backgroundColor: Colors.white, // full white background
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
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.blue),
                  foregroundColor: Colors.black,
                ),
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
                child: const Text("Save Attendance"),
              ),
            ),
          ],
        ),
      ),
      body: Obx(
        () => Container(
          color: Colors.white,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                /// FILTER SECTION
                Card(
                  color: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      children: [
                        _field("Date", currentDate),
                        const SizedBox(height: 12),
                        TextFormField(
                          readOnly: true,
                          initialValue: controller.hostelName.value,
                          decoration: InputDecoration(
                            labelText: "Hostel Block",
                            labelStyle: const TextStyle(color: Colors.black),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: "Level 1",
                          decoration: InputDecoration(
                            labelText: "Floor",
                            labelStyle: const TextStyle(color: Colors.black),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 14,
                            ),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: "Level 1",
                              child: Text("Level 1"),
                            ),
                            DropdownMenuItem(
                              value: "Level 2",
                              child: Text("Level 2"),
                            ),
                            DropdownMenuItem(
                              value: "Level 3",
                              child: Text("Level 3"),
                            ),
                            DropdownMenuItem(
                              value: "Level 4",
                              child: Text("Level 4"),
                            ),
                            DropdownMenuItem(
                              value: "Level 5",
                              child: Text("Level 5"),
                            ),
                          ],
                          onChanged: (_) {},
                        )
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
                        "Total Students", controller.totalStudents.toString()),
                    _countText("Present", controller.presentCount.toString()),
                    _countText("Absent", controller.absentCount.toString()),
                    _countText("Leave", controller.leaveCount.toString()),
                    _countText("Out Pass", controller.outPassCount.toString()),
                  ],
                ),

                const SizedBox(height: 18),

                /// SEARCH
                TextField(
                  decoration: InputDecoration(
                    hintText: "Search by Name / ID",
                    hintStyle: const TextStyle(color: Colors.black54),
                    prefixIcon: const Icon(Icons.search, color: Colors.blue),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.blue),
                    ),
                  ),
                  style: const TextStyle(color: Colors.black),
                ),

                const SizedBox(height: 20),

                /// STUDENTS LIST
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.students.length,
                  itemBuilder: (_, index) {
                    final student = controller.students[index];

                    return Card(
                      elevation: 2,
                      color: Colors.white,
                      margin: const EdgeInsets.only(bottom: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: const BorderSide(color: Colors.blue),
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
                                color: Colors.black,
                              ),
                            ),
                            const Divider(),
                            _detailRow("Roll No", student.rollNo),
                            _detailRow("Student ID", student.studentId),
                            _detailRow("Room No", student.roomNo),
                            _detailRow("Bed No", student.bedNo),
                            _detailRow("Biometric", student.biometric),
                            _detailRow("Time", student.biometricTime),
                            const SizedBox(height: 14),
                            DropdownButtonFormField<String>(
                              value: student.status,
                              decoration: const InputDecoration(
                                labelText: "Status",
                                labelStyle: TextStyle(color: Colors.black),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.blue),
                                ),
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: "Present",
                                  child: Text("Present",
                                      style: TextStyle(color: Colors.black)),
                                ),
                                DropdownMenuItem(
                                  value: "Absent",
                                  child: Text("Absent",
                                      style: TextStyle(color: Colors.black)),
                                ),
                                DropdownMenuItem(
                                  value: "Leave",
                                  child: Text("Leave",
                                      style: TextStyle(color: Colors.black)),
                                ),
                                DropdownMenuItem(
                                  value: "Out Pass",
                                  child: Text("Out Pass",
                                      style: TextStyle(color: Colors.black)),
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
                              style: const TextStyle(color: Colors.black),
                              decoration: const InputDecoration(
                                labelText: "Remarks",
                                labelStyle: TextStyle(color: Colors.black),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.blue),
                                ),
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
      ),
    );
  }

  Widget _field(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.blue),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(value, style: const TextStyle(color: Colors.black)),
        ),
      ],
    );
  }

  Widget _countText(String title, String value) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 14, color: Colors.black),
        children: [
          TextSpan(
            text: "$title : ",
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          TextSpan(
            text: value,
            style: const TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 95,
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }
}
