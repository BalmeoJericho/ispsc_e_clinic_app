
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/medical_record.dart';
import '../services/activity_log_service.dart';

class FinalConfirmationScreen extends StatefulWidget {
  final MedicalRecord record;

  const FinalConfirmationScreen({
    super.key,
    required this.record,
  });

  @override
  State<FinalConfirmationScreen> createState() =>
      _FinalConfirmationScreenState();
}

class _FinalConfirmationScreenState
    extends State<FinalConfirmationScreen> {

  bool isSaving = false;

////////////////////////////////////////////////////////////
/// SAVE RECORD
////////////////////////////////////////////////////////////

  Future<void> saveRecord() async {

    setState(() => isSaving = true);

    try {

      final firestore = FirebaseFirestore.instance;

////////////////////////////////////////////////////////////
/// CHECK IF PATIENT EXISTS
////////////////////////////////////////////////////////////

      final patientQuery = await firestore
          .collection('patients')
          .where('patientName',
              isEqualTo: widget.record.patientName)
          .limit(1)
          .get();

      String patientId;

      if (patientQuery.docs.isNotEmpty) {

        patientId = patientQuery.docs.first.id;

      } else {

////////////////////////////////////////////////////////////
/// CREATE NEW PATIENT
////////////////////////////////////////////////////////////

        final newPatient =
            await firestore.collection('patients').add({

          'patientName': widget.record.patientName,
          'age': widget.record.age,
          'gender': widget.record.gender,
          'address': widget.record.address,
          'createdAt': Timestamp.now(),

        });

        patientId = newPatient.id;

        /// ACTIVITY LOG — PATIENT REGISTERED
        await ActivityLogService.log(
          action: "Patient Registered",
          details: widget.record.patientName,
          patientName: widget.record.patientName,
          patientId: patientId,
        );
      }

////////////////////////////////////////////////////////////
/// SAVE VISIT RECORD
////////////////////////////////////////////////////////////

      await firestore
          .collection('patients')
          .doc(patientId)
          .collection('visits')
          .add({

        'dateOfVisit': widget.record.dateOfVisit,
        'reasonForVisit': widget.record.reasonForVisit,
        'hematology': widget.record.hematology,
        'clinicalMicroscopy':
            widget.record.clinicalMicroscopy,
        'bloodChemistry':
            widget.record.bloodChemistry,
        'immunology': widget.record.immunology,
        'radiology': widget.record.radiology,
        'others': widget.record.others,
        'createdAt': Timestamp.now(),

      });

////////////////////////////////////////////////////////////
/// ACTIVITY LOG — VISIT RECORDED
////////////////////////////////////////////////////////////

      await ActivityLogService.log(
        action: "Visit Recorded",
        details:
            "Visit added for ${widget.record.patientName}",
        patientName: widget.record.patientName,
        patientId: patientId,
      );

////////////////////////////////////////////////////////////
/// SUCCESS
////////////////////////////////////////////////////////////

      if (!mounted) return;

      Navigator.popUntil(
          context, (route) => route.isFirst);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Visit saved successfully."),
        ),
      );

    } catch (e) {

      setState(() => isSaving = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to save record."),
        ),
      );
    }
  }

////////////////////////////////////////////////////////////
/// INFO ROW
////////////////////////////////////////////////////////////

  Widget infoRow(String label, String value) {

    return Padding(
      padding:
          const EdgeInsets.symmetric(vertical: 4),

      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                  fontWeight: FontWeight.bold),
            ),
          ),

          Expanded(child: Text(value)),
        ],
      ),
    );
  }

////////////////////////////////////////////////////////////
/// LAB SECTION
////////////////////////////////////////////////////////////

  Widget buildSection(
      String title, List<String> items) {

    if (items.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [

        const SizedBox(height: 20),

        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),

        const Divider(),

        ...items.map(
          (e) => Padding(
            padding:
                const EdgeInsets.symmetric(
                    vertical: 3),

            child: Text("• $e"),
          ),
        ),
      ],
    );
  }

////////////////////////////////////////////////////////////
/// UI
////////////////////////////////////////////////////////////

  @override
  Widget build(BuildContext context) {

    final record = widget.record;

    return Scaffold(

      appBar: AppBar(
        title:
            const Text("Confirm Visit Record"),
      ),

      body: SafeArea(

        child: Padding(
          padding:
              const EdgeInsets.all(20),

          child: Column(

            children: [

              const Align(
                alignment:
                    Alignment.centerLeft,

                child: Text(
                  "Step 3 of 3",
                  style: TextStyle(
                    fontWeight:
                        FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              LinearProgressIndicator(
                value: 1,
                backgroundColor:
                    Colors.grey.shade300,
              ),

              const SizedBox(height: 20),

////////////////////////////////////////////////////////////
/// DETAILS CARD
////////////////////////////////////////////////////////////

              Expanded(

                child:
                    SingleChildScrollView(

                  child: Card(

                    elevation: 3,

                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius
                              .circular(12),
                    ),

                    child: Padding(
                      padding:
                          const EdgeInsets
                              .all(20),

                      child: Column(

                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,

                        children: [

                          const Text(
                            "Patient Information",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),

                          const Divider(),

                          infoRow(
                              "Name:",
                              record.patientName),

                          infoRow(
                              "Age:",
                              record.age),

                          infoRow(
                              "Gender:",
                              record.gender),

                          infoRow(
                              "Address:",
                              record.address),

                          const SizedBox(height: 20),

                          const Text(
                            "Visit Details",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),

                          const Divider(),

                          infoRow(
                              "Date:",
                              record.dateOfVisit),

                          const SizedBox(height: 10),

                          const Text(
                            "Reason for Visit",
                            style: TextStyle(
                                fontWeight:
                                    FontWeight.bold),
                          ),

                          const SizedBox(height: 4),

                          Container(
                            width: double.infinity,

                            padding:
                                const EdgeInsets
                                    .all(12),

                            decoration:
                                BoxDecoration(
                              color: Colors
                                  .grey
                                  .shade100,

                              borderRadius:
                                  BorderRadius
                                      .circular(8),
                            ),

                            child: Text(
                              record.reasonForVisit
                                      .isEmpty
                                  ? "No reason provided"
                                  : record.reasonForVisit,
                            ),
                          ),

                          buildSection(
                              "HEMATOLOGY",
                              record.hematology),

                          buildSection(
                              "CLINICAL MICROSCOPY",
                              record.clinicalMicroscopy),

                          buildSection(
                              "BLOOD CHEMISTRY",
                              record.bloodChemistry),

                          buildSection(
                              "IMMUNOLOGY",
                              record.immunology),

                          buildSection(
                              "RADIOLOGY",
                              record.radiology),

                          buildSection(
                              "OTHERS",
                              record.others),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

////////////////////////////////////////////////////////////
/// ACTION BUTTONS
////////////////////////////////////////////////////////////

              const SizedBox(height: 20),

              Row(

                children: [

                  Expanded(
                    child: OutlinedButton(
                      onPressed: () =>
                          Navigator.pop(context),
                      child:
                          const Text("Edit"),
                    ),
                  ),

                  const SizedBox(width: 16),

                  Expanded(
                    child: ElevatedButton(

                      onPressed:
                          isSaving ? null : saveRecord,

                      child: isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child:
                                  CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              "Save Visit"),
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

