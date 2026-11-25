import 'package:flutter/material.dart';
import '../models/employee_model.dart';
import '../services/employee_service.dart';
import 'add_employee_dialog.dart';
import 'view_employee_dialog.dart';

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
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FA),

      body: Padding(
        padding: const EdgeInsets.all(24),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            /// TITLE
            const Text(
              "Employee Management",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              "Manage employee accounts.",
              style: TextStyle(
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 30),

            /// SEARCH + BUTTON
            Row(
              children: [

                Expanded(
                  child: TextField(
                    controller: _searchController,

                    decoration: InputDecoration(
                      hintText: "Search employee...",

                      prefixIcon: const Icon(Icons.search),

                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(12),
                      ),
                    ),

                    onChanged: (value) {
                      setState(() {
                        _search = value;
                      });
                    },
                  ),
                ),

                const SizedBox(width: 20),

                ElevatedButton.icon(
                  onPressed: () async {
                    await showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) => const AddEmployeeDialog(),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text("Add Employee"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 18,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 25),

            /// TABLE CARD
            Expanded(
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: StreamBuilder<List<EmployeeModel>>(
                  stream: _employeeService.getEmployees(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text(snapshot.error.toString()),
                      );
                    }

                    final employees = snapshot.data ?? [];

                      final query = _search.trim().toLowerCase();

                      final filteredEmployees = employees.where((employee) {
                        return employee.fullName.toLowerCase().contains(query) ||
                            employee.email.toLowerCase().contains(query) ||
                            employee.department.toLowerCase().contains(query) ||
                            employee.staffType.toLowerCase().contains(query) ||
                            employee.employeeId.toLowerCase().contains(query) ||
                            employee.status.toLowerCase().contains(query);
                      }).toList();

                      

                      return LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: SizedBox(
                            width: constraints.maxWidth,
                            child: DataTable(
                        headingRowHeight: 60,
                        dataRowMinHeight: 65,
                        dataRowMaxHeight: 65,
                        columnSpacing: 40,
                        columns: const [
                          DataColumn(label: Text("Employee")),
                          DataColumn(label: Text("Email")),
                          DataColumn(label: Text("Department")),
                          DataColumn(label: Text("Staff Type")),
                          DataColumn(label: Text("Status")),
                          DataColumn(label: Text("Actions")),
                        ],
                        rows: filteredEmployees.isEmpty
                            ? [
                                const DataRow(
                                  cells: [
                                    DataCell(Text("")),
                                    DataCell(Text("")),
                                    DataCell(Text("")),
                                    DataCell(Text("")),
                                    DataCell(Text("")),
                                    DataCell(Text("")),
                                  ],
                                ),
                              ]
                            : filteredEmployees.map((employee) {
                          return DataRow(
                            cells: [
                              DataCell(Text(employee.fullName)),
                              DataCell(Text(employee.email)),
                              DataCell(Text(employee.department)),
                              DataCell(Text(employee.staffType)),
                              DataCell(
                                Chip(
                                  label: Text(employee.status),
                                ),
                              ),
                              DataCell(
                                PopupMenuButton<String>(
                                  onSelected: (value) async {
                                      switch (value) {
                                        case "view":
                                          await showDialog(
                                            context: context,
                                            builder: (_) => ViewEmployeeDialog(
                                              employee: employee,
                                            ),
                                          );
                                          break;

                                        case "edit":
                                          await showDialog(
                                            context: context,
                                            barrierDismissible: false,
                                            builder: (_) => AddEmployeeDialog(
                                              employee: employee,
                                            ),
                                          );
                                          break;

                                        case "deactivate":
                                          await EmployeeService().updateStatus(
                                            employee,
                                            "inactive",
                                          );
                                          break;

                                        case "activate":
                                          await EmployeeService().updateStatus(
                                            employee,
                                            "active",
                                          );
                                          break;

                                        case "delete":
                                        final confirm = await showDialog<bool>(
                                          context: context,
                                          builder: (_) => AlertDialog(
                                            title: const Text("Delete Employee"),
                                            content: Text(
                                              "Are you sure you want to delete ${employee.fullName}?",
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

                                       
                                        if (confirm == true) {
                                        try {
                                          await EmployeeService().deleteEmployee(employee);

                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  "${employee.fullName} has been deleted successfully.",
                                                ),
                                                backgroundColor: Colors.green,
                                                behavior: SnackBarBehavior.floating,
                                              ),
                                            );
                                          }
                                        } catch (e) {
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text("Failed to delete employee.\n$e"),
                                                backgroundColor: Colors.red,
                                                behavior: SnackBarBehavior.floating,
                                              ),
                                            );
                                          }
                                        }
                                      }

                                        break;
                                      }
                                    },
                                  itemBuilder: (context) => [
                                    const PopupMenuItem<String>(
                                      value: "view",
                                      child: Text("View"),
                                    ),

                                    const PopupMenuItem<String>(
                                      value: "edit",
                                      child: Text("Edit"),
                                    ),

                                    PopupMenuItem<String>(
                                      value: employee.status == "active"
                                          ? "deactivate"
                                          : "activate",
                                      child: Text(
                                        employee.status == "active"
                                            ? "Deactivate"
                                            : "Activate",
                                      ),
                                    ),

                                    const PopupMenuItem<String>(
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
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}