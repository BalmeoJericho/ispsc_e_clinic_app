import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>?> getCurrentUser(String uid) async {
    final doc =
        await _firestore.collection("users").doc(uid).get();

    if (!doc.exists) return null;

    return doc.data();
  }
}