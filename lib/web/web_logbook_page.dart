import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'logbook_report_service.dart';

class WebLogbook extends StatefulWidget {
  const WebLogbook({super.key});

  @override
  State<WebLogbook> createState() => _WebLogbookState();
}

class _WebLogbookState extends State<WebLogbook> {
  String searchQuery = "";
  int currentPage = 1;
  final int rowsPerPage = 10;

////////////////////////////////////////////////////////////
/// GET PATIENT MAP
////////////////////////////////////////////////////////////

  Future<Map<String, Map<String, dynamic>>> _getPatientMap() async {
    final patientsSnapshot =
        await FirebaseFirestore.instance.collection('patients').get();

    return {
      for (var p in patientsSnapshot.docs) p.id: p.data(),
    };
  }

////////////////////////////////////////////////////////////
/// EXPORT TODAY
////////////////////////////////////////////////////////////

  Future<void> _exportToday() async {
    final patientMap = await _getPatientMap();

    final visitsSnapshot =
        await FirebaseFirestore.instance.collectionGroup('visits').get();

    final today = DateTime.now();

    List<Map<String, dynamic>> visits = [];

    for (var doc in visitsSnapshot.docs) {
      final visitData = doc.data();

      final date = DateTime.tryParse(visitData['dateOfVisit'] ?? '');
      if (date == null) continue;

      if (date.year == today.year &&
          date.month == today.month &&
          date.day == today.day) {
        final parent = doc.reference.parent.parent;
        final patient = parent != null ? patientMap[parent.id] : null;

        if (patient == null) continue;

        visits.add({
          ...visitData,
          "patientName": patient['patientName'] ?? "",
          "age": patient['age'] ?? "",
          "gender": patient['gender'] ?? "",
          "address": patient['address'] ?? "",
          "reasonForVisit": visitData['reasonForVisit'] ??
              visitData['chiefComplaint'] ??
              "",
        });
      }
    }

    await generateLogbookReport(
      visits: visits,
      title: "Today's Clinic Visits",
    );
  }

////////////////////////////////////////////////////////////
/// EXPORT MONTH
////////////////////////////////////////////////////////////

  Future<void> _exportMonth() async {
    final patientMap = await _getPatientMap();

    final visitsSnapshot =
        await FirebaseFirestore.instance.collectionGroup('visits').get();

    final now = DateTime.now();

    List<Map<String, dynamic>> visits = [];

    for (var doc in visitsSnapshot.docs) {
      final visitData = doc.data();

      final date = DateTime.tryParse(visitData['dateOfVisit'] ?? '');
      if (date == null) continue;

      if (date.year == now.year && date.month == now.month) {
        final parent = doc.reference.parent.parent;
        final patient = parent != null ? patientMap[parent.id] : null;

        if (patient == null) continue;

        visits.add({
          ...visitData,
          "patientName": patient['patientName'] ?? "",
          "age": patient['age'] ?? "",
          "gender": patient['gender'] ?? "",
          "address": patient['address'] ?? "",
          "reasonForVisit": visitData['reasonForVisit'] ??
              visitData['chiefComplaint'] ??
              "",
        });
      }
    }

    await generateLogbookReport(
      visits: visits,
      title: "Monthly Clinic Visits",
    );
  }

////////////////////////////////////////////////////////////
/// CUSTOM RANGE MODAL
////////////////////////////////////////////////////////////

  Future<void> _openCustomRangeModal() async {
    DateTime? startDate;
    DateTime? endDate;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Custom Logbook Report"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: Text(
                      startDate == null
                          ? "Select Start Date"
                          : startDate!.toString().split(' ')[0],
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );

                      if (picked != null) {
                        setDialogState(() {
                          startDate = picked;
                        });
                      }
                    },
                  ),
                  ListTile(
                    title: Text(
                      endDate == null
                          ? "Select End Date"
                          : endDate!.toString().split(' ')[0],
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );

                      if (picked != null) {
                        setDialogState(() {
                          endDate = picked;
                        });
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  child: const Text("Generate Report"),
                  onPressed: () async {
                    if (startDate == null || endDate == null) return;

                    Navigator.pop(context);

                    final patientMap = await _getPatientMap();

                    final visitsSnapshot = await FirebaseFirestore.instance
                        .collectionGroup('visits')
                        .get();

                    List<Map<String, dynamic>> visits = [];

                    for (var doc in visitsSnapshot.docs) {
                      final visitData = doc.data();

                      final date =
                          DateTime.tryParse(visitData['dateOfVisit'] ?? '');
                      if (date == null) continue;

                      if (date.isAfter(
                              startDate!.subtract(const Duration(days: 1))) &&
                          date.isBefore(
                              endDate!.add(const Duration(days: 1)))) {
                        final parent = doc.reference.parent.parent;
                        final patient =
                            parent != null ? patientMap[parent.id] : null;

                        if (patient == null) continue;

                        visits.add({
                          ...visitData,
                          "patientName": patient['patientName'] ?? "",
                          "age": patient['age'] ?? "",
                          "gender": patient['gender'] ?? "",
                          "address": patient['address'] ?? "",
                          "reasonForVisit": visitData['reasonForVisit'] ??
                              visitData['chiefComplaint'] ??
                              "",
                        });
                      }
                    }

                    await generateLogbookReport(
                      visits: visits,
                      title:
                          "Clinic Report (${startDate!.toString().split(' ')[0]} - ${endDate!.toString().split(' ')[0]})",
                    );
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

////////////////////////////////////////////////////////////
/// UI
////////////////////////////////////////////////////////////

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(40),
      color: const Color(0xFFF4F6FA),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Clinic Logbook",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          _buildSearchBar(),
          const SizedBox(height: 15),
          _buildExportButtons(),
          const SizedBox(height: 20),
          Expanded(child: _buildTable()),
        ],
      ),
    );
  }

