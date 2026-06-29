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
        title: Text(
          "Take Attendance",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
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
      body: Container(
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
                      TextFormField(
                        readOnly: true,
                        initialValue: currentDate,
                        decoration: InputDecoration(
                          labelText: "Date",
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
                      Obx(
                        () => TextFormField(
                          readOnly: true,
                          initialValue: controller.hostelName.value,
                          decoration: InputDecoration(
                            labelText: "Hostel Block",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
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

              Obx(() {
                return Table(
                  border: TableBorder.all(
                    color: Colors.grey,
                    width: 1,
                  ),
                  columnWidths: const {
                    0: FlexColumnWidth(2),
                    1: FlexColumnWidth(4),
                    2: FlexColumnWidth(2),
                  },
                  children: [
                    /// Header
                    TableRow(
                      decoration: BoxDecoration(
                        color: Colors.white,
                      ),
                      children: const [
                        Padding(
                          padding: EdgeInsets.all(10),
                          child: Center(
                            child: Text(
                              "Room No",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(10),
                          child: Center(
                            child: Text(
                              "Student Name",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(10),
                          child: Center(
                            child: Text(
                              "Status",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),

                    /// Student Rows
                    ...controller.students.map(
                      (student) => TableRow(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Center(
                              child: Text(student.roomNo),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Text(student.studentName),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(6),
                            child: Center(
                              child: GestureDetector(
                                onTap: () {
                                  student.status = student.status == "Present"
                                      ? "Absent"
                                      : "Present";

                                  controller.students.refresh();
                                },
                                child: Container(
                                  width: 40,
                                  height: 34,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: student.status == "Present"
                                        ? Colors.green
                                        : Colors.red,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    student.status == "Present" ? "P" : "A",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              })
            ],
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
