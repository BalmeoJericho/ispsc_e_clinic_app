import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/employee_service.dart';
import '../models/employee_model.dart';
import 'add_employee_dialog.dart';

class WebEmployeePage extends StatefulWidget {
  const WebEmployeePage({super.key});

  @override
  State<WebEmployeePage> createState() => _WebEmployeePageState();
}

class _WebEmployeePageState extends State<WebEmployeePage> {
  final EmployeeService _employeeService = EmployeeService();

final TextEditingController _searchController =
    TextEditingController();

String _search = "";

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          const Text(
            "Employee Management",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 6),

          const Text(
            "Manage employee records.",
            style: TextStyle(
              color: Colors.grey,
            ),
          ),

          const SizedBox(height: 24),

          Row(
            children: [

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
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    enabledBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(
                      vertical: 18,
                    ),
                  ),
                ),
              ),

              const Spacer(),

              ElevatedButton.icon(
                onPressed: () {
                  _showAddEmployeeDialog();
                },
                icon: const Icon(Icons.add),
                label: const Text("Add Employee"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 18,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection("users")
                  .where("role", isEqualTo: "employee")
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
                    child: Text("No employees found."),
                  );
                }

                final docs = snapshot.data!.docs;

                final employees = docs.where((doc) {

                  final data =
                      doc.data() as Map<String, dynamic>;

                  final name = (data["fullName"] ?? "")
                      .toString()
                      .toLowerCase();

                  return name.contains(_search);

                }).toList();
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
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        DataColumn(
                          label: SizedBox(
                            width: 180,
                            child: Text(
                              "Department",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        DataColumn(
                          label: SizedBox(
                            width: 170,
                            child: Text(
                              "Staff Type",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        DataColumn(
                          label: SizedBox(
                            width: 120,
                            child: Text(
                              "Status",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        DataColumn(
                          label: SizedBox(
                            width: 80,
                            child: Center(
                              child: Text(
                                "Actions",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],

                      rows: employees.map((doc) {

                        final employee =
                            doc.data() as Map<String, dynamic>;

                        return DataRow(
                          cells: [

                            DataCell(
                              SizedBox(
                                width: 220,
                                child: Text(
                                  employee["fullName"] ?? "",
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
                                  employee["department"] ?? "",
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),

                            DataCell(
                              SizedBox(
                                width: 170,
                                child: Text(
                                  employee["staffType"] ?? "",
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),

                            DataCell(
                              SizedBox(
                                width: 120,
                                child: _buildStatusChip(
                                  employee["status"] ?? "active",
                                ),
                              ),
                            ),

                            DataCell(
                              PopupMenuButton<String>(
                                onSelected: (value) {

                                  switch (value) {

                                    case "view":
                                      _viewEmployee(employee);
                                      break;

                                    case "edit":
                                      _editEmployee(doc.id, employee);
                                      break;

                                    case "delete":
                                      _deleteEmployee(doc.id);
                                      break;
                                  }
                                },

                                itemBuilder: (_) => const [

                                  PopupMenuItem(
                                    value: "view",
                                    child: Text("View"),
                                  ),

                                  PopupMenuItem(
                                    value: "edit",
                                    child: Text("Edit"),
                                  ),

                                  PopupMenuDivider(),

                                  PopupMenuItem(
                                    value: "delete",
                                    child: Text("Delete"),
                                  ),
                                ],
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
    case "active":
      color = Colors.green;
      break;
    case "inactive":
      color = Colors.red;
      break;
    case "pending":
      color = Colors.orange;
      break;
    default:
      color = Colors.grey;
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
      status.toUpperCase(),
      textAlign: TextAlign.center,
      style: TextStyle(
        color: color,
        fontWeight: FontWeight.bold,
        fontSize: 12,
      ),
    ),
  );
}

void _viewEmployee(Map<String, dynamic> employee) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text("Employee Information"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Text("Name: ${employee["fullName"] ?? ""}"),

          const SizedBox(height: 8),

          Text("Email: ${employee["email"] ?? ""}"),

          const SizedBox(height: 8),

          Text("Department: ${employee["department"] ?? ""}"),

          const SizedBox(height: 8),

          Text("Staff Type: ${employee["staffType"] ?? ""}"),

          const SizedBox(height: 8),

          Text("Status: ${employee["status"] ?? ""}"),
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

Future<void> _editEmployee(
  String id,
  Map<String, dynamic> employee,
) async {
  final firstNameController =
      TextEditingController(text: employee['firstName'] ?? '');

  final lastNameController =
      TextEditingController(text: employee['lastName'] ?? '');

  final departmentController =
      TextEditingController(text: employee['department'] ?? '');

  String selectedStatus = employee['status'] ?? 'active';

  await showDialog(
    context: context,
    builder: (_) => StatefulBuilder(
      builder: (context, setDialogState) {
        return AlertDialog(
          title: const Text("Edit Employee"),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: firstNameController,
                  decoration: const InputDecoration(
                    labelText: "First Name",
                  ),
                ),
                const SizedBox(height: 12),

                TextField(
                  controller: lastNameController,
                  decoration: const InputDecoration(
                    labelText: "Last Name",
                  ),
                ),
                const SizedBox(height: 12),

                TextField(
                  controller: departmentController,
                  decoration: const InputDecoration(
                    labelText: "Department",
                  ),
                ),
                const SizedBox(height: 12),

                DropdownButtonFormField<String>(
                  value: selectedStatus,
                  decoration: const InputDecoration(
                    labelText: "Status",
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: "active",
                      child: Text("Active"),
                    ),
                    DropdownMenuItem(
                      value: "inactive",
                      child: Text("Inactive"),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() {
                        selectedStatus = value;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                    try {
                        await FirebaseFirestore.instance
                            .collection("employees")
                            .doc(id)
                            .update({
                        "firstName": firstNameController.text.trim(),
                        "lastName": lastNameController.text.trim(),
                        "department": departmentController.text.trim(),
                        "status": selectedStatus,
                        "updatedAt": FieldValue.serverTimestamp(),
                        });

                        if (mounted) {
                        Navigator.pop(context);
                        }
                    } catch (e) {
                        print(e);

                        ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(e.toString()),
                        ),
                        );
                    }
                    },
                child: const Text("Save"),
            ),
          ],
        );
      },
    ),
  );
}

Future<void> _deleteEmployee(String id) async {

  final confirm = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text("Delete Employee"),
      content: const Text(
        "Are you sure you want to delete this employee?",
      ),
      actions: [

        TextButton(
          onPressed: () {
            Navigator.pop(context, false);
          },
          child: const Text("Cancel"),
        ),

        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
          ),
          onPressed: () {
            Navigator.pop(context, true);
          },
          child: const Text("Delete"),
        ),
      ],
    ),
  );

  if (confirm != true) return;

  await _firestore
      .collection("users")
      .doc(id)
      .delete();

  if (!mounted) return;

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text("Employee deleted."),
    ),
  );
}
Future<void> _showAddEmployeeDialog() async {
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final departmentController = TextEditingController();

  String staffType = "Teaching";
  String status = "active";

  await showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text("Add Employee"),
            content: SizedBox(
              width: 420,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    TextField(
                      controller: fullNameController,
                      decoration: const InputDecoration(
                        labelText: "Full Name",
                      ),
                    ),

                    const SizedBox(height: 16),

                    TextField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        labelText: "Email",
                      ),
                    ),

                    const SizedBox(height: 16),

                    TextField(
                      controller: departmentController,
                      decoration: const InputDecoration(
                        labelText: "Department",
                      ),
                    ),

                    const SizedBox(height: 16),

                    DropdownButtonFormField<String>(
                      value: staffType,
                      decoration: const InputDecoration(
                        labelText: "Staff Type",
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: "Teaching",
                          child: Text("Teaching"),
                        ),
                        DropdownMenuItem(
                          value: "Non-Teaching",
                          child: Text("Non-Teaching"),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() {
                            staffType = value;
                          });
                        }
                      },
                    ),

                    const SizedBox(height: 16),

                    DropdownButtonFormField<String>(
                      value: status,
                      decoration: const InputDecoration(
                        labelText: "Status",
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: "active",
                          child: Text("Active"),
                        ),
                        DropdownMenuItem(
                          value: "inactive",
                          child: Text("Inactive"),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() {
                            status = value;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            actions: [

              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {

                  if (fullNameController.text.trim().isEmpty ||
                      emailController.text.trim().isEmpty) {
                    return;
                  }

                  await _firestore.collection("users").add({

                    "fullName": fullNameController.text.trim(),

                    "email": emailController.text.trim(),

                    "department": departmentController.text.trim(),

                    "staffType": staffType,

                    "role": "employee",

                    "status": status,

                    "createdAt": FieldValue.serverTimestamp(),

                  });

                  if (mounted) {
                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Employee added successfully.",
                        ),
                      ),
                    );
                  }
                },
                child: const Text("Save"),
              ),
            ],
          );
        },
      );
    },
  );
}
}