import 'package:flutter/material.dart';
import '../models/medical_record.dart';
import 'lab_selection_screen.dart';

class ReviewBasicInfoScreen extends StatefulWidget {
  final MedicalRecord record;

  const ReviewBasicInfoScreen({super.key, required this.record});

  @override
  State<ReviewBasicInfoScreen> createState() =>
      _ReviewBasicInfoScreenState();
}

class _ReviewBasicInfoScreenState
    extends State<ReviewBasicInfoScreen> {
  late TextEditingController nameController;
  late TextEditingController addressController;
  late TextEditingController ageController;
  late TextEditingController dateController;
  late TextEditingController reasonController;

  String gender = "Male";

  @override
  void initState() {
    super.initState();

    nameController =
        TextEditingController(text: widget.record.patientName);
    addressController =
        TextEditingController(text: widget.record.address);
    ageController =
        TextEditingController(text: widget.record.age);
    dateController =
        TextEditingController(text: widget.record.dateOfVisit);

    reasonController =
        TextEditingController(text: widget.record.reasonForVisit);

    gender = widget.record.gender.isNotEmpty
        ? widget.record.gender
        : "Male";
  }

  @override
  void dispose() {
    nameController.dispose();
    addressController.dispose();
    ageController.dispose();
    dateController.dispose();
    reasonController.dispose();
    super.dispose();
  }

  Future<void> pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      dateController.text =
          "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
    }
  }

  void proceedToNext() {
    final updatedRecord = MedicalRecord(
      patientName: nameController.text.trim(),
      address: addressController.text.trim(),
      dateOfVisit: dateController.text.trim(),
      age: ageController.text.trim(),
      gender: gender,
      reasonForVisit: reasonController.text.trim(),
      patientID: '',
      hematology: [],
      clinicalMicroscopy: [],
      bloodChemistry: [],
      immunology: [],
      radiology: [],
      others: [],
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            LabSelectionScreen(record: updatedRecord),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔵 Progress Indicator
              const Text(
                "Step 1 of 3",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: 0.33,
                backgroundColor: Colors.grey.shade300,
              ),
              const SizedBox(height: 24),

              const Text(
                "Patient Information",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              Expanded(
                child: ListView(
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: "Full Name",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextField(
                      controller: addressController,
                      decoration: const InputDecoration(
                        labelText: "Address",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextField(
                      controller: ageController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Age",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    DropdownButtonFormField<String>(
                      value: gender,
                      decoration: const InputDecoration(
                        labelText: "Gender",
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                            value: "Male", child: Text("Male")),
                        DropdownMenuItem(
                            value: "Female",
                            child: Text("Female")),
                      ],
                      onChanged: (value) {
                        setState(() {
                          gender = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    TextField(
                      controller: dateController,
                      readOnly: true,
                      onTap: pickDate,
                      decoration: const InputDecoration(
                        labelText: "Date of Visit",
                        border: OutlineInputBorder(),
                        suffixIcon:
                            Icon(Icons.calendar_today),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // 🟢 NEW FIELD - Reason for Visit
                    TextField(
                      controller: reasonController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: "Reason for Visit",
                        
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Back"),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: proceedToNext,
                      child:
                          const Text("Confirm & Continue"),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}