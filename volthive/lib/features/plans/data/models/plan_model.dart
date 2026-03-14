import 'package:equatable/equatable.dart';

/// Subscription plan model
class PlanModel extends Equatable {
  final String id;
  final String name;
  final String description;
  final double solarKw;
  final double batteryKwh;
  final String backupHours;
  final double uptimeSla;
  final int monthlyPrice;
  final int annualPrice;
  final List<String> features;
  final List<String> bestFor;
  final bool isRecommended;

  const PlanModel({
    required this.id,
    required this.name,
    required this.description,
    required this.solarKw,
    required this.batteryKwh,
    required this.backupHours,
    required this.uptimeSla,
    required this.monthlyPrice,
    required this.annualPrice,
    required this.features,
    required this.bestFor,
    this.isRecommended = false,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        solarKw,
        batteryKwh,
        backupHours,
        uptimeSla,
        monthlyPrice,
        annualPrice,
        features,
        bestFor,
        isRecommended,
      ];
}
