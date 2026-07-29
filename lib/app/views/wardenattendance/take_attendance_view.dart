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
        title: const Text(
          "Take Attendance",
          style: TextStyle(
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
              child: Obx(
                () => ElevatedButton(
                  onPressed: controller.isSaving.value
                      ? null
                      : controller.saveAttendance,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: controller.isSaving.value
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text("Save Attendance"),
                ),
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
                          initialValue: controller.blockName.value,
                          decoration: InputDecoration(
                            labelText: "Hostel Block",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Obx(
                        () => DropdownButtonFormField<String>(
                          initialValue: controller.selectedFloorId.value,
                          decoration: InputDecoration(
                            labelText: "Floor",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          items: controller.floors.map((floor) {
                            return DropdownMenuItem<String>(
                              value: floor.id,
                              child: Text(floor.floorLabel),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              controller.changeFloor(value);
                            }
                          },
                        ),
                      )
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Obx(
                () => Wrap(
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
                    2: FlexColumnWidth(3),
                    3: FlexColumnWidth(4),
                  },
                  children: [
                    /// Header
                    const TableRow(
                      decoration: BoxDecoration(
                        color: Colors.white,
                      ),
                      children: [
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
                        Padding(
                          padding: EdgeInsets.all(10),
                          child: Center(
                            child: Text(
                              "Remarks",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),

                    ...controller.students.map(
                      (student) => TableRow(
                        children: [
                          /// Room No
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Center(
                              child: Text(student.roomNo),
                            ),
                          ),

                          /// Student Name
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Text(student.studentName),
                          ),

                          /// Status
                          Padding(
                            padding: const EdgeInsets.all(6),
                            child: DropdownButtonFormField<String>(
                              initialValue: student.status,
                              isExpanded: true,
                              decoration: const InputDecoration(
                                isDense: true,
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
                                if (value != null) {
                                  student.status = value;
                                  controller.students.refresh();
                                }
                              },
                            ),
                          ),

                          /// Remarks
                          Padding(
                            padding: const EdgeInsets.all(6),
                            child: TextFormField(
                              initialValue: student.remarks,
                              decoration: const InputDecoration(
                                hintText: "Remarks",
                                isDense: true,
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (value) {
                                student.remarks = value;
                              },
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
