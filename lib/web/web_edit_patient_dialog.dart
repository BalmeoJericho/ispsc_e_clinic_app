
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'activity_log_service.dart';

class EditPatientDialog extends StatefulWidget {
  final String patientId;
  final Map<String, dynamic> patientData;

  const EditPatientDialog({
    super.key,
    required this.patientId,
    required this.patientData,
  });

  @override
  State<EditPatientDialog> createState() => _EditPatientDialogState();
}

class _EditPatientDialogState extends State<EditPatientDialog> {

  late TextEditingController nameController;
  late TextEditingController ageController;
  late TextEditingController addressController;

  String gender = "Male";
  bool saving = false;

////////////////////////////////////////////////////////////
/// INIT
////////////////////////////////////////////////////////////

  @override
  void initState() {
    super.initState();

    nameController =
        TextEditingController(text: widget.patientData['patientName']);

    ageController =
        TextEditingController(text: widget.patientData['age'].toString());

    addressController =
        TextEditingController(text: widget.patientData['address']);

    gender = widget.patientData['gender'] ?? "Male";
  }

////////////////////////////////////////////////////////////
/// UPDATE PATIENT
////////////////////////////////////////////////////////////

  Future<void> updatePatient() async {

    setState(() => saving = true);

    try {

      final updatedName = nameController.text.trim();

      await FirebaseFirestore.instance
          .collection('patients')
          .doc(widget.patientId)
          .update({

        "patientName": updatedName,
        "age": ageController.text.trim(),
        "gender": gender,
        "address": addressController.text.trim(),
      });

////////////////////////////////////////////////////////////
/// ACTIVITY LOG
////////////////////////////////////////////////////////////

      await WebActivityLogService.log(
        action: "Updated Patient Information",
        details: "Patient record edited",
        patientName: updatedName,
        source: "web",
      );

      if (!mounted) return;

      Navigator.pop(context);

    } catch (e) {

      setState(() => saving = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to update patient."),
        ),
      );
    }
  }

////////////////////////////////////////////////////////////
/// UI
////////////////////////////////////////////////////////////

  @override
  Widget build(BuildContext context) {

    return Dialog(
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(25),

        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            const Text(
              "Edit Patient Record",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

////////////////////////////////////////////////////////////
/// NAME
////////////////////////////////////////////////////////////

            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Full Name",
              ),
            ),

            const SizedBox(height: 15),

////////////////////////////////////////////////////////////
/// AGE
////////////////////////////////////////////////////////////

            TextField(
              controller: ageController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Age",
              ),
            ),

            const SizedBox(height: 15),

////////////////////////////////////////////////////////////
/// GENDER
////////////////////////////////////////////////////////////

            DropdownButtonFormField<String>(
              value: gender,
              decoration: const InputDecoration(
                labelText: "Gender",
              ),
              items: const [

                DropdownMenuItem(
                  value: "Male",
                  child: Text("Male"),
                ),

                DropdownMenuItem(
                  value: "Female",
                  child: Text("Female"),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  gender = value!;
                });
              },
            ),

            const SizedBox(height: 15),

////////////////////////////////////////////////////////////
/// ADDRESS
////////////////////////////////////////////////////////////

            TextField(
              controller: addressController,
              decoration: const InputDecoration(
                labelText: "Address",
              ),
            ),

            const SizedBox(height: 25),

////////////////////////////////////////////////////////////
/// BUTTONS
////////////////////////////////////////////////////////////

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [

                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Cancel"),
                ),

                const SizedBox(width: 10),

                ElevatedButton(
                  onPressed: saving ? null : updatePatient,
                  child: saving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text("Save Changes"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

