import '../models/medical_record.dart';

final List<MedicalRecord> dummyRecords = [
  MedicalRecord(
    patientName: 'John Doe',
    patientID: '001',
    age: '30',
    gender: 'Male',
    dateOfVisit: '2026-02-06',
    address: '123 Street, Tagudin',
    hematology: [
      'Complete Blood Count',
      'Hemoglobin',
      'Hematocrit',
      'Platelet',
      'ABO and Rh Typing',
      'PT',
      'APTT',
      'Peripheral Blood Smear',
      'Others'
    ],
    clinicalMicroscopy: [
      'Urinalysis',
      'Pregnancy Test',
      'Fecalysis',
      'Fecal Occult Blood',
      'Drug Testing',
      'Others'
    ],
    bloodChemistry: [
      'Fasting Blood Sugar',
      'HbA1C',
      'Total Cholesterol',
      'Triglycerides',
      'HDL',
      'LDL',
      'Blood Urea Nitrogen',
      'Creatinine',
      'Blood Uric Acid',
      'SGPT',
      'SGOT',
      'Amylase',
      'Lipase',
      'Sodium',
      'Potassium',
      'Chloride',
      'Ionized Calcium',
      'Others'
    ],
    immunology: ['HBsAg', 'Typhi Dot', 'Dengue IGg/IGm', 'Others'],
    radiology: [
      'Chest X-ray',
      'Abdominal UTZ',
      'Digital Rectal Exam',
      'Breast UTZ',
      'Pelvic UTZ'
    ],
    others: ['12LECG', 'Pap Smear', 'Prostate Specific Antigen'],
    notes: 'No abnormalities detected',
  ),
];
