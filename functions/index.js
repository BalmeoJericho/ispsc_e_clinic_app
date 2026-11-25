const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

exports.deleteEmployee = functions.https.onCall(async (data, context) => {
  try {
    const uid = data.uid;

    if (!uid) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "Missing user UID."
      );
    }

    const db = admin.firestore();

    // Delete from Authentication
    await admin.auth().deleteUser(uid);

    // Delete from users collection
    await db.collection("users").doc(uid).delete();

    // Find and delete employee document
    const snapshot = await db
        .collection("employees")
        .where("uid", "==", uid)
        .get();

    const batch = db.batch();

    snapshot.forEach((doc) => {
      batch.delete(doc.ref);
    });

    await batch.commit();

    return {
      success: true,
      message: "Employee deleted successfully.",
    };
  } catch (error) {
    console.error(error);

    throw new functions.https.HttpsError(
      "internal",
      error.message,
    );
  }
});