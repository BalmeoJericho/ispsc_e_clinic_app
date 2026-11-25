import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'scan_screen.dart';
import 'visit_history_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() =>
      _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int currentIndex = 0;
  String searchQuery = '';

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: currentIndex == 0
            ? _buildPatientsPage()
            : _buildSettingsPage(),
      ),

      /// Scan Button
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.camera_alt),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const ScanScreen(),
            ),
          );
        },
      ),

      floatingActionButtonLocation:
          FloatingActionButtonLocation.centerDocked,

      /// Bottom Navigation
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 6,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: Icon(
                  Icons.folder,
                  color: currentIndex == 0
                      ? Theme.of(context)
                          .colorScheme
                          .primary
                      : Colors.grey,
                ),
                onPressed: () {
                  setState(() => currentIndex = 0);
                },
              ),

              const SizedBox(width: 40),

              IconButton(
                icon: Icon(
                  Icons.settings,
                  color: currentIndex == 1
                      ? Theme.of(context)
                          .colorScheme
                          .primary
                      : Colors.grey,
                ),
                onPressed: () {
                  setState(() => currentIndex = 1);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  ////////////////////////////////////////////////////////////
  /// PATIENTS PAGE
  ////////////////////////////////////////////////////////////

  Widget _buildPatientsPage() {
    return Column(
      children: [

        /// Search Bar
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            decoration: const InputDecoration(
              hintText: "Search patient...",
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() {
                searchQuery =
                    value.toLowerCase().trim();
              });
            },
          ),
        ),

        /// Patient List
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('patients')
                .orderBy('createdAt',
                    descending: true)
                .snapshots(),
            builder: (context, snapshot) {

              if (snapshot.hasError) {
                return const Center(
                    child: Text(
                        "Error loading patients"));
              }

              if (snapshot.connectionState ==
                  ConnectionState.waiting) {
                return const Center(
                    child:
                        CircularProgressIndicator());
              }

              final patients = snapshot.data!.docs
                  .where((doc) {
                final name =
                    (doc['patientName'] ?? '')
                        .toString()
                        .toLowerCase();

                return name.contains(searchQuery);
              }).toList();

              if (patients.isEmpty) {
                return const Center(
                    child: Text("No patients found"));
              }

              return ListView.builder(
                padding:
                    const EdgeInsets.all(16),
                itemCount: patients.length,
                itemBuilder:
                    (context, index) {

                  final patient =
                      patients[index];

                  final name =
                      patient['patientName'] ??
                          '';

                  final age =
                      patient['age'] ?? '';

                  final gender =
                      patient['gender'] ?? '';

                  final address =
                      patient['address'] ?? '';

                  return StreamBuilder<
                          QuerySnapshot>(
                      stream: FirebaseFirestore
                          .instance
                          .collection(
                              'patients')
                          .doc(patient.id)
                          .collection(
                              'visits')
                          .snapshots(),
                      builder: (context,
                          visitSnapshot) {

                        int visitCount =
                            visitSnapshot.hasData
                                ? visitSnapshot
                                    .data!
                                    .docs
                                    .length
                                : 0;

                        return Card(
                          margin:
                              const EdgeInsets
                                  .only(
                                      bottom:
                                          12),

                          child: ListTile(
                            leading:
                                const CircleAvatar(
                              child:
                                  Icon(Icons.person),
                            ),

                            title: Text(
                              name,
                              style:
                                  const TextStyle(
                                fontWeight:
                                    FontWeight
                                        .bold,
                              ),
                            ),

                            subtitle: Text(
                              "Patient ID: ${patient.id.substring(0, 8)}\n"
                              "Age: $age | $gender\n"
                              "Total Visits: $visitCount",
                            ),

                            isThreeLine:
                                true,

                            trailing:
                                const Icon(
                              Icons
                                  .arrow_forward_ios,
                              size: 16,
                            ),

                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      VisitHistoryScreen(
                                    patientId:
                                        patient
                                            .id,
                                    patientName:
                                        name,
                                    patientAge:
                                        age,
                                    patientGender:
                                        gender,
                                    patientAddress:
                                        address,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      });
                },
              );
            },
          ),
        ),
      ],
    );
  }

  ////////////////////////////////////////////////////////////
  /// SETTINGS PAGE
  ////////////////////////////////////////////////////////////

  Widget _buildSettingsPage() {
    final user =
        FirebaseAuth.instance.currentUser;

    return ListView(
      padding:
          const EdgeInsets.all(16),
      children: [

        /// User Info
        ListTile(
          leading: const Icon(Icons.person),
          title:
              Text(user?.email ?? "User"),
        ),

        const Divider(),

        /// Logout
        ListTile(
          leading: const Icon(Icons.logout),
          title: const Text("Logout"),
          onTap: logout,
        ),
      ],
    );
  }
}