import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// Invoice model for billing
class InvoiceModel extends Equatable {
  final String id;
  final DateTime date;
  final DateTime dueDate;
  final double amount;
  final String status; // 'paid', 'pending', 'overdue'
  final String planName;
  final String period;

  const InvoiceModel({
    required this.id,
    required this.date,
    required this.dueDate,
    required this.amount,
    required this.status,
    required this.planName,
    required this.period,
  });

  // ─── Serialization ──────────────────────────────────────────────────────────

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': Timestamp.fromDate(date),
      'dueDate': Timestamp.fromDate(dueDate),
      'amount': amount,
      'status': status,
      'planName': planName,
      'period': period,
    };
  }

  factory InvoiceModel.fromMap(Map<String, dynamic> map) {
    return InvoiceModel(
      id: map['id'] as String,
      date: (map['date'] as Timestamp).toDate(),
      dueDate: (map['dueDate'] as Timestamp).toDate(),
      amount: (map['amount'] as num).toDouble(),
      status: map['status'] as String,
      planName: map['planName'] as String,
      period: map['period'] as String,
    );
  }

  // ─── Seeded historical invoices for Rahul ───────────────────────────────────

  static List<InvoiceModel> seededInvoicesForRahul() {
    final now = DateTime.now();
    return [
      InvoiceModel(
        id: 'INV-2025-003',
        date: DateTime(now.year, now.month, 1),
        dueDate: DateTime(now.year, now.month, 10),
        amount: 6799,
        status: 'paid',
        planName: 'Bloom',
        period: _monthLabel(now.year, now.month),
      ),
      InvoiceModel(
        id: 'INV-2025-002',
        date: DateTime(now.year, now.month - 1, 1),
        dueDate: DateTime(now.year, now.month - 1, 10),
        amount: 6799,
        status: 'paid',
        planName: 'Bloom',
        period: _monthLabel(now.year, now.month - 1),
      ),
      InvoiceModel(
        id: 'INV-2025-001',
        date: DateTime(now.year, now.month - 2, 1),
        dueDate: DateTime(now.year, now.month - 2, 10),
        amount: 6799,
        status: 'paid',
        planName: 'Bloom',
        period: _monthLabel(now.year, now.month - 2),
      ),
    ];
  }

  /// Generate a fresh invoice right after payment.
  factory InvoiceModel.fromPayment({
    required String planName,
    required double amount,
  }) {
    final now = DateTime.now();
    final id =
        'INV-${now.year}-${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    return InvoiceModel(
      id: id,
      date: now,
      dueDate: now.add(const Duration(days: 7)),
      amount: amount,
      status: 'paid',
      planName: planName,
      period: _monthLabel(now.year, now.month),
    );
  }

  static String _monthLabel(int year, int month) {
    const months = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    // Handle month underflow (e.g., month 0 = December of previous year)
    if (month <= 0) {
      month += 12;
      year -= 1;
    }
    return '${months[month]} $year';
  }

  @override
  List<Object?> get props => [id, date, dueDate, amount, status, planName, period];
}
