import 'package:flutter/material.dart';

class VisitDetailsPage extends StatelessWidget {
  final Map<String, dynamic> patientData;
  final Map<String, dynamic> visitData;

  const VisitDetailsPage({
    super.key,
    required this.patientData,
    required this.visitData,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: BackButton(color: Colors.black),
        title: const Text(
          "Visit Details",
          style: TextStyle(color: Colors.black),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// Visit Information

            _buildSectionTitle("Visit Information"),

            _buildInfoCard(),

            const SizedBox(height: 25),

            /// Laboratory Requests

            _buildSectionTitle("Laboratory Requests"),

            _buildLaboratoryCard(),

            const SizedBox(height: 25),

            /// Doctor Remarks

            _buildSectionTitle("Doctor Remarks"),

            _buildDoctorCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Text("Visit Information"),
      ),
    );
  }

  Widget _buildLaboratoryCard() {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Text("Laboratory Requests"),
      ),
    );
  }

  Widget _buildDoctorCard() {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Text("Doctor Remarks"),
      ),
    );
  }
}