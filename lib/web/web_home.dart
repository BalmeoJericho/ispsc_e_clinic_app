import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';


class WebHome extends StatelessWidget {
  const WebHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            "Dashboard Overview",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 30),
          Expanded(child: _OverviewContent()),
        ],
      ),
    );
  }
}

class _OverviewContent extends StatelessWidget {
  const _OverviewContent();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('patients').snapshots(),
      builder: (context, patientSnapshot) {
        if (patientSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (patientSnapshot.hasError) {
          return Center(
            child: Text(
              "Error: ${patientSnapshot.error}",
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        final patients = patientSnapshot.data?.docs ?? [];

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collectionGroup('visits')
              .snapshots(),
          builder: (context, visitSnapshot) {
            if (visitSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (visitSnapshot.hasError) {
              return Center(
                child: Text(
                  "Error: ${visitSnapshot.error}",
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }

            final visits = visitSnapshot.data?.docs ?? [];

            return _buildDashboard(patients, visits);
          },
        );
      },
    );
  }

  ////////////////////////////////////////////////////////////

  Widget _buildDashboard(
    List<QueryDocumentSnapshot> patients,
    List<QueryDocumentSnapshot> visits,
  ) {
    final now = DateTime.now();

    final Map<String, Map<String, dynamic>> patientMap = {
      for (var p in patients) p.id: p.data() as Map<String, dynamic>,
    };

    final validVisits = visits.where((visit) {
      final parent = visit.reference.parent.parent;
      return parent != null && patientMap.containsKey(parent.id);
    }).toList();

    final int totalPatients = patients.length;
    final int totalVisits = validVisits.length;

    int visitsToday = 0;
    int visitsThisMonth = 0;
    int male = 0;
    int female = 0;

    final Map<int, int> monthly = {
      for (int i = 1; i <= 12; i++) i: 0,
    };

    for (var visit in validVisits) {
      final data = visit.data() as Map<String, dynamic>;
      final date = DateTime.tryParse(data['dateOfVisit'] ?? '');

      if (date != null) {
        if (date.year == now.year &&
            date.month == now.month &&
            date.day == now.day) {
          visitsToday++;
        }

        if (date.year == now.year && date.month == now.month) {
          visitsThisMonth++;
        }

        monthly[date.month] = (monthly[date.month] ?? 0) + 1;
      }

      final parent = visit.reference.parent.parent;
      if (parent == null) continue;

      final gender =
          (patientMap[parent.id]?['gender'] ?? '').toString().toLowerCase();

      if (gender == 'male') male++;
      if (gender == 'female') female++;
    }

    validVisits.sort((a, b) {
      final aDate = DateTime.tryParse(
            (a.data() as Map<String, dynamic>)['dateOfVisit'] ?? '',
          ) ??
          DateTime(2000);
      final bDate = DateTime.tryParse(
            (b.data() as Map<String, dynamic>)['dateOfVisit'] ?? '',
          ) ??
          DateTime(2000);

      return bDate.compareTo(aDate);
    });

    return SingleChildScrollView(
      child: Column(
        children: [
          Row(
            children: [
              _statCard(
                "Total Patients",
                totalPatients,
                Icons.people,
                Colors.blue,
              ),
              const SizedBox(width: 20),
              _statCard(
                "Total Visits",
                totalVisits,
                Icons.assignment,
                Colors.green,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _statCard(
                "Visits Today",
                visitsToday,
                Icons.today,
                Colors.orange,
              ),
              const SizedBox(width: 20),
              _statCard(
                "Visits This Month",
                visitsThisMonth,
                Icons.calendar_month,
                Colors.purple,
              ),
            ],
          ),
          const SizedBox(height: 40),
          Row(
            children: [
              Expanded(child: _genderChart(male, female)),
              const SizedBox(width: 30),
              Expanded(child: _monthlyChart(monthly)),
            ],
          ),
          const SizedBox(height: 40),
          _recentVisits(validVisits, patientMap),
        ],
      ),
    );
  }

  ////////////////////////////////////////////////////////////

  Widget _statCard(
    String title,
    int value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: _cardDecoration(),
        child: Row(
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Text(
                  value.toString(),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  ////////////////////////////////////////////////////////////

  Widget _genderChart(int male, int female) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          Row(
            children: [
              const Text(
                "Gender Distribution",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 6),
              Tooltip(
                message:
                    "This chart shows the number of clinic visits categorized by patient gender. It helps identify gender distribution trends in clinic usage.",
                child: const Icon(
                  Icons.info_outline,
                  size: 16,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 250,
            child: PieChart(
              PieChartData(
                sections: [
                  PieChartSectionData(
                    value: male.toDouble(),
                    title: "Male\n$male",
                    color: Colors.blue,
                  ),
                  PieChartSectionData(
                    value: female.toDouble(),
                    title: "Female\n$female",
                    color: Colors.pink,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  ////////////////////////////////////////////////////////////

  Widget _monthlyChart(Map<int, int> monthly) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                "Visits Per Month",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 6),
              Tooltip(
                message:
                    "This chart displays the total number of clinic visits per month. It helps monitor patient trends and peak periods.",
                child: const Icon(
                  Icons.info_outline,
                  size: 16,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 250,
            child: BarChart(
              BarChartData(
                barGroups: List.generate(12, (index) {
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: monthly[index + 1]!.toDouble(),
                        color: Colors.green,
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  ////////////////////////////////////////////////////////////

  Widget _recentVisits(
    List<QueryDocumentSnapshot> recent,
    Map<String, Map<String, dynamic>> patientMap,
  ) {
    final top10 = recent.take(10).toList();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Recent Visits",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Row(
            children: const [
              Expanded(
                flex: 2,
                child: Text(
                  "Date & Time",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  "Patient Name",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  "Reason for Visit",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                flex: 4,
                child: Text(
                  "Lab Tests",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const Divider(height: 25),
          if (top10.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text("No recent visits"),
              ),
            )
          else
            ...top10.map((visit) {
              final parent = visit.reference.parent.parent;

              if (parent == null || !patientMap.containsKey(parent.id)) {
                return const SizedBox.shrink();
              }

              final patient = patientMap[parent.id]!;
              final data = visit.data() as Map<String, dynamic>;

              final date = (data['dateOfVisit'] ?? "").toString();

              final reason = (data['reasonForVisit'] ??
                      data['chiefComplaint'] ??
                      "No Reason")
                  .toString();

              final labs = _extractLabs(data);

              return Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Color(0xFFEAEAEA)),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(date),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(patient['patientName'] ?? ""),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(reason),
                    ),
                    Expanded(
                      flex: 4,
                      child: Text(
                        labs.isEmpty ? "No Labs" : labs.join(", "),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
        ],
      ),
    );
  }

  ////////////////////////////////////////////////////////////

  List<String> _extractLabs(Map<String, dynamic> data) {
    List<String> labs = [];

    void extract(String key) {
      if (data[key] is List && (data[key] as List).isNotEmpty) {
        labs.addAll(List<String>.from(data[key]));
      }
    }

    extract("hematology");
    extract("clinicalMicroscopy");
    extract("bloodChemistry");
    extract("immunology");
    extract("radiology");
    extract("others");

    return labs;
  }

  ////////////////////////////////////////////////////////////

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          blurRadius: 10,
          color: Colors.black.withOpacity(0.05),
        ),
      ],
    );
  }
}