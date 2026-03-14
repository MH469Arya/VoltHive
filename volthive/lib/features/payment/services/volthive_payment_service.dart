import 'dart:math';
import 'package:volthive/features/payment/models/payment_result.dart';

/// Simulates a payment gateway. Mimics async network call with a delay.
/// In production, this would call a real payment processor.
class VoltHivePaymentService {
  static final VoltHivePaymentService _instance =
      VoltHivePaymentService._internal();
  factory VoltHivePaymentService() => _instance;
  VoltHivePaymentService._internal();

  final _random = Random();

  /// Processes a payment. Returns a [PaymentResult] after a simulated delay.
  /// [amountInRupees] — the plan's monthly price
  /// [methodLabel]    — human-readable label, e.g. "UPI", "HDFC Card"
  Future<PaymentResult> processPayment({
    required double amountInRupees,
    required String methodLabel,
  }) async {
    // Simulate network latency + gateway processing (2–3 s)
    await Future.delayed(Duration(milliseconds: 2000 + _random.nextInt(1000)));

    // SANDBOX: always returns success.
    // To test failure: change PaymentStatus.success → PaymentStatus.failure below.
    final txnId = _generateTransactionId();
    return PaymentResult(
      status: PaymentStatus.success,
      transactionId: txnId,
    );
  }

  String _generateTransactionId() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return 'VH-${List.generate(10, (_) => chars[_random.nextInt(chars.length)]).join()}';
  }
}
