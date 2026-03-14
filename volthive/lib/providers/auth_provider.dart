import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:volthive/features/billing/data/models/invoice_model.dart';
import 'package:volthive/services/firebase_auth_service.dart';
import 'package:volthive/services/firestore_service.dart';

export 'package:volthive/services/firebase_auth_service.dart' show LoginResult;

// ─── User Model ───────────────────────────────────────────────────────────────

/// Represents a signed-in VoltHive user with their subscription info.
class UserModel {
  final String uid;
  final String email;
  final String name;
  final bool hasActivePlan;
  final String? activePlanId;

  const UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.hasActivePlan,
    this.activePlanId,
  });

  UserModel copyWith({
    String? uid,
    String? email,
    String? name,
    bool? hasActivePlan,
    String? activePlanId,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      hasActivePlan: hasActivePlan ?? this.hasActivePlan,
      activePlanId: activePlanId ?? this.activePlanId,
    );
  }

  /// Build a UserModel from a Firestore document map + Firebase uid.
  factory UserModel.fromFirestore(String uid, Map<String, dynamic> data) {
    return UserModel(
      uid: uid,
      email: data['email'] as String? ?? '',
      name: data['name'] as String? ?? '',
      hasActivePlan: data['hasActivePlan'] as bool? ?? false,
      activePlanId: data['activePlanId'] as String?,
    );
  }

  /// Build a minimal UserModel from a Firebase Auth user (before Firestore data loads).
  factory UserModel.fromFirebaseUser(fb.User fbUser) {
    return UserModel(
      uid: fbUser.uid,
      email: fbUser.email ?? '',
      name: fbUser.displayName ?? fbUser.email?.split('@').first ?? 'User',
      hasActivePlan: false,
    );
  }
}

// ─── AuthNotifier ─────────────────────────────────────────────────────────────

class AuthNotifier extends StateNotifier<UserModel?> {
  AuthNotifier() : super(null) {
    // Listen to Firebase Auth state changes automatically
    _firebaseAuthService.authStateChanges.listen(_onAuthStateChanged);
  }

  final _firebaseAuthService = FirebaseAuthService();
  final _firestoreService = FirestoreService();

  /// Called whenever Firebase auth state changes (login / logout / app restart)
  Future<void> _onAuthStateChanged(fb.User? fbUser) async {
    if (fbUser == null) {
      state = null;
      return;
    }

    // Start with basic auth info immediately (fast)
    state = UserModel.fromFirebaseUser(fbUser);

    // Then enrich with Firestore profile data
    final profile = await _firestoreService.getUserProfile(fbUser.uid);
    if (profile != null) {
      state = UserModel.fromFirestore(fbUser.uid, profile);
    } else {
      // First time sign-in — create the profile in Firestore
      final newProfile = {
        'email': fbUser.email ?? '',
        'name': fbUser.displayName ?? fbUser.email?.split('@').first ?? 'User',
        'hasActivePlan': false,
        'activePlanId': null,
        'createdAt': DateTime.now().toIso8601String(),
      };
      await _firestoreService.setUserProfile(fbUser.uid, newProfile);
    }
  }

  /// Sign in with email and password.
  Future<LoginResult> login(String email, String password) async {
    return _firebaseAuthService.signIn(email, password);
    // Auth state stream (_onAuthStateChanged) handles state update automatically
  }

  /// Sign up with email, password, and name.
  Future<LoginResult> register(String email, String password, String name) async {
    return _firebaseAuthService.signUp(email, password, name);
    // Auth state stream (_onAuthStateChanged) handles state update automatically
  }

  /// Called when user selects a plan (alias for confirmPayment).
  void selectPlan(String planId) => confirmPayment(planId);

  /// Called after a successful VoltHive Pay transaction.
  /// Persists the plan to Firestore AND generates + saves an invoice.
  Future<void> confirmPayment(String planId) async {
    if (state == null) return;

    // Resolve plan display name and price
    const planNames = {
      'spark': 'Spark', 'bloom': 'Bloom', 'thrive': 'Thrive',
      'surge': 'Surge', 'forge': 'Forge', 'apex': 'Apex',
    };
    const planPrices = {
      'spark': 3999.0, 'bloom': 6799.0, 'thrive': 11999.0,
      'surge': 17999.0, 'forge': 28999.0, 'apex': 0.0,
    };

    final planName = planNames[planId] ?? 'Custom';
    final planPrice = planPrices[planId] ?? 0.0;

    // Update plan in Firestore
    await _firestoreService.updatePlan(state!.uid, planId);

    // Generate and save invoice to Firestore
    final invoice = InvoiceModel.fromPayment(
      planName: planName,
      amount: planPrice,
    );
    await _firestoreService.saveInvoice(state!.uid, invoice);

    // Update local state immediately for responsive UI
    state = state!.copyWith(hasActivePlan: true, activePlanId: planId);
  }

  /// Sign out the current user.
  Future<void> logout() async {
    await _firebaseAuthService.signOut();
    // Auth state stream sets state = null automatically
  }
}

// ─── Providers ────────────────────────────────────────────────────────────────

final authProvider = StateNotifierProvider<AuthNotifier, UserModel?>((ref) {
  return AuthNotifier();
});

/// Convenience provider — same as authProvider but named for clarity in screens
final currentUserProvider = Provider<UserModel?>((ref) {
  return ref.watch(authProvider);
});
