import 'package:cloud_firestore/cloud_firestore.dart';

class LabRequestModel {
  final String id;
  final String requestId;

  final String employeeUid;
  final String employeeId;
  final String employeeName;
  final String department;
  final String staffType;

  final String requestType;
  final List<String> selectedTests;
  final String purpose;

  final String status;
  final String requestMethod;

  final String approvedBy;
  final Timestamp? approvedAt;

  final String rejectedBy;
  final String rejectionReason;
  final Timestamp? rejectedAt;

  final String formUrl;

  final Timestamp? createdAt;
  final Timestamp? updatedAt;

  const LabRequestModel({
    required this.id,
    required this.requestId,
    required this.employeeUid,
    required this.employeeId,
    required this.employeeName,
    required this.department,
    required this.staffType,
    required this.requestType,
    required this.selectedTests,
    required this.purpose,
    required this.status,
    required this.requestMethod,
    required this.approvedBy,
    this.approvedAt,
    required this.rejectedBy,
    required this.rejectionReason,
    this.rejectedAt,
    required this.formUrl,
    this.createdAt,
    this.updatedAt,
  });

  factory LabRequestModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;

    return LabRequestModel(
      id: doc.id,
      requestId: data['requestId'] ?? '',
      employeeUid: data['employeeUid'] ?? '',
      employeeId: data['employeeId'] ?? '',
      employeeName: data['employeeName'] ?? '',
      department: data['department'] ?? '',
      staffType: data['staffType'] ?? '',
      requestType: data['requestType'] ?? '',
      selectedTests:
          List<String>.from(data['selectedTests'] ?? []),
      purpose: data['purpose'] ?? '',
      status: data['status'] ?? 'Pending',
      requestMethod: data['requestMethod'] ?? '',
      approvedBy: data['approvedBy'] ?? '',
      approvedAt: data['approvedAt'],
      rejectedBy: data['rejectedBy'] ?? '',
      rejectionReason: data['rejectionReason'] ?? '',
      rejectedAt: data['rejectedAt'],
      formUrl: data['formUrl'] ?? '',
      createdAt: data['createdAt'],
      updatedAt: data['updatedAt'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'requestId': requestId,
      'employeeUid': employeeUid,
      'employeeId': employeeId,
      'employeeName': employeeName,
      'department': department,
      'staffType': staffType,
      'requestType': requestType,
      'selectedTests': selectedTests,
      'purpose': purpose,
      'status': status,
      'requestMethod': requestMethod,
      'approvedBy': approvedBy,
      'approvedAt': approvedAt,
      'rejectedBy': rejectedBy,
      'rejectionReason': rejectionReason,
      'rejectedAt': rejectedAt,
      'formUrl': formUrl,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  LabRequestModel copyWith({
    String? status,
    String? approvedBy,
    Timestamp? approvedAt,
    String? rejectedBy,
    String? rejectionReason,
    Timestamp? rejectedAt,
    String? requestMethod,
    String? formUrl,
    Timestamp? updatedAt,
  }) {
    return LabRequestModel(
      id: id,
      requestId: requestId,
      employeeUid: employeeUid,
      employeeId: employeeId,
      employeeName: employeeName,
      department: department,
      staffType: staffType,
      requestType: requestType,
      selectedTests: selectedTests,
      purpose: purpose,
      status: status ?? this.status,
      requestMethod: requestMethod ?? this.requestMethod,
      approvedBy: approvedBy ?? this.approvedBy,
      approvedAt: approvedAt ?? this.approvedAt,
      rejectedBy: rejectedBy ?? this.rejectedBy,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      rejectedAt: rejectedAt ?? this.rejectedAt,
      formUrl: formUrl ?? this.formUrl,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}