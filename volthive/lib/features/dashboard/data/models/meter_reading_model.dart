import 'package:equatable/equatable.dart';

/// Meter reading model for real-time energy data
class MeterReadingModel extends Equatable {
  final DateTime timestamp;
  final double solarGeneratedKwh;
  final double gridConsumedKwh;
  final int batteryLevel; // 0-100
  final bool backupActive;
  final double totalSavingsINR;
  final double co2SavedKg;

  const MeterReadingModel({
    required this.timestamp,
    required this.solarGeneratedKwh,
    required this.gridConsumedKwh,
    required this.batteryLevel,
    required this.backupActive,
    required this.totalSavingsINR,
    required this.co2SavedKg,
  });

  @override
  List<Object?> get props => [
        timestamp,
        solarGeneratedKwh,
        gridConsumedKwh,
        batteryLevel,
        backupActive,
        totalSavingsINR,
        co2SavedKg,
      ];
}
