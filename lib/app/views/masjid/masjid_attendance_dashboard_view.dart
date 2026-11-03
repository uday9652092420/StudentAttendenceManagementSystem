import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_new_app/app/controllers/masjid/masjid_dashboard_controller.dart';
import 'package:my_new_app/app/custome_widgets/app_language_switcher.dart';
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
        leading: Obx(
          () => controller.isEditing.value
              ? IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: controller.cancelEditing,
                )
              : const SizedBox.shrink(),
        ),
        title: Obx(
          () => Text(
            controller.isEditing.value
                ? "Edit Attendance"
                : "Masjid Attendance",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        actions: [
          const AppLanguageSwitcher(),
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
                    title: Text(
                      'Logout'.tr,
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    content: Text(
                      'Are you sure you want to logout?'.tr,
                      style: TextStyle(color: Colors.black87),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Get.back(result: false),
                        child: Text(
                          'No'.tr,
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
                        child: Text('Yes'.tr),
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
        () => controller.showSavedAttendanceSummary.value
            ? _savedAttendanceSummary()
            : Padding(
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
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              child: Column(
                                children: [
                                  const Icon(
                                    Icons.calendar_today,
                                    color: Colors.blue,
                                    size: 20,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Date".tr,
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 3),
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
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              child: Column(
                                children: [
                                  const Icon(
                                    Icons.access_time,
                                    color: Colors.green,
                                    size: 20,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Time".tr,
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(controller.currentTime.value),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    DropdownButtonFormField<String>(
                      key: ValueKey(
                        "course-${controller.selectedCourseId.value}",
                      ),
                      initialValue: controller.selectedCourseId.value.isEmpty
                          ? null
                          : controller.selectedCourseId.value,
                      decoration: InputDecoration(
                        labelText: "Course".tr,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      items: controller.courses
                          .map(
                            (course) => DropdownMenuItem(
                              value: course.id,
                              child: Text(course.name),
                            ),
                          )
                          .toList(),
                      onChanged: controller.isLoading.value
                          ? null
                          : (value) {
                              if (value != null) controller.selectCourse(value);
                            },
                    ),

                    const SizedBox(height: 8),

                    DropdownButtonFormField<String>(
                      key:
                          ValueKey("class-${controller.selectedClassId.value}"),
                      initialValue: controller.selectedClassId.value.isEmpty
                          ? null
                          : controller.selectedClassId.value,
                      decoration: InputDecoration(
                        labelText: "Class".tr,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      items: controller.classes
                          .map(
                            (classOption) => DropdownMenuItem(
                              value: classOption.id,
                              child: Text(classOption.name),
                            ),
                          )
                          .toList(),
                      onChanged: controller.isLoading.value
                          ? null
                          : (value) {
                              if (value != null) controller.selectClass(value);
                            },
                    ),

                    /// Prayer Dropdown
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      key:
                          ValueKey("prayer-${controller.selectedPrayer.value}"),
                      initialValue: controller.selectedPrayer.value,
                      decoration: InputDecoration(
                        labelText: "Prayer".tr,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      items: controller.prayers
                          .map(
                            (e) => DropdownMenuItem(
                              value: e,
                              child: Text(e.tr),
                            ),
                          )
                          .toList(),
                      onChanged: controller.isLoading.value
                          ? null
                          : (value) {
                              if (value != null) controller.selectPrayer(value);
                            },
                    ),

                    const SizedBox(height: 8),

                    /// Search
                    TextField(
                      controller: controller.searchController,
                      decoration: InputDecoration(
                        hintText: "Search Student".tr,
                        prefixIcon: const Icon(Icons.search),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        prefixIconConstraints: const BoxConstraints(
                          minWidth: 40,
                          minHeight: 40,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onChanged: controller.searchStudent,
                    ),

                    const SizedBox(height: 8),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Students".tr,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Expanded(
                      child: controller.isLoading.value
                          ? Center(
                              child: CircularProgressIndicator(),
                            )
                          : controller.filteredStudents.isEmpty
                              ? Center(
                                  child: Text("No Students Found".tr),
                                )
                              : _studentList(),
                    ),
                    const SizedBox(height: 15),

                    if (!controller.attendanceTaken.value)
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                          icon: const Icon(Icons.save),
                          label: Text(
                            controller.isSaving.value
                                ? "Saving..."
                                : "Save Attendance",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: controller.isSaving.value
                              ? null
                              : controller.saveAttendance,
                        ),
                      )
                    else ...[
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: controller.isSaving.value ||
                                  controller.sessionId.value.isEmpty
                              ? null
                              : controller.isEditing.value
                                  ? controller.updateAttendance
                                  : controller.startEditingAttendance,
                          icon: Icon(
                            controller.isEditing.value
                                ? Icons.update
                                : Icons.edit_outlined,
                          ),
                          label: Text(
                            controller.isEditing.value
                                ? "Update Attendance"
                                : "Edit Attendance",
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.successLight,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: controller.isSaving.value ||
                                  controller.sessionId.value.isEmpty
                              ? null
                              : _confirmDeleteAttendance,
                          icon: const Icon(Icons.delete_outline),
                          label: Text("Delete Attendance".tr),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.errorLight,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      if (controller.isEditing.value)
                        TextButton(
                          onPressed: controller.isSaving.value
                              ? null
                              : controller.cancelEditing,
                          child: Text("Cancel".tr),
                        ),
                    ],
                  ],
                ),
              ),
      ),
    );
  }

  Widget _studentList() {
    final list = ListView.builder(
      itemCount: controller.filteredStudents.length,
      itemBuilder: (_, index) {
        final student = controller.filteredStudents[index];

        return Obx(
          () => Card(
            color: Colors.white,
            margin: const EdgeInsets.only(bottom: 8),
            child: CheckboxListTile(
              value: student.isPresent.value,
              onChanged: controller.attendanceTaken.value &&
                      !controller.isEditing.value
                  ? null
                  : (value) {
                      student.isPresent.value = value ?? false;
                    },
              activeColor: Colors.blue,
              controlAffinity: ListTileControlAffinity.trailing,
              secondary: CircleAvatar(
                backgroundColor: Colors.blue,
                child: Text(
                  student.studentName.isEmpty
                      ? "S"
                      : student.studentName.substring(0, 1).toUpperCase(),
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
              subtitle: Text("ID : ${student.studentId}"),
            ),
          ),
        );
      },
    );

    return controller.filteredStudents.length > 4
        ? Scrollbar(thumbVisibility: true, child: list)
        : list;
  }

  Widget _savedAttendanceSummary() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text(
              "Saved Attendance Details".tr,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Card(
            color: Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade300),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _summaryRow(
                    icon: Icons.calendar_today,
                    label: "Date",
                    value: controller.savedAttendanceDate.value,
                    color: Colors.blue,
                  ),
                  const Divider(height: 28),
                  _summaryRow(
                    icon: Icons.mosque_outlined,
                    label: "Prayer",
                    value: controller.selectedPrayer.value,
                    color: Colors.green,
                  ),
                  const Divider(height: 28),
                  _summaryRow(
                    icon: Icons.people_outline,
                    label: "Present Students",
                    value: controller.presentStudentCount.toString(),
                    color: Colors.blue,
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed: controller.isSaving.value
                  ? null
                  : controller.startEditingAttendance,
              icon: const Icon(Icons.edit_outlined),
              label: Text("Edit Attendance".tr),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.successLight,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed:
                  controller.isSaving.value ? null : _confirmDeleteAttendance,
              icon: const Icon(Icons.delete_outline),
              label: Text("Delete Attendance".tr),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.errorLight,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, color: color),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.tr,
                style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
              ),
              const SizedBox(height: 4),
              Text(
                value.tr,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _confirmDeleteAttendance() async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: Text("Delete Attendance".tr),
        content: Text(
          "Are you sure you want to delete this attendance?".tr,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text("Cancel".tr),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            child: Text("Delete".tr),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await controller.deleteAttendance();
    }
  }
}
