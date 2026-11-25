import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

Future<void> generateLabFormReport({
  required Map<String, dynamic> patient,
  required Map<String, dynamic> visit,
}) async {
  final pdf = pw.Document();

  final logoData = await rootBundle.load('assets/ISPSC.jpg');
  final logo = pw.MemoryImage(logoData.buffer.asUint8List());

  final hematology = List<String>.from(visit['hematology'] ?? []);
  final microscopy = List<String>.from(visit['clinicalMicroscopy'] ?? []);
  final chemistry = List<String>.from(visit['bloodChemistry'] ?? []);
  final immunology = List<String>.from(visit['immunology'] ?? []);
  final radiology = List<String>.from(visit['radiology'] ?? []);
  final others = List<String>.from(visit['others'] ?? []);

  pw.Widget mark(bool selected) {
    return pw.Container(
      width: 10,
      alignment: pw.Alignment.centerLeft,
      child: pw.Text(
        selected ? "/" : "",
        style: const pw.TextStyle(fontSize: 5.0),
      ),
    );
  }

  pw.Widget lineItem({
    required bool selected,
    required String text,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 0.05),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          mark(selected),
          pw.SizedBox(width: 2),
          pw.Expanded(
            child: pw.Text(
              text,
              style: const pw.TextStyle(fontSize: 4.95),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget sectionTitle(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(top: 0.9, bottom: 0.25),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 5.15,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
    );
  }

  pw.Widget infoField({
    required String label,
    required String value,
    required double labelWidth,
  }) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        pw.SizedBox(
          width: labelWidth,
          child: pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: 5.0,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ),
        pw.Expanded(
          child: pw.Container(
            padding: const pw.EdgeInsets.only(bottom: 0.4),
            decoration: const pw.BoxDecoration(
              border: pw.Border(
                bottom: pw.BorderSide(width: 0.25),
              ),
            ),
            child: pw.Text(
              value,
              style: const pw.TextStyle(fontSize: 4.95),
            ),
          ),
        ),
      ],
    );
  }

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat(
        110 * PdfPageFormat.mm,
        220 * PdfPageFormat.mm,
        marginAll: 0,
      ),
      margin: const pw.EdgeInsets.fromLTRB(4, 4, 4, 4),
      build: (context) {
        return pw.Container(
          decoration: pw.BoxDecoration(
            border: pw.Border.all(width: 0.3),
          ),
          padding: const pw.EdgeInsets.fromLTRB(4, 3, 4, 3),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            mainAxisSize: pw.MainAxisSize.min,
            children: [
              pw.Container(
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(width: 0.25),
                ),
                padding: const pw.EdgeInsets.fromLTRB(3, 2, 3, 2),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Container(
                      width: 22,
                      height: 22,
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(width: 0.25),
                      ),
                      padding: const pw.EdgeInsets.all(1),
                      child: pw.Image(logo, fit: pw.BoxFit.contain),
                    ),
                    pw.SizedBox(width: 4),
                    pw.Expanded(
                      child: pw.Column(
                        mainAxisSize: pw.MainAxisSize.min,
                        children: [
                          pw.Text(
                            "Republic of the Philippines",
                            textAlign: pw.TextAlign.center,
                            style: const pw.TextStyle(fontSize: 4.0),
                          ),
                          pw.SizedBox(height: 0.2),
                          pw.Text(
                            "ILOCOS SUR POLYTECHNIC STATE COLLEGE",
                            textAlign: pw.TextAlign.center,
                            style: pw.TextStyle(
                              fontSize: 5.1,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.SizedBox(height: 0.2),
                          pw.Text(
                            "Tagudin Campus, Tagudin, Ilocos Sur",
                            textAlign: pw.TextAlign.center,
                            style: const pw.TextStyle(fontSize: 4.0),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 1.2),

              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    flex: 6,
                    child: infoField(
                      label: "NAME:",
                      value: (patient['patientName'] ?? '').toString(),
                      labelWidth: 24,
                    ),
                  ),
                  pw.SizedBox(width: 5),
                  pw.Expanded(
                    flex: 4,
                    child: infoField(
                      label: "Date:",
                      value: (visit['dateOfVisit'] ?? '').toString(),
                      labelWidth: 20,
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 0.8),

              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    flex: 6,
                    child: infoField(
                      label: "ADDRESS:",
                      value: (patient['address'] ?? '').toString(),
                      labelWidth: 36,
                    ),
                  ),
                  pw.SizedBox(width: 5),
                  pw.Expanded(
                    flex: 4,
                    child: infoField(
                      label: "AGE/GENDER:",
                      value:
                          "${patient['age'] ?? ''} ${patient['gender'] ?? ''}",
                      labelWidth: 48,
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 1.0),

              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        sectionTitle("HEMATOLOGY"),
                        lineItem(
                          selected: hematology.contains("Complete Blood Count"),
                          text: "Complete Blood Count",
                        ),
                        lineItem(
                          selected:
                              hematology.contains("Hemoglobin, Hematocrit"),
                          text: "Hemoglobin, Hematocrit",
                        ),
                        lineItem(
                          selected: hematology.contains("Platelet"),
                          text: "Platelet",
                        ),
                        lineItem(
                          selected: hematology.contains("ABO and Rh Typing"),
                          text: "ABO and Rh Typing",
                        ),
                        lineItem(
                          selected: hematology.contains("PT"),
                          text: "PT",
                        ),
                        lineItem(
                          selected: hematology.contains("APTT"),
                          text: "APTT",
                        ),
                        lineItem(
                          selected:
                              hematology.contains("Peripheral Blood Smear"),
                          text: "Peripheral Blood Smear",
                        ),
                        lineItem(
                          selected: hematology.any((e) => ![
                            "Complete Blood Count",
                            "Hemoglobin, Hematocrit",
                            "Platelet",
                            "ABO and Rh Typing",
                            "PT",
                            "APTT",
                            "Peripheral Blood Smear",
                          ].contains(e)),
                          text: "Others",
                        ),

                        pw.SizedBox(height: 0.8),

                        sectionTitle("CLINICAL BLOOD CHEMISTRY"),
                        lineItem(
                          selected: chemistry.contains("Fasting Blood Sugar"),
                          text: "Fasting Blood Sugar",
                        ),
                        lineItem(
                          selected: chemistry.contains("HbA1C"),
                          text: "HbA1C",
                        ),
                        lineItem(
                          selected: chemistry.contains("Total Cholesterol"),
                          text: "Total Cholesterol",
                        ),
                        lineItem(
                          selected: chemistry.contains("Triglycerides"),
                          text: "Triglycerides",
                        ),
                        lineItem(
                          selected: chemistry.contains("HDL"),
                          text: "HDL",
                        ),
                        lineItem(
                          selected: chemistry.contains("LDL"),
                          text: "LDL",
                        ),
                        lineItem(
                          selected:
                              chemistry.contains("Blood Urea Nitrogen"),
                          text: "Blood Urea Nitrogen",
                        ),
                        lineItem(
                          selected: chemistry.contains("Creatinine"),
                          text: "Creatinine",
                        ),
                        lineItem(
                          selected: chemistry.contains("Blood Uric Acid"),
                          text: "Blood Uric Acid",
                        ),
                        lineItem(
                          selected: chemistry.contains("SGPT"),
                          text: "SGPT",
                        ),
                        lineItem(
                          selected: chemistry.contains("SGOT"),
                          text: "SGOT",
                        ),
                        lineItem(
                          selected: chemistry.contains("Amylase"),
                          text: "Amylase",
                        ),
                        lineItem(
                          selected: chemistry.contains("Lipase"),
                          text: "Lipase",
                        ),
                        lineItem(
                          selected: chemistry.contains("Sodium"),
                          text: "Sodium",
                        ),
                        lineItem(
                          selected: chemistry.contains("Potassium"),
                          text: "Potassium",
                        ),
                        lineItem(
                          selected: chemistry.contains("Chloride"),
                          text: "Chloride",
                        ),
                        lineItem(
                          selected: chemistry.contains("Ionized Calcium"),
                          text: "Ionized Calcium",
                        ),
                        lineItem(
                          selected: chemistry.any((e) => ![
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
                            "Ionized Calcium",
                          ].contains(e)),
                          text: "Others",
                        ),
                      ],
                    ),
                  ),

                  pw.SizedBox(width: 8),

                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        sectionTitle("CLINICAL MICROSCOPY AND\nPARASITOLOGY"),
                        lineItem(
                          selected: microscopy.contains("Urinalysis"),
                          text: "Urinalysis",
                        ),
                        lineItem(
                          selected: microscopy.contains("Pregnancy Test"),
                          text: "Pregnancy Test",
                        ),
                        lineItem(
                          selected: microscopy.contains("Fecalysis"),
                          text: "Fecalysis",
                        ),
                        lineItem(
                          selected: microscopy.contains("Fecal Occult Blood"),
                          text: "Fecal Occult Blood",
                        ),
                        lineItem(
                          selected: microscopy.contains("Drug Testing"),
                          text: "Drug Testing",
                        ),
                        lineItem(
                          selected: microscopy.any((e) => ![
                            "Urinalysis",
                            "Pregnancy Test",
                            "Fecalysis",
                            "Fecal Occult Blood",
                            "Drug Testing",
                          ].contains(e)),
                          text: "Others",
                        ),

                        pw.SizedBox(height: 0.9),

                        sectionTitle("IMMUNOLOGY AND SEROLOGY"),
                        lineItem(
                          selected: immunology.contains("HBsAg"),
                          text: "HBsAg",
                        ),
                        lineItem(
                          selected: immunology.contains("Typhi Dot"),
                          text: "Typhi Dot",
                        ),
                        lineItem(
                          selected: immunology.contains("Dengue IgG/ IgM") ||
                              immunology.contains("Dengue IgG/IgM"),
                          text: "Dengue IgG/ IgM",
                        ),
                        lineItem(
                          selected: immunology.any((e) => ![
                            "HBsAg",
                            "Typhi Dot",
                            "Dengue IgG/ IgM",
                            "Dengue IgG/IgM",
                          ].contains(e)),
                          text: "Others",
                        ),

                        pw.SizedBox(height: 0.9),

                        sectionTitle("RADIOLOGY"),
                        lineItem(
                          selected: radiology.contains("Chest X-ray"),
                          text: "Chest X-ray",
                        ),
                        lineItem(
                          selected: radiology.contains("Abdominal UTZ"),
                          text: "Abdominal UTZ",
                        ),
                        lineItem(
                          selected:
                              radiology.contains("Digital Rectal Exam"),
                          text: "Digital Rectal Exam",
                        ),
                        lineItem(
                          selected:
                              radiology.contains("Breast and Pelvic UTZ"),
                          text: "Breast and Pelvic UTZ",
                        ),

                        pw.SizedBox(height: 0.9),

                        sectionTitle("OTHERS"),
                        lineItem(
                          selected: others.contains("12L- ECG") ||
                              others.contains("12L ECG") ||
                              others.contains("ECG"),
                          text: "12L- ECG",
                        ),
                        lineItem(
                          selected: others.contains("Pap Smear"),
                          text: "Pap Smear",
                        ),
                        lineItem(
                          selected:
                              others.contains("Prostate Specific Antigen"),
                          text: "Prostate Specific Antigen",
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 0.5),

              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.SizedBox(
                  width: 86,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Text(
                        "MARIA RONA S. GARCIA, RN",
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(
                          fontSize: 4.9,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text(
                        "NURSE II",
                        style: const pw.TextStyle(fontSize: 4.7),
                      ),
                      pw.Text(
                        "Lic. No. 0738438",
                        style: const pw.TextStyle(fontSize: 4.5),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    ),
  );

  final Uint8List bytes = await pdf.save();

  await Printing.layoutPdf(
    onLayout: (format) async => bytes,
  );
}