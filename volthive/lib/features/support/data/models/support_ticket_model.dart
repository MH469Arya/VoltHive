import 'package:equatable/equatable.dart';

/// Support ticket model
class SupportTicketModel extends Equatable {
  final String id;
  final String title;
  final String description;
  final String status; // 'open', 'in_progress', 'resolved', 'closed'
  final String priority; // 'low', 'medium', 'high'
  final DateTime createdAt;
  final DateTime? resolvedAt;

  const SupportTicketModel({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    required this.createdAt,
    this.resolvedAt,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        status,
        priority,
        createdAt,
        resolvedAt,
      ];
}
