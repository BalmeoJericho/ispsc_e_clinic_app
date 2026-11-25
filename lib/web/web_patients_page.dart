import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'web_patient_details.dart';
import 'web_edit_patient_dialog.dart';
import 'activity_log_service.dart';
import '../services/employee_service.dart';
import '../models/employee_model.dart';

class WebPatients extends StatefulWidget {
  const WebPatients({super.key});

  @override
  State<WebPatients> createState() => _WebPatientsState();
}

class _WebPatientsState extends State<WebPatients> {

  final EmployeeService _employeeService = EmployeeService();

  String searchQuery = '';
  int currentPage = 1;
  final int rowsPerPage = 10;

  String sortColumn = "createdAt";
  bool ascending = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF4F6FA),
      padding: const EdgeInsets.all(40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Patients Records",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          const Text(
            "Manage employee medical records, laboratory requests, laboratory results, and visit history.",
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 12),
          const SizedBox(height: 30),
          _buildSearchField(),
          const SizedBox(height: 12),
          Expanded(child: _buildTable()),
        ],
      ),
    );
  }

////////////////////////////////////////////////////////////
/// SEARCH FIELD
////////////////////////////////////////////////////////////

  Widget _buildSearchField() {
  return SizedBox(
    height: 56,
    child: TextField(
      decoration: InputDecoration(
        hintText: "Search employee...",
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onChanged: (value) {
        setState(() {
          searchQuery = value.toLowerCase();
          currentPage = 1;
        });
      },
    ),
  );
}

////////////////////////////////////////////////////////////
/// TABLE
////////////////////////////////////////////////////////////

  Widget _buildTable() {
  return StreamBuilder<List<EmployeeModel>>(
    stream: _employeeService.getEmployees(),
    builder: (context, patientSnapshot) {

      if (!patientSnapshot.hasData) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }

        final patients = patientSnapshot.data!;

        return FutureBuilder<QuerySnapshot>(
          future: FirebaseFirestore.instance.collectionGroup('visits').get(),
          builder: (context, visitSnapshot) {
            if (!visitSnapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final visits = visitSnapshot.data!.docs;

////////////////////////////////////////////////////////////
/// LAST VISIT MAP
////////////////////////////////////////////////////////////

            final Map<String, Map<String, dynamic>> latestVisitMap = {};

            for (var visit in visits) {
              final parent = visit.reference.parent.parent;
              if (parent == null) continue;

              final visitData = visit.data() as Map<String, dynamic>;
              final dateString = visitData['dateOfVisit'];

              if (dateString == null) continue;

              DateTime? visitDate;

              try {
                visitDate = DateTime.parse(dateString);
              } catch (_) {
                continue;
              }

              if (!latestVisitMap.containsKey(parent.id)) {
                latestVisitMap[parent.id] = visitData;
              } else {
                final existingDateString =
                    latestVisitMap[parent.id]!['dateOfVisit'];

                try {
                  final existingDate = DateTime.parse(existingDateString);

                  if (visitDate.isAfter(existingDate)) {
                    latestVisitMap[parent.id] = visitData;
                  }
                } catch (_) {}
              }
            }

////////////////////////////////////////////////////////////
/// FILTER
////////////////////////////////////////////////////////////

            final filteredPatients = patients.where((patient) {
              return patient.fullName
                  .toLowerCase()
                  .contains(searchQuery);
            }).toList();

////////////////////////////////////////////////////////////
/// SORTING
////////////////////////////////////////////////////////////

            filteredPatients.sort((a, b) {
              dynamic valueA;
              dynamic valueB;

              switch (sortColumn) {
                case 'employeeId':
                  valueA = a.employeeId;
                  valueB = b.employeeId;
                  break;

                case 'fullName':
                  valueA = a.fullName;
                  valueB = b.fullName;
                  break;

                case 'department':
                  valueA = a.department;
                  valueB = b.department;
                  break;

                default:
                  valueA = a.createdAt?.millisecondsSinceEpoch ?? 0;
                  valueB = b.createdAt?.millisecondsSinceEpoch ?? 0;
              }

              final result = valueA
                  .toString()
                  .compareTo(valueB.toString());

              return ascending ? result : -result;
            });

            

////////////////////////////////////////////////////////////
/// PAGINATION
////////////////////////////////////////////////////////////

            final totalPages =
                (filteredPatients.length / rowsPerPage).ceil().clamp(1, 999);

            final start = (currentPage - 1) * rowsPerPage;

            final end = (start + rowsPerPage) > filteredPatients.length
                ? filteredPatients.length
                : start + rowsPerPage;

            final pagePatients = filteredPatients.sublist(start, end);

////////////////////////////////////////////////////////////
/// TABLE CARD
////////////////////////////////////////////////////////////

            return Container(
              
              decoration: _cardDecoration(),
              child: Column(
                children: [
                  _buildHeader(),
                  const Divider(height: 1),
                  Expanded(
                    child: ListView.builder(
                      itemCount: pagePatients.length,
                      itemBuilder: (context, index) {
                        final patient = pagePatients[index];
                        final visitData = latestVisitMap[patient.uid];

                        return _buildRow(patient, visitData);
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildPagination(totalPages),
                ],
              ),
            );
          },
        );
      },
    );
  }

////////////////////////////////////////////////////////////
/// HEADER WITH SORT ARROWS
////////////////////////////////////////////////////////////

  Widget _buildHeader() {
    Widget headerCell(String label, String column) {
      final isActive = sortColumn == column;

      return InkWell(
        onTap: () {
          setState(() {
            if (sortColumn == column) {
              ascending = !ascending;
            } else {
              sortColumn = column;
              ascending = true;
            }
          });
        },
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isActive ? Colors.blue : Colors.black,
              ),
            ),
            const SizedBox(width: 4),
            if (isActive)
              Icon(
                ascending ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                size: 18,
                color: Colors.blue,
              ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
      decoration: const BoxDecoration(
        
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: headerCell("Employee ID", "employeeId"),
          ),
          Expanded(
            flex: 3,
            child: headerCell("Employee Name", "name"),
          ),
          Expanded(
            flex: 2,
            child: headerCell("Staff Type", "staffType"),
          ),
          Expanded(
            flex: 2,
            child: headerCell("Department", "department"),
          ),
          Expanded(
            flex: 2,
            child: headerCell("Last Visit", "lastVisit"),
          ),
          Expanded(
            flex: 1,
            child: Align(
              alignment: Alignment.center,
              child: Text(
                "Action",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

////////////////////////////////////////////////////////////
/// ROW
////////////////////////////////////////////////////////////

  Widget _buildRow(
  EmployeeModel patient,
  Map<String, dynamic>? visitData,
) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        hoverColor: Colors.grey.shade100,
        splashColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 30,
            vertical: 14,
          ),
          
          child: Row(
  children: [
    Expanded(
      flex: 2,
      child: Text(
        patient.employeeId,
        
      ),
    ),
    Expanded(
      flex: 3,
      child: Text(patient.fullName),
    ),
    Expanded(
  flex: 2,
      child: Text(patient.staffType),
    ),
    Expanded(
      flex: 2,
      child: Text(patient.department),
    ),
    Expanded(
      flex: 2,
      child: Text(visitData?['dateOfVisit'] ?? 'No Visit'),
    ),
    Expanded(
      flex: 1,
      child: PopupMenuButton<String>(
        icon: const Icon(Icons.more_vert),
        onSelected: (value) async {
          if (value == "view") {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => 
                PatientDetailsPage(
                  patientId: patient.uid,
                  patientData: {
                    'fullName': patient.fullName,
                    'employeeId': patient.employeeId,
                    'email': patient.email,
                    'department': patient.department,
                    'staffType': patient.staffType,
                    'role': patient.role,
                    'status': patient.status,
                    'photoUrl': patient.photoUrl,
                  },
                )
              ),
            );
          }

          if (value == "edit") {
            await showDialog(
              context: context,
              builder: (_) => EditPatientDialog(
                patientId: patient.uid,
                patientData: {}, // temporary
              ),
            );

            setState(() {});
          }

          
        },
        itemBuilder: (context) => const [
          PopupMenuItem(
            value: "view",
            child: Text("View Record"),
          ),
          
          
        ],
      ),
    ),
  ],
),
        ),
      ),
    );
  }

////////////////////////////////////////////////////////////
/// PAGINATION
////////////////////////////////////////////////////////////

  Widget _buildPagination(int totalPages) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed:
              currentPage > 1 ? () => setState(() => currentPage--) : null,
        ),
        Text("Page $currentPage of $totalPages"),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed:
              currentPage < totalPages ? () => setState(() => currentPage++) : null,
        ),
      ],
    );
  }

////////////////////////////////////////////////////////////
/// CARD STYLE
////////////////////////////////////////////////////////////

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