import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/lab_request_model.dart';

class LabRequestService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('lab_requests');

  // ============================
  // CREATE
  // ============================

  Future<void> createRequest(
    LabRequestModel request,
  ) async {
    await _collection.add(request.toMap());
  }

  // ============================
  // READ ALL REQUESTS
  // ============================

  Stream<List<LabRequestModel>> getRequests() {
    return _collection
        .orderBy(
          'createdAt',
          descending: true,
        )
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) =>
                    LabRequestModel.fromFirestore(
                  doc,
                ),
              )
              .toList(),
        );
  }

  // ============================
  // READ BY STATUS
  // ============================

  Stream<List<LabRequestModel>>
      getRequestsByStatus(
    String status,
  ) {
    return _collection
        .where(
          'status',
          isEqualTo: status,
        )
        .orderBy(
          'createdAt',
          descending: true,
        )
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) =>
                    LabRequestModel.fromFirestore(
                  doc,
                ),
              )
              .toList(),
        );
  }

  // ============================
  // UPDATE
  // ============================

  Future<void> updateRequest(
    String id,
    Map<String, dynamic> data,
  ) async {
    await _collection.doc(id).update(data);
  }

  // ============================
  // APPROVE REQUEST
  // ============================

  Future<void> approveRequest({
    required String id,
    required String approvedBy,
  }) async {
    await _collection.doc(id).update({
      'status': 'Approved',
      'approvedBy': approvedBy,
      'approvedAt':
          FieldValue.serverTimestamp(),
      'updatedAt':
          FieldValue.serverTimestamp(),
    });
  }

  // ============================
  // REJECT REQUEST
  // ============================

  Future<void> rejectRequest({
    required String id,
    required String rejectedBy,
    required String rejectionReason,
  }) async {
    await _collection.doc(id).update({
      'status': 'Rejected',
      'rejectedBy': rejectedBy,
      'rejectionReason': rejectionReason,
      'rejectedAt':
          FieldValue.serverTimestamp(),
      'updatedAt':
          FieldValue.serverTimestamp(),
    });
  }

  // ============================
  // DELETE REQUEST
  // ============================

  Future<void> deleteRequest(
    String id,
  ) async {
    await _collection.doc(id).delete();
  }
}