import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'analytics_report_service.dart';

class WebAnalytics extends StatelessWidget {
  const WebAnalytics({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(40),
      color: const Color(0xFFF4F6FA),
      child: FutureBuilder(
        future: Future.wait([
          FirebaseFirestore.instance.collection('patients').get(),
          FirebaseFirestore.instance.collectionGroup('visits').get(),
        ]),
        builder: (context, AsyncSnapshot<List<QuerySnapshot>> snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final patients = snapshot.data![0].docs;
          final visits = snapshot.data![1].docs;

////////////////////////////////////////////////////////////
/// PATIENT MAP
////////////////////////////////////////////////////////////

          final Map<String, Map<String, dynamic>> patientMap = {
            for (var p in patients) p.id: p.data() as Map<String, dynamic>,
          };

////////////////////////////////////////////////////////////
/// VALID VISITS ONLY
////////////////////////////////////////////////////////////

          final validVisits = visits.where((visit) {
            final parent = visit.reference.parent.parent;
            return parent != null && patientMap.containsKey(parent.id);
          }).toList();

          final int totalPatients = patients.length;
          final int totalVisits = validVisits.length;

////////////////////////////////////////////////////////////
/// GENDER
////////////////////////////////////////////////////////////

          int male = 0;
          int female = 0;

          for (var visit in validVisits) {
            final parent = visit.reference.parent.parent;
            if (parent == null) continue;

            final gender =
                (patientMap[parent.id]?['gender'] ?? '')
                    .toString()
                    .toLowerCase();

            if (gender == "male") male++;
            if (gender == "female") female++;
          }

          final int totalGender = male + female;

          final double malePercent =
              totalGender == 0 ? 0 : (male / totalGender) * 100;

          final double femalePercent =
              totalGender == 0 ? 0 : (female / totalGender) * 100;

////////////////////////////////////////////////////////////
/// MONTHLY
////////////////////////////////////////////////////////////

          final Map<int, int> monthly = {
            for (int i = 1; i <= 12; i++) i: 0
          };

          for (var visit in validVisits) {
            final data = visit.data() as Map<String, dynamic>;
            final date = DateTime.tryParse(data['dateOfVisit'] ?? '');

            if (date != null) {
              monthly[date.month] =
                  (monthly[date.month] ?? 0) + 1;
            }
          }

////////////////////////////////////////////////////////////
/// LAB ANALYTICS
////////////////////////////////////////////////////////////

          final Map<String, int> individualLabs = {};
          final Map<String, int> categoryCounts = {
            "Hematology": 0,
            "Clinical Microscopy": 0,
            "Blood Chemistry": 0,
            "Immunology": 0,
            "Radiology": 0,
            "Others": 0,
          };

          for (var visit in validVisits) {
            final data = visit.data() as Map<String, dynamic>;

            void process(String key, String label) {
              if (data[key] is List) {
                final List labs = data[key];

                categoryCounts[label] =
                    categoryCounts[label]! + labs.length;

                for (var lab in labs) {
                  individualLabs[lab.toString()] =
                      (individualLabs[lab.toString()] ?? 0) + 1;
                }
              }
            }

            process("hematology", "Hematology");
            process("clinicalMicroscopy", "Clinical Microscopy");
            process("bloodChemistry", "Blood Chemistry");
            process("immunology", "Immunology");
            process("radiology", "Radiology");
            process("others", "Others");
          }

          final topLabs = individualLabs.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));

          final top5 = topLabs.take(5).toList();

////////////////////////////////////////////////////////////
/// UI
////////////////////////////////////////////////////////////

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                const Text(
                  "Analytics Dashboard",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

////////////////////////////////////////////////////////////
/// EXPORT
////////////////////////////////////////////////////////////

                ElevatedButton.icon(
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text("Export Analytics Report"),
                  onPressed: () {
                    generateAnalyticsReport(
                      totalPatients: totalPatients,
                      totalVisits: totalVisits,
                      male: male,
                      female: female,
                      monthly: monthly,
                      topLabs: top5,
                      categoryCounts: categoryCounts,
                    );
                  },
                ),

                const SizedBox(height: 30),

////////////////////////////////////////////////////////////
/// CARDS
////////////////////////////////////////////////////////////

                Row(
                  children: [
                    _statCard("Total Patients", totalPatients, Icons.people, Colors.blue),
                    const SizedBox(width: 20),
                    _statCard("Total Visits", totalVisits, Icons.assignment, Colors.green),
                  ],
                ),

                const SizedBox(height: 40),

////////////////////////////////////////////////////////////
/// CHARTS
////////////////////////////////////////////////////////////

                Row(
                  children: [
                    Expanded(child: _genderChart(male, female, malePercent, femalePercent)),
                    const SizedBox(width: 30),
                    Expanded(child: _monthlyChart(monthly)),
                  ],
                ),

                const SizedBox(height: 40),

                _topLabsChart(top5),

                const SizedBox(height: 40),

                _categoryChart(categoryCounts),
              ],
            ),
          );
        },
      ),
    );
  }

