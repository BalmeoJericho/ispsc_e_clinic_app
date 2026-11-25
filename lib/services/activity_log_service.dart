
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class ActivityLogService {

  static final FirebaseFirestore _db = FirebaseFirestore.instance;

////////////////////////////////////////////////////////////
/// CREATE ACTIVITY LOG
////////////////////////////////////////////////////////////

  static Future<void> log({
    required String action,
    required String details,
    String user = "Clinic Staff",
    String source = "mobile", // mobile or web
    String? patientName,
    String? patientId,
  }) async {

    if (action.isEmpty) return;

    try {

      await _db.collection("activity_logs").add({

        "action": action,
        "details": details,
        "user": user,

        // optional patient tracking
        "patientName": patientName ?? "",
        "patientId": patientId ?? "",

        // where the activity came from
        "source": source,

        // main timestamp used by web dashboard
        "timestamp": FieldValue.serverTimestamp(),

        // backup timestamp
        "createdAt": DateTime.now(),

      });

    } catch (e) {

      debugPrint("Activity log error: $e");

    }
  }

}

