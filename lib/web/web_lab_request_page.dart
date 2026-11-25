import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/lab_request_model.dart';
import '../services/lab_request_service.dart';

class WebLabRequestPage extends StatefulWidget {
  const WebLabRequestPage({super.key});

  @override
  State<WebLabRequestPage> createState() => _WebLabRequestPageState();
}

class _WebLabRequestPageState extends State<WebLabRequestPage> {
  final LabRequestService _service = LabRequestService();

  final TextEditingController _searchController =
      TextEditingController();

  String _statusFilter = "All";

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<LabRequestModel> _filterRequests(
    List<LabRequestModel> requests,
  ) {
    final search =
        _searchController.text.trim().toLowerCase();

    return requests.where((request) {
      final matchesSearch =
          request.employeeName
                  .toLowerCase()
                  .contains(search) ||
              request.employeeId
                  .toLowerCase()
                  .contains(search);

      final matchesStatus =
          _statusFilter == "All" ||
              request.status == _statusFilter;

      return matchesSearch && matchesStatus;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FA),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
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
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (_) {
                      setState(() {});
                    },
                    decoration: InputDecoration(
                      hintText:
                          "Search employee...",
                      prefixIcon:
                          const Icon(Icons.search),
                      border:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                DropdownButton<String>(
                  value: _statusFilter,
                  items: const [
                    DropdownMenuItem(
                      value: "All",
                      child: Text("All"),
                    ),
                    DropdownMenuItem(
                      value: "Pending",
                      child: Text("Pending"),
                    ),
                    DropdownMenuItem(
                      value: "Approved",
                      child: Text("Approved"),
                    ),
                    DropdownMenuItem(
                      value: "Rejected",
                      child: Text("Rejected"),
                    ),
                  ],
                  onChanged: (value) {
                    if (value == null) return;

                    setState(() {
                      _statusFilter = value;
                    });
                  },
                ),
              ],
            ),

            const SizedBox(height: 20),

            Expanded(
              child: StreamBuilder<List<LabRequestModel>>(
                stream: _service.getRequests(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                      child:
                          CircularProgressIndicator(),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        snapshot.error.toString(),
                      ),
                    );
                  }

                  final requests = _filterRequests(
                    snapshot.data ?? [],
                  );

                  

                  // PART 2
return SizedBox(
  width: double.infinity,
  child: Card(
    clipBehavior: Clip.antiAlias,
    color: Colors.white,
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    child: LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: constraints.maxWidth,
            ),
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(
                Colors.white,
              ),
              columnSpacing: 40,
              horizontalMargin: 24,
              columns: const [
                DataColumn(label: Text("Employee")),
                DataColumn(label: Text("Department")),
                DataColumn(label: Text("Staff")),
                DataColumn(label: Text("Tests")),
                DataColumn(label: Text("Method")),
                DataColumn(label: Text("Status")),
                DataColumn(label: Text("Action")),
              ],
              rows: requests.isEmpty
                  ? []
                  : requests.map((request) {
                      return DataRow(
                        cells: [
                          DataCell(Text(request.employeeName)),
                          DataCell(Text(request.department)),
                          DataCell(Text(request.staffType)),
                          DataCell(
                            Text(request.selectedTests.join(", ")),
                          ),
                          DataCell(Text(request.requestMethod)),
                          DataCell(
                            Text(
                              request.status,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: request.status == "Approved"
                                    ? Colors.green
                                    : request.status == "Rejected"
                                        ? Colors.red
                                        : Colors.orange,
                              ),
                            ),
                          ),
                          DataCell(
                            IconButton(
                              icon: const Icon(Icons.visibility),
                              onPressed: () =>
                                  _showRequestDetails(request),
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
);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color backgroundColor;
    Color textColor;

    switch (status.toLowerCase()) {
      case "approved":
        backgroundColor = Colors.green.shade100;
        textColor = Colors.green.shade800;
        break;

      case "rejected":
        backgroundColor = Colors.red.shade100;
        textColor = Colors.red.shade800;
        break;

      default:
        backgroundColor = Colors.orange.shade100;
        textColor = Colors.orange.shade800;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
  void _showRequestDetails(LabRequestModel request) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text(
          "Laboratory Request Details",
        ),

        content: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [

                const Text(
                  "Employee Information",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),

                const Divider(),

                Text(
                  "Employee ID: ${request.employeeId}",
                ),

                Text(
                  "Employee Name: ${request.employeeName}",
                ),

                Text(
                  "Department: ${request.department}",
                ),

                Text(
                  "Staff Type: ${request.staffType}",
                ),

                const SizedBox(height: 20),

                const Text(
                  "Request Information",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),

                const Divider(),

                Text(
                  "Purpose: ${request.purpose}",
                ),

                Text(
                  "Request Type: ${request.requestType}",
                ),

                Text(
                  "Method: ${request.requestMethod}",
                ),

                const SizedBox(height: 8),

                  Text(
                    "Submitted On:",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Builder(
                    builder: (_) {
                      final createdAt = request.createdAt;

                      return Text(
                        createdAt == null
                            ? "-"
                            : DateFormat(
                                "MMMM dd, yyyy • hh:mm a",
                              ).format(
                                createdAt.toDate(),
                              ),
                      );
                    },
                  ),

                  const SizedBox(height: 8),

                  Row(
                    children: [
                      const Text(
                        "Status: ",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        request.status,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: request.status == "Approved"
                              ? Colors.green
                              : request.status == "Rejected"
                                  ? Colors.red
                                  : Colors.orange,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  if (request.status == "Approved") ...[
                    const Text(
                      "Approval Information",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),

                    const Divider(),

                    Text(
                      "Approved By: ${request.approvedBy ?? "-"}",
                    ),

                    Builder(
                      builder: (_) {
                        final approvedAt = request.approvedAt;

                        return Text(
                          approvedAt == null
                              ? "Approved On: -"
                              : "Approved On: ${DateFormat(
                                  "MMMM dd, yyyy • hh:mm a",
                                ).format(
                                  approvedAt.toDate(),
                                )}",
                        );
                      },
                    ),
                  ],

                  if (request.status == "Rejected") ...[
                    const Text(
                      "Rejection Information",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),

                    const Divider(),

                    Text(
                      "Rejected By: ${request.rejectedBy ?? "-"}",
                    ),

                    Builder(
                      builder: (_) {
                        final rejectedAt = request.rejectedAt;

                        return Text(
                          rejectedAt == null
                              ? "Rejected On: -"
                              : "Rejected On: ${DateFormat(
                                  "MMMM dd, yyyy • hh:mm a",
                                ).format(
                                  rejectedAt.toDate(),
                                )}",
                        );
                      },
                    ),

                    const SizedBox(height: 6),

                    Text(
                      "Reason: ${request.rejectionReason ?? "-"}",
                    ),
                  ],

                  const SizedBox(height: 20),

                  const Text(
                    "Requested Tests",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),

                const Divider(),

                ...request.selectedTests.map(
                  (test) => ListTile(
                    dense: true,
                    leading: const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                    ),
                    title: Text(test),
                  ),
                ),
              ],
            ),
          ),
        ),

        actions: [

          if (request.status == "Pending")
            TextButton.icon(
              icon: const Icon(
                Icons.close,
                color: Colors.red,
              ),
              label: const Text(
                "Reject",
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () async {
                final reasonController = TextEditingController();

                final reject = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text("Reject Request"),
                    content: TextField(
                      controller: reasonController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: "Reason",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () =>
                            Navigator.pop(context, false),
                        child: const Text("Cancel"),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () =>
                            Navigator.pop(context, true),
                        child: const Text("Reject"),
                      ),
                    ],
                  ),
                );

                if (reject != true) return;

                await _service.rejectRequest(
                  id: request.id,
                  rejectedBy: "Nurse",
                  rejectionReason: reasonController.text.trim(),
                );

                if (context.mounted) {
                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Request rejected."),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),

          if (request.status == "Pending")
            ElevatedButton.icon(
              icon: const Icon(Icons.check),
              label: const Text("Approve"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                final approve = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text("Approve Request"),
                    content: Text(
                      "Approve ${request.employeeName}'s laboratory request?",
                    ),
                    actions: [
                      TextButton(
                        onPressed: () =>
                            Navigator.pop(context, false),
                        child: const Text("Cancel"),
                      ),
                      ElevatedButton(
                        onPressed: () =>
                            Navigator.pop(context, true),
                        child: const Text("Approve"),
                      ),
                    ],
                  ),
                );

                if (approve != true) return;

                await _service.approveRequest(
                  id: request.id,
                  approvedBy: "Nurse",
                );

                if (context.mounted) {
                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Request approved successfully.",
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
            ),

          if (request.status != "Pending")
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close"),
            ),
        ],
      );
    },
  );
}
}
