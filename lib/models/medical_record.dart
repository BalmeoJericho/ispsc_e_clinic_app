import 'package:cloud_firestore/cloud_firestore.dart';

class MedicalRecord {
  String patientName;
  String patientID;
  String age;
  String gender;
  String dateOfVisit;
  String address;

  // 🟢 NEW FIELD
  String reasonForVisit;

  List<String> hematology;
  List<String> clinicalMicroscopy;
  List<String> bloodChemistry;
  List<String> immunology;
  List<String> radiology;
  List<String> others;

  String notes;

  DateTime? createdAt; // 🔥 IMPORTANT FOR ORDERING

  MedicalRecord({
    required this.patientName,
    required this.patientID,
    required this.age,
    required this.gender,
    required this.dateOfVisit,
    this.address = '',
    this.reasonForVisit = '', // 🟢 DEFAULT EMPTY
    this.hematology = const [],
    this.clinicalMicroscopy = const [],
    this.bloodChemistry = const [],
    this.immunology = const [],
    this.radiology = const [],
    this.others = const [],
    this.notes = '',
    this.createdAt,
  });

  // Convert to Firebase format
  Map<String, dynamic> toMap() {
    return {
      'patientName': patientName,
      'patientID': patientID,
      'age': age,
      'gender': gender,
      'dateOfVisit': dateOfVisit,
      'address': address,
      'reasonForVisit': reasonForVisit, // 🟢 NEW FIELD
      'hematology': hematology,
      'clinicalMicroscopy': clinicalMicroscopy,
      'bloodChemistry': bloodChemistry,
      'immunology': immunology,
      'radiology': radiology,
      'others': others,
      'notes': notes,
      'createdAt': FieldValue.serverTimestamp(), // 🔥 AUTO SERVER TIME
    };
  }

  // Convert from Firebase
  factory MedicalRecord.fromMap(Map<String, dynamic> map) {
    return MedicalRecord(
      patientName: map['patientName'] ?? '',
      patientID: map['patientID'] ?? '',
      age: map['age'] ?? '',
      gender: map['gender'] ?? '',
      dateOfVisit: map['dateOfVisit'] ?? '',
      address: map['address'] ?? '',
      reasonForVisit: map['reasonForVisit'] ?? '', // 🟢 NEW FIELD
      hematology: List<String>.from(map['hematology'] ?? []),
      clinicalMicroscopy:
          List<String>.from(map['clinicalMicroscopy'] ?? []),
      bloodChemistry:
          List<String>.from(map['bloodChemistry'] ?? []),
      immunology: List<String>.from(map['immunology'] ?? []),
      radiology: List<String>.from(map['radiology'] ?? []),
      others: List<String>.from(map['others'] ?? []),
      notes: map['notes'] ?? '',
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : null,
    );
  }
}