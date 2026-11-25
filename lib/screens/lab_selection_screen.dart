import 'package:flutter/material.dart';
import '../models/medical_record.dart';
import 'final_confirmation_screen.dart';

class LabSelectionScreen extends StatefulWidget {
  final MedicalRecord record;

  const LabSelectionScreen({super.key, required this.record});

  @override
  State<LabSelectionScreen> createState() =>
      _LabSelectionScreenState();
}

class _LabSelectionScreenState
    extends State<LabSelectionScreen> {

  final Map<String, List<String>> labCategories = {
    "HEMATOLOGY": [
      "Complete Blood Count",
      "Hemoglobin",
      "Hematocrit",
      "Platelet",
      "ABO and Rh Typing",
      "PT",
      "APTT",
      "Peripheral Blood Smear"
    ],
    "CLINICAL MICROSCOPY & PARASITOLOGY": [
      "Urinalysis",
      "Pregnancy Test",
      "Fecalysis",
      "Fecal Occult Blood",
      "Drug Testing"
    ],
    "CLINICAL BLOOD CHEMISTRY": [
      "Fasting Blood Sugar",
      "HbA1C",
      "Total Cholesterol",
      "Triglycerides",
      "HDL",
      "LDL",
      "Blood Urea Nitrogen",
      "Creatinine",
      "Blood Uric Acid",
      "SGPT",
      "SGOT",
      "Amylase",
      "Lipase",
      "Sodium",
      "Potassium",
      "Chloride",
      "Ionized Calcium"
    ],
    "IMMUNOLOGY & SEROLOGY": [
      "HBsAg",
      "Typhi Dot",
      "Dengue IgG/IgM"
    ],
    "RADIOLOGY": [
      "Chest X-ray",
      "Abdominal UTZ",
      "Digital Rectal Exam",
      "Breast & Pelvic UTZ"
    ],
    "OTHERS": [
      "12LECG",
      "Pap Smear",
      "Prostate Specific Antigen"
    ]
  };

  final Map<String, Set<String>> selectedTests = {};

  @override
  void initState() {
    super.initState();

    // Initialize empty selections
    for (var key in labCategories.keys) {
      selectedTests[key] = {};
    }
  }

  void proceedToNext() {

    final updatedRecord = widget.record;

    // Save selected tests to record
    updatedRecord.hematology =
        selectedTests["HEMATOLOGY"]!.toList();

    updatedRecord.clinicalMicroscopy =
        selectedTests["CLINICAL MICROSCOPY & PARASITOLOGY"]!
            .toList();

    updatedRecord.bloodChemistry =
        selectedTests["CLINICAL BLOOD CHEMISTRY"]!
            .toList();

    updatedRecord.immunology =
        selectedTests["IMMUNOLOGY & SEROLOGY"]!
            .toList();

    updatedRecord.radiology =
        selectedTests["RADIOLOGY"]!.toList();

    updatedRecord.others =
        selectedTests["OTHERS"]!.toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            FinalConfirmationScreen(record: updatedRecord),
      ),
    );
  }

  Widget buildCategory(String category, List<String> tests) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        title: Text(
          category,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        children: tests.map((test) {
          return CheckboxListTile(
            title: Text(test),
            value: selectedTests[category]!.contains(test),
            onChanged: (value) {
              setState(() {
                if (value == true) {
                  selectedTests[category]!.add(test);
                } else {
                  selectedTests[category]!.remove(test);
                }
              });
            },
          );
        }).toList(),
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

              const Text(
                "Step 2 of 3",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),

              const SizedBox(height: 8),

              LinearProgressIndicator(
                value: 0.66,
                backgroundColor: Colors.grey.shade300,
              ),

              const SizedBox(height: 24),

              const Text(
                "Select Laboratory Tests",
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 16),

              Expanded(
                child: ListView(
                  children: labCategories.entries.map((entry) {
                    return buildCategory(
                        entry.key, entry.value);
                  }).toList(),
                ),
              ),

              Row(
                children: [

                  Expanded(
                    child: OutlinedButton(
                      onPressed: () =>
                          Navigator.pop(context),
                      child: const Text("Back"),
                    ),
                  ),

                  const SizedBox(width: 16),

                  Expanded(
                    child: ElevatedButton(
                      onPressed: proceedToNext,
                      child: const Text(
                          "Confirm & Continue"),
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