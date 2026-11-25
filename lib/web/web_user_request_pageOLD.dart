import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/lab_request_model.dart';
import '../services/lab_request_service.dart';

class WebUserRequestPage extends StatefulWidget {
  const WebUserRequestPage({super.key});

  @override
  State<WebUserRequestPage> createState() => _WebUserRequestPageState();
}

class _WebUserRequestPageState extends State<WebUserRequestPage> {
  final LabRequestService _service = LabRequestService();

  final TextEditingController _searchController = TextEditingController();

  String _search = "";

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          const Text(
            "Laboratory Requests",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 6),

          const Text(
            "Manage employee laboratory requests.",
            style: TextStyle(color: Colors.grey),
          ),

          const SizedBox(height: 24),

          SizedBox(
  width: 420,
  child: TextField(
    controller: _searchController,
    onChanged: (value) {
      setState(() {
        _search = value.toLowerCase();
      });
    },
    decoration: InputDecoration(
      hintText: "Search employee...",
      hintStyle: TextStyle(
        color: Colors.grey.shade600,
      ),
      prefixIcon: const Icon(
        Icons.search,
        color: Colors.black54,
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 18),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    ),
  ),
),

const SizedBox(height: 20),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("lab_requests")
                  .orderBy("createdAt", descending: true)
                  .snapshots(),
              builder: (context, snapshot) {

                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(
                    child: Text("No requests found."),
                  );
                }

                final requests = snapshot.data!.docs
                    .map((e) => LabRequestModel.fromFirestore(e))
                    .where((e) =>
                        e.employeeName
                            .toLowerCase()
                            .contains(_search))
                    .toList();

                if (requests.isEmpty) {
                  return const Center(
                    child: Text("No matching requests."),
                  );
                }

                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowHeight: 60,
                      dataRowMinHeight: 60,
                      dataRowMaxHeight: 60,
                      columnSpacing: 40,
                      columns: const [

                          DataColumn(
                            label: SizedBox(
                              width: 220,
                              child: Text(
                                "Employee",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),

                          DataColumn(
                            label: SizedBox(
                              width: 180,
                              child: Text(
                                "Laboratory Test",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),

                          DataColumn(
                            label: SizedBox(
                              width: 160,
                              child: Text(
                                "Requested",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),

                          DataColumn(
                            label: SizedBox(
                              width: 120,
                              child: Text(
                                "Status",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),

                          DataColumn(
                            label: SizedBox(
                              width: 80,
                              child: Center(
                                child: Text(
                                  "Actions",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                        ],

                        rows: requests.map((request) {
                          return DataRow(
                            cells: [

                              DataCell(
                                SizedBox(
                                  width: 220,
                                  child: Text(
                                    request.employeeName,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),

                              DataCell(
                                SizedBox(
                                  width: 180,
                                  child: Text(
                                    request.testType,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),

                              DataCell(
                                SizedBox(
                                  width: 160,
                                  child: Text(
                                    request.createdAt == null
                                        ? "-"
                                        : "${request.createdAt!.toDate().month}/${request.createdAt!.toDate().day}/${request.createdAt!.toDate().year}",
                                  ),
                                ),
                              ),

                              DataCell(
                                SizedBox(
                                  width: 120,
                                  child: _buildStatusChip(request.status),
                                ),
                              ),

                              DataCell(
                                SizedBox(
                                  width: 80,
                                  child: Center(
                                    child: PopupMenuButton<String>(
                                      onSelected: (value) {
                                        switch (value) {
                                          case 'view':
                                            _viewRequest(request);
                                            break;

                                          case 'approve':
                                            _approveRequest(request);
                                            break;

                                          case 'reject':
                                            _rejectRequest(request);
                                            break;

                                          case 'delete':
                                            _deleteRequest(request);
                                            break;
                                        }
                                      },
                                      itemBuilder: (_) => const [

                                        PopupMenuItem(
                                          value: 'view',
                                          child: Text('View'),
                                        ),

                                        PopupMenuItem(
                                          value: 'approve',
                                          child: Text('Approve'),
                                        ),

                                        PopupMenuItem(
                                          value: 'reject',
                                          child: Text('Reject'),
                                        ),

                                        PopupMenuDivider(),

                                        PopupMenuItem(
                                          value: 'delete',
                                          child: Text('Delete'),
                                        ),

                                      ],
                                    ),
                                  ),
                                ),
                              ),

                            ],
                          );
                        }).toList(),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildStatusChip(String status) {
  Color color;

  switch (status.toLowerCase()) {
    case "approved":
      color = Colors.green;
      break;

    case "rejected":
      color = Colors.red;
      break;

    case "completed":
      color = Colors.blue;
      break;

    default:
      color = Colors.orange;
  }

  return Container(
    padding: const EdgeInsets.symmetric(
      horizontal: 12,
      vertical: 6,
    ),
    decoration: BoxDecoration(
      color: color.withOpacity(.12),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      status,
      style: TextStyle(
        color: color,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}

void _viewRequest(LabRequestModel request) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text("Laboratory Request"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Employee: ${request.employeeName}"),
          const SizedBox(height: 8),
          Text("Test: ${request.testType}"),
          const SizedBox(height: 8),
          Text("Status: ${request.status}"),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Close"),
        ),
      ],
    ),
  );
}

Future<void> _approveRequest(LabRequestModel request) async {
  await FirebaseFirestore.instance
      .collection("lab_requests")
      .doc(request.id)
      .update({
    "status": "approved",
    "approvedAt": Timestamp.now(),
    "updatedAt": Timestamp.now(),
  });

  if (!mounted) return;

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text("Request approved."),
    ),
  );
}

Future<void> _rejectRequest(LabRequestModel request) async {
  await FirebaseFirestore.instance
      .collection("lab_requests")
      .doc(request.id)
      .update({
    "status": "rejected",
    "updatedAt": Timestamp.now(),
  });

  if (!mounted) return;

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text("Request rejected."),
    ),
  );
}

Future<void> _deleteRequest(LabRequestModel request) async {
  final confirm = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text("Delete Request"),
      content: const Text(
        "Are you sure you want to delete this request?",
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text("Delete"),
        ),
      ],
    ),
  );

  if (confirm != true) return;

  await FirebaseFirestore.instance
      .collection("lab_requests")
      .doc(request.id)
      .delete();

  if (!mounted) return;

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text("Request deleted."),
    ),
  );
}
}
 