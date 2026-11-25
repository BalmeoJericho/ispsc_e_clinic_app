import 'package:flutter/material.dart';
import '../models/medical_record.dart';

class RecordDetailScreen extends StatelessWidget {
  final MedicalRecord record;
  const RecordDetailScreen({super.key, required this.record});

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<String> items) {
    if (items.isEmpty) return const SizedBox();
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
          const SizedBox(height: 6),
          ...items.map((e) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text("• $e"),
              )),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Patient Record Details")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 3,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    record.patientName,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 16),
                _buildDetailRow('Patient ID', record.patientID),
                _buildDetailRow('Age', record.age),
                _buildDetailRow('Gender', record.gender),
                _buildDetailRow('Address', record.address),
                _buildDetailRow('Date', record.dateOfVisit),
                const Divider(height: 30),
                _buildSection("HEMATOLOGY", record.hematology),
                _buildSection("CLINICAL MICROSCOPY & PARASITOLOGY",
                    record.clinicalMicroscopy),
                _buildSection("CLINICAL BLOOD CHEMISTRY", record.bloodChemistry),
                _buildSection("IMMUNOLOGY & SEROLOGY", record.immunology),
                _buildSection("RADIOLOGY", record.radiology),
                _buildSection("OTHERS", record.others),
                if (record.notes.isNotEmpty) ...[
                  const Divider(height: 30),
                  _buildSection("Notes", [record.notes]),
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }
}
