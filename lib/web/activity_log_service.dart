import 'package:cloud_firestore/cloud_firestore.dart';

class WebActivityLogService {

  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static Future<void> log({
    required String action,
    required String details,
    String user = "Clinic Staff",
    String source = "web",
    String? patientName,
  }) async {

    try {

      await _db.collection("activity_logs").add({

        "action": action,
        "details": details,
        "user": user,
        "patientName": patientName ?? "",
        "source": source,
        "timestamp": FieldValue.serverTimestamp(),

      });

    } catch (e) {

      print("Activity log error: $e");

    }
  }
}