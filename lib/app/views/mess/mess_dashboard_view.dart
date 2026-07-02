import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:my_new_app/app/controllers/mess/mess_dashboard_controller.dart';

class MessDashboardView extends GetView<MessDashboardController> {
  const MessDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF4F7FB),
      appBar: AppBar(
        backgroundColor: Colors.blue,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Mess Attendance & Meal Forecast",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Obx(() {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              //-----------------------------------
              // TOP FILTER CARD
              //-----------------------------------

              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              readOnly: true,
                              controller: TextEditingController(
                                text: DateFormat("dd/MM/yyyy")
                                    .format(controller.selectedDate.value),
                              ),
                              decoration: InputDecoration(
                                labelText: "Date",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: controller.selectedHostel.value,
                              decoration: InputDecoration(
                                labelText: "Hostel Type",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              items: controller.hostels
                                  .map(
                                    (e) => DropdownMenuItem(
                                      value: e,
                                      child: Text(e),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) {
                                controller.selectedHostel.value = v!;
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 15),

                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              decoration: InputDecoration(
                                hintText: "Hostel Incharge",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: TextFormField(
                              decoration: InputDecoration(
                                hintText: "HH:MM",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 15),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.blue,
                            ),
                            onPressed: controller.recalculateMeals,
                            icon: const Icon(Icons.refresh),
                            label: const Text("Recalculate"),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.blue,
                            ),
                            onPressed: controller.printForecast,
                            icon: const Icon(Icons.print),
                            label: const Text("Print"),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                            ),
                            onPressed: controller.sendKitchen,
                            child: const Text(
                              "Send to Kitchen",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      //-----------------------------------
                      // MEAL COUNT CARDS
                      //-----------------------------------

                      Row(
                        children: [
                          Expanded(
                            child: _mealCard(
                              "Breakfast",
                              controller.breakfast.value,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _mealCard(
                              "Lunch",
                              controller.lunch.value,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _mealCard(
                              "Dinner",
                              controller.dinner.value,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _mealCard(
                              "Sick Diet",
                              controller.sickDiet.value,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 25),

                      //-----------------------------------
                      // MEAL SUMMARY TITLE
                      //-----------------------------------

                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Meal Summary",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),
                      //-----------------------------------
                      // MEAL SUMMARY TABLE
                      //-----------------------------------

                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(12),
                                  topRight: Radius.circular(12),
                                ),
                              ),
                              child: const Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      "Meal",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      "Count",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            _mealRow(
                              "Breakfast",
                              controller.breakfast.value,
                            ),
                            _mealRow(
                              "Lunch",
                              controller.lunch.value,
                            ),
                            _mealRow(
                              "Dinner",
                              controller.dinner.value,
                            ),
                            _mealRow(
                              "Sick Diet",
                              controller.sickDiet.value,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      //-----------------------------------
                      // FORECAST RECORDS
                      //-----------------------------------

                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Forecast Records",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      controller.forecastRecords.isEmpty
                          ? Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(25),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.grey.shade300,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                "No records yet.",
                                textAlign: TextAlign.center,
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: controller.forecastRecords.length,
                              itemBuilder: (_, index) {
                                final record =
                                    controller.forecastRecords[index];

                                return Card(
                                  child: ListTile(
                                    title: Text(record.hostelName),
                                    subtitle: Text(
                                      "Breakfast : ${record.breakfast}\n"
                                      "Lunch : ${record.lunch}\n"
                                      "Dinner : ${record.dinner}",
                                    ),
                                  ),
                                );
                              },
                            ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              //-----------------------------------
              // RIGHT SIDE SUMMARY CARD
              //-----------------------------------

              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Meal Summary",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 15),
                      _summaryRow(
                        "Total Hostel Attendance",
                        controller.totalAttendance.value,
                      ),
                      const Divider(),
                      _summaryRow(
                        "Out-Pass Students",
                        controller.outPass.value,
                      ),
                      const Divider(),
                      _summaryRow(
                        "Sick Students",
                        controller.sickStudents.value,
                      ),
                      const SizedBox(height: 25),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: controller.recalculateMeals,
                          child: const Text("Recalculate"),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: controller.printForecast,
                          child: const Text("Print"),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                          ),
                          onPressed: controller.sendKitchen,
                          child: const Text(
                            "Send to Kitchen",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
//==========================================================
// Meal Card
//==========================================================

Widget _mealCard(String title, int count) {
  return Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: Colors.grey.shade300),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 17,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          "$count",
          style: const TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
      ],
    ),
  );
}

//==========================================================
// Meal Summary Row
//==========================================================

Widget _mealRow(String meal, int count) {
  return Container(
    padding: const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 15,
    ),
    decoration: BoxDecoration(
      border: Border(
        bottom: BorderSide(
          color: Colors.grey.shade300,
        ),
      ),
    ),
    child: Row(
      children: [
        Expanded(
          child: Text(
            meal,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
        ),
        Expanded(
          child: Text(
            "$count",
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
        ),
      ],
    ),
  );
}

//==========================================================
// Right Summary Row
//==========================================================

Widget _summaryRow(String title, int value) {
  return Padding(
    padding: const EdgeInsets.symmetric(
      vertical: 8,
    ),
    child: Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
        ),
        Text(
          "$value",
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
      ],
    ),
  );
}
