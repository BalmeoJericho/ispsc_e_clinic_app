import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'web_sidebar.dart';
import 'pdf_service.dart';
import 'lab_form_report_service.dart'; 
import 'web_visit_details.dart';

class PatientDetailsPage extends StatefulWidget {
  final String patientId;
  final Map<String, dynamic> patientData;

  const PatientDetailsPage({
    super.key,
    required this.patientId,
    required this.patientData,
  });

  @override
  State<PatientDetailsPage> createState() =>
      _PatientDetailsPageState();
}

class _PatientDetailsPageState extends State<PatientDetailsPage> {
  int selectedIndex = 1;

 @override
Widget build(BuildContext context) {
 

  return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),

      body: Row(
        children: [

          /// SIDEBAR
          WebSidebar(
            selectedIndex: selectedIndex,
            onItemSelected: (index) {},
          ),

          /// MAIN CONTENT
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(40),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

////////////////////////////////////////////////////////////
/// HEADER
////////////////////////////////////////////////////////////

                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [

                      Row(
                        children: [

                          TextButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon:
                                const Icon(Icons.arrow_back),
                            label:
                                const Text("Back to Patients"),
                          ),

                          const SizedBox(width: 20),

                          
                        ],
                      ),

////////////////////////////////////////////////////////////
/// BUTTONS (UPDATED)
////////////////////////////////////////////////////////////

                      Row(
                        children: [

                          /// PATIENT REPORT
                          ElevatedButton.icon(
                            icon:
                                const Icon(Icons.picture_as_pdf),
                            label:
                                const Text("Download Record"),
                            onPressed: () async {
                              final snapshot =
                                  await FirebaseFirestore
                                      .instance
                                      .collection('patients')
                                      .doc(widget.patientId)
                                      .collection('visits')
                                      .orderBy('createdAt',
                                          descending: true)
                                      .get();

                              final visits = snapshot.docs
                                  .map((e) => e.data())
                                  .toList();

                              await generatePatientPdf(
                                patient: widget.patientData,
                                visits: visits,
                              );
                            },
                          ),

                          const SizedBox(width: 10),

                          /// LAB FORM (NEW)
                          ElevatedButton.icon(
                            icon:
                                const Icon(Icons.description),
                            label: const Text("Lab Form"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 253, 253, 253),
                            ),
                            onPressed: () async {
                              final snapshot =
                                  await FirebaseFirestore
                                      .instance
                                      .collection('patients')
                                      .doc(widget.patientId)
                                      .collection('visits')
                                      .orderBy('createdAt',
                                          descending: true)
                                      .limit(1)
                                      .get();

                              if (snapshot.docs.isEmpty) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        "No visit found"),
                                  ),
                                );
                                return;
                              }

                              final visit =
                                  snapshot.docs.first.data();

                              await generateLabFormReport(
                                patient: widget.patientData,
                                visit: visit,
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

////////////////////////////////////////////////////////////
/// PATIENT INFO
////////////////////////////////////////////////////////////

                 Container(
  padding: const EdgeInsets.all(12),
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(20),
    gradient: const LinearGradient(
      colors: [
        Color(0xFF568BDB),
        Color(0xFF1E3A5F),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black12,
        blurRadius: 20,
        offset: Offset(0, 8),
      ),
    ],
  ),
  child: Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [

      /// PHOTO
      Container(
        width: 110,
        height: 140,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: widget.patientData['photoUrl'] != null &&
                widget.patientData['photoUrl']
                    .toString()
                    .isNotEmpty
            ? ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.network(
                  widget.patientData['photoUrl'],
                  fit: BoxFit.cover,
                ),
              )
            : const Icon(
                Icons.person,
                size: 60,
                color: Color(0xff4F7DF3),
              ),
      ),

      const SizedBox(width: 16),

      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Row(
              children: [

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      const Text(
                        "ISPSC E-CLINIC",
                        style: TextStyle(
                          color: Colors.white70,
                          letterSpacing: 3,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              widget.patientData['fullName'] ?? '',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),

                          const SizedBox(width: 8),

                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: (widget.patientData['status'] ?? '')
                                      .toString()
                                      .toLowerCase() ==
                                  'active'
                                  ? Colors.green
                                  : Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 6),

                      Text(
                        widget.patientData['role']
                                ?.toString()
                                .toUpperCase() ??
                            "",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),

                
              ],
            ),

            const SizedBox(height: 18),

            /// FIRST ROW
            Row(
              children: [

                Expanded(
                  child: _infoColumn(
                    "Employee ID",
                    widget.patientData['employeeId'] ?? '',
                  ),
                ),

                Expanded(
                  child: _infoColumn(
                    "Department",
                    widget.patientData['department'] ?? '',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            /// SECOND ROW
            Row(
              children: [

                Expanded(
                  child: _infoColumn(
                    "Staff Type",
                    widget.patientData['staffType'] ?? '',
                  ),
                ),

                Expanded(
                  child: _infoColumn(
                    "Email",
                    widget.patientData['email'] ?? '',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

          ],
        ),
      ),
    ],
  ),
),

                  const SizedBox(height: 20),

                  const Text(
                    "Visit History",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

////////////////////////////////////////////////////////////
/// VISITS
////////////////////////////////////////////////////////////

                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('patients')
                          .doc(widget.patientId)
                          .collection('visits')
                          .orderBy('createdAt',
                              descending: true)
                          .snapshots(),

                      builder: (context, snapshot) {

                        if (!snapshot.hasData) {
                          return const Center(
                            child:
                                CircularProgressIndicator(),
                          );
                        }

                        final visits =
                            snapshot.data!.docs;

                        if (visits.isEmpty) {
                          return const Center(
                            child: Text(
                                "No visit records"),
                          );
                        }

                        return ListView.builder(
                          itemCount: visits.length,

                          itemBuilder: (context, index) {

                            final visit = visits[index
                                    ].data()
                                as Map<String, dynamic>;

                            final tests = [

                              ...List<String>.from(
                                  visit['hematology'] ??
                                      []),

                              ...List<String>.from(
                                  visit[
                                          'clinicalMicroscopy'] ??
                                      []),

                              ...List<String>.from(
                                  visit[
                                          'bloodChemistry'] ??
                                      []),

                              ...List<String>.from(
                                  visit['immunology'] ??
                                      []),

                              ...List<String>.from(
                                  visit['radiology'] ??
                                      []),

                              ...List<String>.from(
                                  visit['others'] ?? []),
                            ];

                            return Container(
                              margin:
                                  const EdgeInsets.only(
                                      bottom: 15),
                              padding:
                                  const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.circular(
                                        10),
                                boxShadow: [
                                  BoxShadow(
                                    blurRadius: 6,
                                    color: Colors.black
                                        .withOpacity(0.04),
                                  )
                                ],
                              ),

                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                children: [

                                  Text(
                                    visit['dateOfVisit'] ??
                                        '',
                                    style:
                                        const TextStyle(
                                      fontWeight:
                                          FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),

                                  const SizedBox(
                                      height: 6),



                                  const SizedBox(
                                      height: 10),

                                  if (tests.isEmpty)
                                    const Text(
                                        "No tests recorded")
                                  else
                                    Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [

                                      const Text(
                                        "Laboratory Request",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),

                                      const SizedBox(height: 8),

                                      ...tests.map(
                                        (e) => Padding(
                                          padding: const EdgeInsets.only(bottom: 4),
                                          child: Row(
                                            children: [
                                              const Icon(
                                                Icons.check_circle,
                                                color: Colors.green,
                                                size: 18,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(e),
                                            ],
                                          ),
                                        ),
                                      ),

                                      const SizedBox(height: 15),

                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: TextButton.icon(
                                          onPressed: () {

                                          },
                                          icon: const Icon(Icons.visibility_outlined),
                                          label: const Text("View Details"),
                                        ),
                                      ),
                                    ],
                                  )
                                ],
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
          ),
        ],
      ),
    );
  }
  Widget _infoColumn(String title, String value) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 12,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        value,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 17,
          fontWeight: FontWeight.bold,
        ),
      ),
    ],
  );
}
}