import 'dart:math';

import 'package:flutter/material.dart';

import '../models/employee_model.dart';
import '../services/employee_service.dart';

class AddEmployeeDialog extends StatefulWidget {
  final EmployeeModel? employee;

  const AddEmployeeDialog({
    super.key,
    this.employee,
  });

  bool get isEdit => employee != null;

  @override
  State<AddEmployeeDialog> createState() =>
      _AddEmployeeDialogState();
}

class _AddEmployeeDialogState extends State<AddEmployeeDialog> {
  final _formKey = GlobalKey<FormState>();

  final EmployeeService _employeeService = EmployeeService();

  final firstNameController = TextEditingController();
  final middleNameController = TextEditingController();
  final lastNameController = TextEditingController();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool _isSaving = false;
  bool _obscurePassword = true;

  String role = "employee";
  String status = "active";

  String staffType = "Teaching";

  String department = "CAS";

  @override
  void initState() {
    super.initState();

    if (widget.employee != null) {
      firstNameController.text = widget.employee!.firstName;
      middleNameController.text = widget.employee!.middleName;
      lastNameController.text = widget.employee!.lastName;
      emailController.text = widget.employee!.email;

      staffType = widget.employee!.staffType;
      department = widget.employee!.department;
      status = widget.employee!.status;
    }
  }

  final List<String> teachingDepartments = [
    "CAS",
    "CBME",
    "CTE",
  ];

  final List<String> nonTeachingDepartments = [
    "Registrar",
    "Library",
    "Security",
    "Canteen",
    "Accounting",
    "Cashier",
    "HR Office",
    "MIS Office",
    "Guidance Office",
  ];

  @override
  void dispose() {
    firstNameController.dispose();
    middleNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  //==========================
  // AUTO GENERATE EMPLOYEE ID
  //==========================

  String generateEmployeeId() {
    const letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";

    final random = Random();

    String randomLetters = "";

    for (int i = 0; i < 3; i++) {
      randomLetters += letters[random.nextInt(letters.length)];
    }

    final randomNumbers =
        (100 + random.nextInt(900)).toString();

    return "EMP-$randomLetters$randomNumbers";
  }

  //==========================
  // PASSWORD VALIDATION
  //==========================

  String? validatePassword(String value) {
    if (value.isEmpty) {
      return "Password is required";
    }

    if (value.length < 8) {
      return "Minimum of 8 characters";
    }

    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return "Must contain an uppercase letter";
    }

    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return "Must contain a lowercase letter";
    }

    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return "Must contain a number";
    }

    return null;
  }

  Widget buildTextField({
  required String label,
  required TextEditingController controller,
  bool isPassword = false,
  bool requiredField = true,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 15),
    child: TextFormField(
      controller: controller,
      obscureText: isPassword ? _obscurePassword : false,

      style: const TextStyle(
        letterSpacing: 0,
      ),

      validator: (value) {
        if (requiredField && (value == null || value.trim().isEmpty)) {
          return "$label is required";
        }

        if (!requiredField &&
            (value == null || value.trim().isEmpty)) {
          return null;
        }

        if (label == "Email") {
          if (!RegExp(
            r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$',
          ).hasMatch(value!)) {
            return "Enter a valid email";
          }
        }

        if (label == "Password") {
          return validatePassword(value!);
        }

        return null;
      },

      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),

        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility
                      : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              )
            : null,
      ),
    ),
  );
}
    @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.isEdit ? "Edit Employee" : "Add Employee",
        style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
         ),
        ),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "Employee ID will be generated automatically.",
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                buildTextField(
                  label: "First Name",
                  controller: firstNameController,
                ),

                buildTextField(
                  label: "Middle Name",
                  controller: middleNameController,
                  requiredField: false,
                ),

                buildTextField(
                  label: "Last Name",
                  controller: lastNameController,
                ),

                buildTextField(
                  label: "Email",
                  controller: emailController,
                ),

                if (!widget.isEdit)
                buildTextField(
                  label: "Password",
                  controller: passwordController,
                  isPassword: true,
                ),

                const SizedBox(height: 10),

                DropdownButtonFormField<String>(
                  value: staffType,
                  decoration: const InputDecoration(
                    labelText: "Staff Type",
                    border: OutlineInputBorder(),
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

                    setState(() {

                      staffType = value!;

                      if (staffType == "Teaching") {
                        department = teachingDepartments.first;
                      } else {
                        department = nonTeachingDepartments.first;
                      }

                    });

                  },
                ),

                const SizedBox(height: 15),

                DropdownButtonFormField<String>(
                  value: department,
                  decoration: const InputDecoration(
                    labelText: "Department",
                    border: OutlineInputBorder(),
                  ),
                  items: (staffType == "Teaching"
                          ? teachingDepartments
                          : nonTeachingDepartments)
                      .map(
                        (dept) => DropdownMenuItem(
                          value: dept,
                          child: Text(dept),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {

                    setState(() {

                      department = value!;

                    });

                  },
                ),

                const SizedBox(height: 15),

                DropdownButtonFormField<String>(
                  value: status,
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

                    setState(() {

                      status = value!;

                    });

                  },
                ),
              ],
            ),
          ),
        ),
      ),

      actions: [

        TextButton(
          onPressed: _isSaving
              ? null
              : () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),

        ElevatedButton(
          onPressed: _isSaving ? null : _saveEmployee,
          child: _isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              :  Text(widget.isEdit
                    ? "Update Employee"
                    : "Save Employee",),
        ),

      ],
    );
  }
    Future<void> _saveEmployee() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final employeeId = widget.isEdit
            ? widget.employee!.employeeId
            : generateEmployeeId();

      final employee = EmployeeModel(
        uid: widget.isEdit
            ? widget.employee!.uid
            : "",
        employeeId: employeeId,
        firstName: firstNameController.text.trim(),
        middleName: middleNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        fullName: [
          firstNameController.text.trim(),
          middleNameController.text.trim(),
          lastNameController.text.trim(),
        ].where((e) => e.isNotEmpty).join(" "),
        staffType: staffType,
        department: department,
        email: emailController.text.trim(),
        role: "employee",
        status: status,
        photoUrl: "",
      );

      if (widget.isEdit) {
            await _employeeService.updateEmployee(employee);
            } else {
            await _employeeService.createEmployeeAccount(
                employee: employee,
                password: passwordController.text.trim(),
            );
        }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.isEdit
                  ? "Employee updated successfully."
                  : "Employee account created successfully.",
            ),
            backgroundColor: Colors.green,
          ),
        );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst("Exception: ", ""),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }

    if (mounted) {
      setState(() {
        _isSaving = false;
      });
    }
  }
}