import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_new_app/app/controllers/sponsor/sponsor_dashboard_controller.dart';

class SponsorDashboardView extends GetView<SponsorDashboardController> {
  const SponsorDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Sponsor Dashboard',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: controller.logout,
            icon: const Icon(
              Icons.logout,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => controller.refreshDashboard(),
        child: Obx(() {
          final isLoading = controller.isLoading.value;
          final dashboard = controller.dashboard.value;

          if (isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (dashboard == null) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.dashboard_outlined,
                      size: 48,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'No Dashboard Data Available',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.45,
                  children: [
                    _summaryCard(
                      Icons.groups,
                      Colors.blue,
                      'Total Students',
                      dashboard.summary.totalSponsoredStudents.toString(),
                    ),
                    _summaryCard(
                      Icons.show_chart,
                      Colors.green,
                      'Avg Attendance',
                      dashboard.summary.averageAttendance == 0
                          ? 'N/A'
                          : '${dashboard.summary.averageAttendance}%',
                    ),
                    _summaryCard(
                      Icons.school,
                      Colors.orange,
                      'Avg Exam Score',
                      dashboard.summary.averageExamScore == 0
                          ? 'N/A'
                          : '${dashboard.summary.averageExamScore}%',
                    ),
                    _summaryCard(
                      Icons.restaurant,
                      Colors.deepPurple,
                      'Kitchen Utilization',
                      dashboard.summary.kitchenUtilization == 0
                          ? 'N/A'
                          : '${dashboard.summary.kitchenUtilization}%',
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  'My Sponsored Students',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                if (controller.students.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 30),
                    child: Center(
                      child: Text(
                        'No Sponsored Students Found',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: controller.students.length,
                    itemBuilder: (_, index) {
                      final student = controller.students[index];
                      final studentName = student.studentName.trim();

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: InkWell(
                          onTap: () => controller.viewStudent(student),
                          borderRadius: BorderRadius.circular(14),
                          child: Card(
                            color: Colors.white,
                            elevation: 2,
                            margin: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(15),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 28,
                                        backgroundColor: Colors.blue.shade100,
                                        child: Text(
                                          getInitials(studentName),
                                          style: const TextStyle(
                                            color: Colors.blue,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 15),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              studentName.isEmpty
                                                  ? 'Unknown Student'
                                                  : studentName,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              student.courseName.isEmpty
                                                  ? 'No Course'
                                                  : student.courseName,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                color: Colors.grey.shade700,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            controller.viewStudent(student),
                                        child: const Text('View Profile'),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 15),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _infoTile(
                                          'Attendance',
                                          student.attendancePercentage == 0
                                              ? 'N/A'
                                              : '${student.attendancePercentage}%',
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: _infoTile(
                                          'Exam',
                                          student.lastExamScore == 0
                                              ? 'N/A'
                                              : '${student.lastExamScore}%',
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _infoTile(
                                          'Discipline',
                                          student.discipline.isEmpty
                                              ? 'N/A'
                                              : student.discipline,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: _infoTile(
                                          'Hostel',
                                          student.hostel.isEmpty
                                              ? 'N/A'
                                              : student.hostel,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: Card(
                    color: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Kitchen Dashboard',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _smallCard(
                                  'Meals Served',
                                  dashboard.kitchen.mealsServed.toString(),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _smallCard(
                                  'Cost Covered',
                                  dashboard.kitchen.costCovered == 0
                                      ? '₹0'
                                      : '₹${dashboard.kitchen.costCovered.toStringAsFixed(0)}',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _smallCard(
                                  'Utilization',
                                  dashboard.kitchen.utilizationPercentage == 0
                                      ? 'N/A'
                                      : '${dashboard.kitchen.utilizationPercentage}%',
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _smallCard(
                                  'Certification',
                                  dashboard.kitchen.certificationMessage.isEmpty
                                      ? 'Meals Prepared Hygienically'
                                      : dashboard.kitchen.certificationMessage,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: Card(
                    color: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Kitchen Photos',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          const SizedBox(height: 15),
                          SizedBox(
                            height: 120,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: [
                                kitchenPhoto(
                                  'https://images.unsplash.com/photo-1556910103-1c02745aae4d',
                                ),
                                kitchenPhoto(
                                  'https://images.unsplash.com/photo-1504674900247-0877df9cc836',
                                ),
                                kitchenPhoto(
                                  'https://images.unsplash.com/photo-1546069901-ba9599a7e63c',
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: Card(
                    color: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Progress Report',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            ),
                          ),
                          const SizedBox(height: 15),
                          reportItem(
                            'Sponsor Status',
                            dashboard.sponsor.activePlan
                                ? 'Active'
                                : 'Inactive',
                          ),
                          reportItem(
                            'Billing Cycle',
                            dashboard.sponsor.billingCycle.isEmpty
                                ? 'Not Available'
                                : dashboard.sponsor.billingCycle,
                          ),
                          reportItem(
                            'Sponsorship Category',
                            dashboard.sponsor.sponsorshipCategory.isEmpty
                                ? 'Not Available'
                                : dashboard.sponsor.sponsorshipCategory,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  String getInitials(String name) {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      return '--';
    }

    final words = trimmedName
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList();
    if (words.isEmpty) {
      return '--';
    }

    final initials = <String>[];
    for (final word in words.take(2)) {
      if (word.isNotEmpty) {
        initials.add(word[0].toUpperCase());
      }
    }

    return initials.isEmpty ? '--' : initials.join();
  }

  Widget _summaryCard(
    IconData icon,
    Color color,
    String title,
    String value,
  ) {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: color.withValues(alpha: 0.15),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
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
    );
  }

  Widget _smallCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.black87),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoTile(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.black87),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 17,
            ),
          ),
        ],
      ),
    );
  }

  Widget reportItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget kitchenPhoto(String url) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(
          url,
          width: 140,
          height: 120,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) {
              return child;
            }
            return const SizedBox(
              width: 140,
              height: 120,
              child: Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: 140,
              height: 120,
              color: Colors.grey.shade100,
              child: const Icon(
                Icons.broken_image_outlined,
                color: Colors.grey,
              ),
            );
          },
        ),
      ),
    );
  }
}
