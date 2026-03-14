import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:volthive/features/billing/data/models/invoice_model.dart';

/// Handles all Cloud Firestore reads and writes for VoltHive.
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ─── User Profile ────────────────────────────────────────────────────────────

  /// Fetches the user profile from `users/{uid}`.
  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      return doc.exists ? doc.data() : null;
    } catch (e) {
      return null;
    }
  }

  /// Creates or updates the user profile in `users/{uid}`.
  Future<void> setUserProfile(String uid, Map<String, dynamic> data) async {
    await _db.collection('users').doc(uid).set(data, SetOptions(merge: true));
  }

  /// Updates only the plan fields for a user after a successful payment.
  Future<void> updatePlan(String uid, String planId) async {
    await _db.collection('users').doc(uid).set({
      'hasActivePlan': true,
      'activePlanId': planId,
      'planUpdatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Streams the user profile so the UI rebuilds on any Firestore change.
  Stream<Map<String, dynamic>?> streamUserProfile(String uid) {
    return _db.collection('users').doc(uid).snapshots().map((doc) {
      return doc.exists ? doc.data() : null;
    });
  }

  // ─── Invoices ────────────────────────────────────────────────────────────────

  /// Saves a new invoice document to `users/{uid}/invoices/{invoice.id}`.
  Future<void> saveInvoice(String uid, InvoiceModel invoice) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('invoices')
        .doc(invoice.id)
        .set(invoice.toMap());
  }

  /// Fetches all invoices for a user, ordered by date (newest first).
  Future<List<InvoiceModel>> getInvoices(String uid) async {
    try {
      final snapshot = await _db
          .collection('users')
          .doc(uid)
          .collection('invoices')
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => InvoiceModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Streams invoices in real-time (UI auto-updates when new invoice saved).
  Stream<List<InvoiceModel>> streamInvoices(String uid) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('invoices')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => InvoiceModel.fromMap(doc.data())).toList());
  }
}