////////////////////////////////////////////////////////////
/// GENDER
////////////////////////////////////////////////////////////

  Widget _genderChart(int male, int female, double malePercent, double femalePercent) {
    return _card(
      child: Column(
        children: [
          _titleWithInfo(
            "Gender Distribution",
            "Shows the percentage of clinic visits by gender.",
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 250,
            child: PieChart(
              PieChartData(
                sections: [
                  PieChartSectionData(value: male.toDouble(), title: "Male\n${malePercent.toStringAsFixed(1)}%", color: Colors.blue),
                  PieChartSectionData(value: female.toDouble(), title: "Female\n${femalePercent.toStringAsFixed(1)}%", color: Colors.pink),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

////////////////////////////////////////////////////////////
/// MONTHLY
////////////////////////////////////////////////////////////

  Widget _monthlyChart(Map<int, int> monthly) {
    const months = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"];

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _titleWithInfo(
            "Visits Per Month",
            "Shows total visits recorded per month.",
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 250,
            child: BarChart(
              BarChartData(
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final i = value.toInt();
                        if (i < 0 || i >= months.length) return const SizedBox();
                        return Text(months[i]);
                      },
                    ),
                  ),
                ),
                barGroups: List.generate(12, (i) {
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: monthly[i + 1]!.toDouble(),
                        color: Colors.green,
                      )
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
/// TOP LABS
////////////////////////////////////////////////////////////

  Widget _topLabsChart(List<MapEntry<String, int>> top5) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _titleWithInfo(
            "Top 5 Lab Tests",
            "Shows the most requested laboratory tests.",
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 250,
            child: BarChart(
              BarChartData(
                barGroups: List.generate(top5.length, (i) {
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: top5[i].value.toDouble(),
                        color: Colors.teal,
                      )
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
/// CATEGORY
////////////////////////////////////////////////////////////

  Widget _categoryChart(Map<String, int> data) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _titleWithInfo(
            "Lab Category Distribution",
            "Shows how lab requests are distributed across categories.",
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 250,
            child: PieChart(
              PieChartData(
                sections: data.entries
                    .where((e) => e.value > 0)
                    .map(
                      (e) => PieChartSectionData(
                        value: e.value.toDouble(),
                        title: "${e.key}\n${e.value}",
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

////////////////////////////////////////////////////////////
/// REUSABLE
////////////////////////////////////////////////////////////

  Widget _titleWithInfo(String title, String message) {
    return Row(
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(width: 6),
        Tooltip(
          message: message,
          child: const Icon(Icons.info_outline, size: 16, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: _cardDecoration(),
      child: child,
    );
  }

  Widget _statCard(String title, int value, IconData icon, Color color) {
    return Expanded(
      child: _card(
        child: Row(
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 8),
                Text(value.toString(), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          blurRadius: 10,
          color: Colors.black.withOpacity(0.05),
        )
      ],
    );
  }
}