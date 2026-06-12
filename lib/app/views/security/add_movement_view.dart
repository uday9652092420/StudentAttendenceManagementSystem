import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_new_app/app/config/constants.dart';

import 'package:my_new_app/app/controllers/securitycontrollers/add_movement_controller.dart';

import 'package:intl/intl.dart';
import 'package:my_new_app/app/helpers/flutter_toast.dart';

class AddMovementView extends GetView<AddMovementController> {
  const AddMovementView({super.key});

  String formatDate(String? date) {
    if (date == null || date.isEmpty) return "-";

    try {
      return DateFormat(
        "dd MMM yyyy",
      ).format(DateTime.parse(date));
    } catch (_) {
      return date;
    }
  }

  String formatDateTime(DateTime dateTime) {
    return DateFormat(
      "dd MMM yyyy • hh:mm a",
    ).format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FB),
      appBar: AppBar(
        backgroundColor: Colors.blue.shade700,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        title: Center(
          child: const Text(
            "Security Check Movement",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final data = controller.gatePass.value;

        if (data == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "No Gate Pass Data Found",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "GatePassId: ${controller.gatePassId}",
                ),
              ],
            ),
          );
        }
        print(
          "IMAGE URL => ${Constants.imageBaseUrl}${data.photoPath}",
        );
        final imageUrl = data.photoPath != null && data.photoPath!.isNotEmpty
            ? "${Constants.imageBaseUrl}${data.photoPath}"
            : "";
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        width: 110,
                        height: 130,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) {
                          return Container(
                            width: 110,
                            height: 130,
                            color: Colors.blue.shade50,
                            child: const Icon(
                              Icons.person,
                              size: 60,
                              color: Colors.blue,
                            ),
                          );
                        },
                      )
                    : Container(
                        width: 110,
                        height: 130,
                        color: Colors.blue.shade50,
                        child: const Icon(
                          Icons.person,
                          size: 60,
                          color: Colors.blue,
                        ),
                      ),
              ),

              const SizedBox(height: 20),

              /// STUDENT DETAILS
              Card(
                color: Colors.white,
                elevation: 4,
                shadowColor: Colors.grey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          children: [
                            _infoRow(
                              "Student ID",
                              data.studentId ?? "",
                            ),
                            _infoRow(
                              "Student Name",
                              data.studentName ?? "",
                            ),
                            _infoRow(
                              "Room No",
                              data.roomNo ?? "",
                            ),
                            _infoRow(
                              "Course",
                              data.courseName ?? "",
                            ),
                            _infoRow(
                              "Gate Pass No",
                              data.gatePassNo ?? "",
                            ),
                            _infoRow(
                              "Purpose",
                              data.reason ?? "",
                            ),
                            _infoRow(
                              "Expected Return",
                              data.returnTime ?? "",
                            ),
                            _infoRow(
                              "Issue Date",
                              formatDate(data.issueDate),
                            ),
                            _infoRow(
                              "Approved By",
                              data.approvedBy ?? "",
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.logout,
                            color: Colors.blue,
                          ),
                          SizedBox(width: 8),
                          Text(
                            "Out Movement (Exit)",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        initialValue: formatDateTime(
                          DateTime.now(),
                        ),
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: "Out Date & Time",
                          prefixIcon: const Icon(
                            Icons.calendar_today,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      TextField(
                        controller: controller.outSecurityGuardController,
                        decoration: InputDecoration(
                          labelText: "Out Security Guard",
                          prefixIcon: const Icon(
                            Icons.security,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      // TextField(
                      //   controller: controller.outNotesController,
                      //   maxLines: 3,
                      //   decoration: InputDecoration(
                      //     labelText: "Notes",
                      //     border: OutlineInputBorder(
                      //       borderRadius: BorderRadius.circular(12),
                      //     ),
                      //   ),
                      // ),
                      // const SizedBox(height: 10),
                      Obx(
                        () => CheckboxListTile(
                          value: controller.confirmStudentLeft.value,
                          activeColor: Colors.blue,
                          contentPadding: EdgeInsets.zero,
                          title: const Text(
                            "Confirm student has left the hostel",
                          ),
                          onChanged: (value) {
                            controller.confirmStudentLeft.value =
                                value ?? false;
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.login,
                            color: Colors.green,
                          ),
                          SizedBox(width: 8),
                          Text(
                            "Return Movement (Entry)",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        initialValue: formatDateTime(
                          DateTime.now(),
                        ),
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: "Return Date & Time",
                          prefixIcon: const Icon(
                            Icons.calendar_today,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      TextField(
                        controller: controller.returnSecurityGuardController,
                        decoration: InputDecoration(
                          labelText: "Return Security Guard",
                          prefixIcon: const Icon(
                            Icons.security,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      // TextField(
                      //   controller: controller.returnNotesController,
                      //   maxLines: 3,
                      //   decoration: InputDecoration(
                      //     labelText: "Return Notes",
                      //     border: OutlineInputBorder(
                      //       borderRadius: BorderRadius.circular(12),
                      //     ),
                      //   ),
                      // ),
                      // const SizedBox(height: 10),
                      Obx(
                        () => CheckboxListTile(
                          value: controller.confirmStudentReturned.value,
                          activeColor: Colors.green,
                          contentPadding: EdgeInsets.zero,
                          title: const Text(
                            "Confirm student has returned to the hostel",
                          ),
                          onChanged: (value) {
                            controller.confirmStudentReturned.value =
                                value ?? false;
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 25),

              Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.note_alt_outlined, color: Colors.blue),
                          SizedBox(width: 8),
                          Text(
                            "Notes",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      TextField(
                        controller: controller.outNotesController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: "Enter remarks / notes",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: controller.isLoading.value ||
                          ((data.outConfirmed ?? false) &&
                              (data.returnConfirmed ?? false))
                      ? null
                      : () async {
                          await controller.saveMovement();
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    foregroundColor: Colors.white,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: controller.isLoading.value
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : Text(
                          ((data.outConfirmed ?? false) &&
                                  (data.returnConfirmed ?? false))
                              ? "Movement Completed"
                              : "Save Movement",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              )
            ],
          ),
        );
      }),
    );
  }

  Widget _infoRow(
    String title,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 6,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              title,
              style: TextStyle(
                color: Colors.blue.shade700,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          const Text(
            ": ",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
