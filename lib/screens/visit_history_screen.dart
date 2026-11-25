import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VisitHistoryScreen extends StatelessWidget {
  final String patientId;
  final String patientName;
  final String patientAge;
  final String patientGender;
  final String patientAddress;

  const VisitHistoryScreen({
    super.key,
    required this.patientId,
    required this.patientName,
    required this.patientAge,
    required this.patientGender,
    required this.patientAddress,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [

            /// Header
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
                const Expanded(
                  child: Text(
                    "Patient Record",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),

            const SizedBox(height: 10),

            /// Patient Info Card
            Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [

                      Text(
                        patientName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text("Patient ID: $patientId"),
                      Text("Age: $patientAge"),
                      Text("Gender: $patientGender"),
                      Text("Address: $patientAddress"),
                    ],
                  ),
                ),
              ),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Visit History",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 8),

            /// Visits List
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('patients')
                    .doc(patientId)
                    .collection('visits')
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {

                  if (snapshot.hasError) {
                    return const Center(
                        child: Text("Error loading visits"));
                  }

                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator());
                  }

                  final visits = snapshot.data!.docs;

                  if (visits.isEmpty) {
                    return const Center(
                        child: Text("No visits recorded"));
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: visits.length,
                    itemBuilder: (context, index) {

                      final visit = visits[index];
                      final data =
                          visit.data() as Map<String, dynamic>;

                      final reason =
                          data['reasonForVisit'] ?? '';

                      final tests = [
                        ...List<String>.from(data['hematology'] ?? []),
                        ...List<String>.from(data['clinicalMicroscopy'] ?? []),
                        ...List<String>.from(data['bloodChemistry'] ?? []),
                        ...List<String>.from(data['immunology'] ?? []),
                        ...List<String>.from(data['radiology'] ?? []),
                        ...List<String>.from(data['others'] ?? []),
                      ];

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [

                              /// Visit Date
                              Text(
                                data['dateOfVisit'] ?? 'No Date',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),

                              const SizedBox(height: 6),

                              /// Reason
                              if (reason.isNotEmpty)
                                Text(
                                  "Reason: $reason",
                                  style: const TextStyle(
                                      fontStyle: FontStyle.italic),
                                ),

                              const SizedBox(height: 8),

                              /// Tests
                              if (tests.isEmpty)
                                const Text(
                                    "No laboratory tests selected")
                              else
                                Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: tests
                                      .map(
                                        (e) => Text("• $e"),
                                      )
                                      .toList(),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}