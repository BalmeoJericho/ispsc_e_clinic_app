import 'package:cloud_firestore/cloud_firestore.dart';

class EmployeeModel {
  final String uid;
  final String employeeId;
  final String firstName;
  final String middleName;
  final String lastName;
  final String fullName;
  final String staffType;
  final String department;
  final String email;
  final String role;
  final String status;
  final String photoUrl;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;

  EmployeeModel({
    required this.uid,
    required this.employeeId,
    required this.firstName,
    required this.middleName,
    required this.lastName,
    required this.fullName,
    required this.staffType,
    required this.department,
    required this.email,
    required this.role,
    required this.status,
    required this.photoUrl,
    this.createdAt,
    this.updatedAt,
  });

  factory EmployeeModel.fromMap(
    Map<String, dynamic> data,
    String documentId,
  ) {
    return EmployeeModel(
      uid: documentId,
      employeeId: data['employeeId'] ?? '',
      firstName: data['firstName'] ?? '',
      middleName: data['middleName'] ?? '',
      lastName: data['lastName'] ?? '',
      fullName: data['fullName'] ?? '',
      staffType: data['staffType'] ?? '',
      department: data['department'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? 'employee',
      status: data['status'] ?? 'active',
      photoUrl: data['photoUrl'] ?? '',
      createdAt: data['createdAt'],
      updatedAt: data['updatedAt'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'employeeId': employeeId,
      'firstName': firstName,
      'middleName': middleName,
      'lastName': lastName,
      'fullName': fullName,
      'staffType': staffType,
      'department': department,
      'email': email,
      'role': role,
      'status': status,
      'photoUrl': photoUrl,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}