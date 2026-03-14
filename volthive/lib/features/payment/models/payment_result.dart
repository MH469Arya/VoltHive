/// Result of a payment attempt through VoltHive Payment Gateway.
enum PaymentStatus { success, failure, cancelled }

class PaymentResult {
  final PaymentStatus status;
  final String? transactionId;
  final String? errorMessage;

  const PaymentResult({
    required this.status,
    this.transactionId,
    this.errorMessage,
  });

  bool get isSuccess => status == PaymentStatus.success;
}
