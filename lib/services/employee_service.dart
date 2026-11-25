import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import '../firebase_options.dart';
import '../models/employee_model.dart';

class EmployeeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');

  /// ==========================================
  /// GET ALL EMPLOYEES
  /// ==========================================
  Stream<List<EmployeeModel>> getEmployees() {
    return usersCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) {
            return EmployeeModel.fromMap(
              doc.data() as Map<String, dynamic>,
              doc.id,
            );
          }).toList(),
        );
  }

  /// ==========================================
  /// CREATE SECONDARY FIREBASE APP
  /// ==========================================
  Future<FirebaseApp> _createSecondaryApp() async {
    const appName = 'employeeCreator';

    try {
      return Firebase.app(appName);
    } on FirebaseException {
      return await Firebase.initializeApp(
        name: appName,
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  }

  /// ==========================================
  /// CREATE EMPLOYEE ACCOUNT
  /// ==========================================
  Future<void> createEmployeeAccount({
    required EmployeeModel employee,
    required String password,
  }) async {
    final secondaryApp = await _createSecondaryApp();

    final secondaryAuth = FirebaseAuth.instanceFor(
      app: secondaryApp,
    );

    try {
      // Create Authentication account
      UserCredential credential =
          await secondaryAuth.createUserWithEmailAndPassword(
        email: employee.email.trim(),
        password: password,
      );

      final uid = credential.user!.uid;

      // Save login account
        await _firestore.collection('users').doc(uid).set({
          ...employee.toMap(),
          'uid': uid,
        });

        // Save employee profile
        await _firestore.collection('employees').doc(employee.employeeId).set({
          ...employee.toMap(),
          'uid': uid,
        });
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          throw Exception(
              'This email address is already registered.');
        case 'invalid-email':
          throw Exception(
              'Please enter a valid email address.');
        case 'weak-password':
          throw Exception(
              'Password is too weak.');
        default:
          throw Exception(
              e.message ?? 'Failed to create employee.');
      }
    } catch (e) {
      throw Exception(
          'Unable to create employee account.\n$e');
    } finally {
      await secondaryAuth.signOut();

      try {
        await secondaryApp.delete();
      } catch (_) {}
    }
  }

  /// ==========================================
  /// GET SINGLE EMPLOYEE
  /// ==========================================
  Future<EmployeeModel?> getEmployee(String uid) async {
    final doc = await usersCollection.doc(uid).get();

    if (!doc.exists) return null;

    return EmployeeModel.fromMap(
      doc.data() as Map<String, dynamic>,
      doc.id,
    );
  }

  /// ==========================================
  /// UPDATE EMPLOYEE
  /// ==========================================
  Future<void> updateEmployee(
    EmployeeModel employee,
  ) async {
    await usersCollection.doc(employee.uid).update(
          employee.toMap(),
        );
  }

  /// ==========================================
  /// UPDATE EMPLOYEE STATUS
  /// ==========================================
  Future<void> updateStatus(
  EmployeeModel employee,
  String status,
) async {
  // Update users collection
  await _firestore.collection('users').doc(employee.uid).update({
    'status': status,
    'updatedAt': FieldValue.serverTimestamp(),
  });

  // Update employees collection
  await _firestore
      .collection('employees')
      .doc(employee.employeeId)
      .update({
    'status': status,
    'updatedAt': FieldValue.serverTimestamp(),
  });
}

  /// ==========================================
  /// DELETE EMPLOYEE
  /// ==========================================
  Future<void> deleteEmployee(
        EmployeeModel employee,
      ) async {
        // Delete from users collection
        await _firestore
            .collection('users')
            .doc(employee.uid)
            .delete();

        // Delete from employees collection
        await _firestore
            .collection('employees')
            .doc(employee.employeeId)
            .delete();
    }
}