////////////////////////////////////////////////////////////
/// SEARCH
////////////////////////////////////////////////////////////

  Widget _buildSearchBar() {
    return SizedBox(
      width: 350,
      child: TextField(
        decoration: InputDecoration(
          hintText: "Search patient name...",
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
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
/// EXPORT BUTTONS
////////////////////////////////////////////////////////////

  Widget _buildExportButtons() {
    return Row(
      children: [
        ElevatedButton.icon(
          icon: const Icon(Icons.picture_as_pdf),
          label: const Text("Export Today"),
          onPressed: _exportToday,
        ),
        const SizedBox(width: 10),
        ElevatedButton.icon(
          icon: const Icon(Icons.picture_as_pdf),
          label: const Text("Export This Month"),
          onPressed: _exportMonth,
        ),
        const SizedBox(width: 10),
        ElevatedButton.icon(
          icon: const Icon(Icons.date_range),
          label: const Text("Custom Range"),
          onPressed: _openCustomRangeModal,
        ),
      ],
    );
  }

////////////////////////////////////////////////////////////
/// TABLE
////////////////////////////////////////////////////////////

  Widget _buildTable() {
    return FutureBuilder<List<QuerySnapshot<Map<String, dynamic>>>>(
      future: Future.wait([
        FirebaseFirestore.instance.collection('patients').get(),
        FirebaseFirestore.instance.collectionGroup('visits').get(),
      ]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final patients = snapshot.data![0].docs;
        final visits = snapshot.data![1].docs;

        final patientMap = {
          for (var p in patients) p.id: p.data(),
        };

        final filtered = visits.where((visit) {
          final parent = visit.reference.parent.parent;
          final patient = parent != null ? patientMap[parent.id] : null;

          if (patient == null) return false;

          final name = (patient['patientName'] ?? "")
              .toString()
              .toLowerCase();

          return name.contains(searchQuery);
        }).toList();

        if (filtered.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(30),
            decoration: _cardDecoration(),
            child: const Center(
              child: Text("No logbook records found"),
            ),
          );
        }

        final totalPages =
            (filtered.length / rowsPerPage).ceil().clamp(1, 999);

        final safeCurrentPage =
            currentPage > totalPages ? totalPages : currentPage;

        final start = (safeCurrentPage - 1) * rowsPerPage;

        final end = (start + rowsPerPage) > filtered.length
            ? filtered.length
            : start + rowsPerPage;

        final pageData = filtered.sublist(start, end);

        return Container(
          padding: const EdgeInsets.all(30),
          decoration: _cardDecoration(),
          child: Column(
            children: [
              _buildHeader(),
              const Divider(height: 30),
              Expanded(
                child: ListView.builder(
                  itemCount: pageData.length,
                  itemBuilder: (context, index) {
                    final visit = pageData[index];
                    final visitData = visit.data();

                    final parent = visit.reference.parent.parent;
                    final patient =
                        parent != null ? patientMap[parent.id] : null;

                    if (patient == null) {
                      return const SizedBox.shrink();
                    }

                    final labs = _extractLabs(visitData);
                    final reasonForVisit =
                        (visitData['reasonForVisit'] ??
                                visitData['chiefComplaint'] ??
                                "")
                            .toString();

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(visitData['dateOfVisit'] ?? ""),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(patient['patientName'] ?? ""),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(patient['age']?.toString() ?? ""),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(patient['gender'] ?? ""),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(patient['address'] ?? ""),
                          ),
                          Expanded(
                            flex: 4,
                            child: Text(
                              reasonForVisit.isEmpty
                                  ? "No Reason"
                                  : reasonForVisit,
                            ),
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
                  },
                ),
              ),
              const SizedBox(height: 20),
              _buildPagination(totalPages, safeCurrentPage),
            ],
          ),
        );
      },
    );
  }

////////////////////////////////////////////////////////////
/// HEADER
////////////////////////////////////////////////////////////

  Widget _buildHeader() {
    return const Row(
      children: [
        Expanded(
          flex: 2,
          child: Text("Date",
              style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        Expanded(
          flex: 3,
          child: Text("Name",
              style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        Expanded(
          flex: 1,
          child: Text("Age",
              style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        Expanded(
          flex: 2,
          child: Text("Gender",
              style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        Expanded(
          flex: 3,
          child: Text("Address",
              style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        Expanded(
          flex: 4,
          child: Text("Reason for Visit",
              style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        Expanded(
          flex: 4,
          child: Text("Laboratory Tests",
              style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

////////////////////////////////////////////////////////////
/// PAGINATION
////////////////////////////////////////////////////////////

  Widget _buildPagination(int totalPages, int safeCurrentPage) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: safeCurrentPage > 1
              ? () => setState(() => currentPage = safeCurrentPage - 1)
              : null,
        ),
        Text("Page $safeCurrentPage of $totalPages"),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: safeCurrentPage < totalPages
              ? () => setState(() => currentPage = safeCurrentPage + 1)
              : null,
        ),
      ],
    );
  }

////////////////////////////////////////////////////////////
/// UTILITIES
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
}