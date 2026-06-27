import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:my_new_app/app/controllers/dashboard/attendance_controller.dart';

class StudentAttendanceView extends GetView<AttendanceController> {
  const StudentAttendanceView({super.key});

  @override
  Widget build(BuildContext context) {
    final String currentDate =
        DateFormat('dd MMM yyyy', 'en_US').format(DateTime.now());

    return Scaffold(
        backgroundColor: const Color(0xfff5f5f5),
        appBar: AppBar(
          backgroundColor: Colors.blue,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            "Period Wise Attendance",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                /// DATE CARD
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xff2196F3),
                        Color(0xff1565C0),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        height: 55,
                        width: 55,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.calendar_month,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Today's Date",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              currentDate,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                /// TOP CARD
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: controller.courseController,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: "Course Name",
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          prefixIcon: const Icon(Icons.menu_book),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      TextFormField(
                        controller: controller.classController,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: "Class Name",
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          prefixIcon: const Icon(Icons.class_),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: controller.periodController,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: "Current Period",
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          prefixIcon: const Icon(Icons.schedule),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                      Row(
                        children: [
                          /// PRESENT
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                children: [
                                  const Text(
                                    "Present",
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    "${controller.presentCount.value}",
                                    style: const TextStyle(
                                      color: Colors.green,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(width: 10),

                          /// ABSENT
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                children: [
                                  const Text(
                                    "Absent",
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    "${controller.absentCount.value}",
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(width: 10),

                          /// TOTAL
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                children: [
                                  const Text(
                                    "Total",
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    "${controller.totalStudents.value}",
                                    style: const TextStyle(
                                      color: Colors.blue,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      // /// COUNTS
                      // Row(
                      //   children: [
                      //     Expanded(
                      //       child: Container(
                      //         padding: const EdgeInsets.symmetric(
                      //           vertical: 14,
                      //         ),
                      //         decoration: BoxDecoration(
                      //           color: Colors.green.withOpacity(0.1),
                      //           borderRadius: BorderRadius.circular(12),
                      //         ),
                      //         child: Column(
                      //           children: [
                      //             const Text(
                      //               "Present Students",
                      //               style: TextStyle(
                      //                 color: Colors.green,
                      //                 fontWeight: FontWeight.w600,
                      //               ),
                      //             ),
                      //             const SizedBox(height: 5),
                      //             Text(
                      //               "${controller.presentCount.value}",
                      //               style: const TextStyle(
                      //                 color: Colors.green,
                      //                 fontSize: 22,
                      //                 fontWeight: FontWeight.bold,
                      //               ),
                      //             ),
                      //           ],
                      //         ),
                      //       ),
                      //     ),
                      //     const SizedBox(width: 12),
                      //     Expanded(
                      //       child: Container(
                      //         padding: const EdgeInsets.symmetric(
                      //           vertical: 14,
                      //         ),
                      //         decoration: BoxDecoration(
                      //           color: Colors.red.withOpacity(0.1),
                      //           borderRadius: BorderRadius.circular(12),
                      //         ),
                      //         child: Column(
                      //           children: [
                      //             const Text(
                      //               "Absent",
                      //               style: TextStyle(
                      //                 color: Colors.red,
                      //                 fontWeight: FontWeight.w600,
                      //               ),
                      //             ),
                      //             const SizedBox(height: 5),
                      //             Text(
                      //               "${controller.absentCount.value}",
                      //               style: const TextStyle(
                      //                 color: Colors.red,
                      //                 fontSize: 22,
                      //                 fontWeight: FontWeight.bold,
                      //               ),
                      //             ),
                      //           ],
                      //         ),
                      //       ),
                      //     ),
                      //   ],
                      // ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                /// STUDENTS LIST
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      /// HEADER
                      Row(
                        children: const [
                          Expanded(
                            flex: 2,
                            child: Text(
                              "Roll No",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 4,
                            child: Text(
                              "Student Name",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              "Status",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const Divider(height: 30),

                      /// STUDENTS
                      controller.students.isEmpty
                          ? const Padding(
                              padding: EdgeInsets.all(20),
                              child: Center(
                                child: Text(
                                  "No Students Found",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            )
                          : ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: controller.students.length,
                              separatorBuilder: (_, __) => const Divider(),
                              itemBuilder: (context, index) {
                                final student = controller.students[index];

                                return Row(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Text(student.rollNo),
                                    ),
                                    Expanded(
                                      flex: 4,
                                      child: Text(student.name),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Center(
                                        child: GestureDetector(
                                          onTap: () {
                                            controller.toggleAttendance(index);
                                          },
                                          child: AnimatedContainer(
                                            duration: const Duration(
                                              milliseconds: 200,
                                            ),
                                            height: 42,
                                            width: 42,
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              color: student.status == "P"
                                                  ? Colors.green
                                                      .withOpacity(0.1)
                                                  : Colors.red.withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              border: Border.all(
                                                color: student.status == "P"
                                                    ? Colors.green
                                                    : Colors.red,
                                                width: 2,
                                              ),
                                            ),
                                            child: Text(
                                              student.status,
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: student.status == "P"
                                                    ? Colors.green
                                                    : Colors.red,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                /// SAVE BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: controller.students.isEmpty
                        ? null
                        : () async {
                            await controller.saveAttendance();
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      "Save Attendance",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }));
  }
}
