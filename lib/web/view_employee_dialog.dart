import 'package:flutter/material.dart';
import '../models/employee_model.dart';

class ViewEmployeeDialog extends StatelessWidget {
  final EmployeeModel employee;

  const ViewEmployeeDialog({
    super.key,
    required this.employee,
  });

  Widget buildRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        initialValue: value,
        readOnly: true,
        decoration: InputDecoration(
          labelText: title,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        "Employee Information",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              buildRow("Employee ID", employee.employeeId),

              buildRow("First Name", employee.firstName),

              buildRow("Middle Name", employee.middleName),

              buildRow("Last Name", employee.lastName),

              buildRow("Full Name", employee.fullName),

              buildRow("Email", employee.email),

              buildRow("Department", employee.department),

              buildRow("Staff Type", employee.staffType),

              buildRow("Role", employee.role),

              buildRow("Status", employee.status),

              buildRow("UID", employee.uid),

              buildRow(
                "Created At",
                employee.createdAt?.toDate().toString() ?? "-",
              ),

            ],
          ),
        ),
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Close"),
        ),
      ],
    );
  }
}