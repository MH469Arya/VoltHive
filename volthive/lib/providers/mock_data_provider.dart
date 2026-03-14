import 'dart:math';
import 'package:volthive/features/plans/data/models/plan_model.dart';
import 'package:volthive/features/dashboard/data/models/meter_reading_model.dart';

/// Mock data provider for Phase 1 UI development
class MockDataProvider {
  MockDataProvider._();

  // All 6 subscription plans from README
  static List<PlanModel> getPlans() {
    return [
      const PlanModel(
        id: 'spark',
        name: 'Spark',
        description: 'Perfect for small homes and shops',
        solarKw: 3.0,
        batteryKwh: 6.0,
        backupHours: '6-8 hours',
        uptimeSla: 99.5,
        monthlyPrice: 3999,
        annualPrice: 41500,
        features: [
          'Real-time dashboard access',
          'Carbon footprint tracking',
          'Outage & savings alerts',
          'Support ticketing',
        ],
        bestFor: [
          'Small homes (1-2 BHK flats)',
          'Compact row houses',
          'Small shops',
          'Kirana stores',
          'Tiny cafes',
          'Clinics',
        ],
      ),
      const PlanModel(
        id: 'bloom',
        name: 'Bloom',
        description: 'Ideal for medium homes and small businesses',
        solarKw: 6.0,
        batteryKwh: 10.0,
        backupHours: '12 hours',
        uptimeSla: 99.7,
        monthlyPrice: 6799,
        annualPrice: 70500,
        features: [
          'Real-time dashboard access',
          'Carbon footprint tracking',
          'Outage & savings alerts',
          'Support ticketing',
          'Priority support',
        ],
        bestFor: [
          'Medium homes (2-3 BHK flats)',
          'Independent bungalows',
          'Medium cafes',
          'Small restaurants',
          'Boutique shops',
          'Small offices (5-15 people)',
        ],
        isRecommended: true, // Recommended for demo
      ),
      const PlanModel(
        id: 'thrive',
        name: 'Thrive',
        description: 'Great for larger homes and medium businesses',
        solarKw: 10.0,
        batteryKwh: 15.0,
        backupHours: '18 hours',
        uptimeSla: 99.8,
        monthlyPrice: 11999,
        annualPrice: 124500,
        features: [
          'Real-time dashboard access',
          'Carbon footprint tracking',
          'Outage & savings alerts',
          'Support ticketing',
          'Priority 24×7 support',
          'Advanced analytics',
        ],
        bestFor: [
          'Larger homes (villas)',
          'Restaurants',
          'Medium hotels (10-25 rooms)',
          'Gyms',
          'Coaching classes',
          'Small schools (up to 200 students)',
        ],
      ),
      const PlanModel(
        id: 'surge',
        name: 'Surge',
        description: 'Powerful solution for hotels and complexes',
        solarKw: 15.0,
        batteryKwh: 25.0,
        backupHours: '24 hours',
        uptimeSla: 99.9,
        monthlyPrice: 17999,
        annualPrice: 186500,
        features: [
          'Real-time dashboard access',
          'Carbon footprint tracking',
          'Outage & savings alerts',
          'Support ticketing',
          'Priority 24×7 support',
          'Advanced analytics',
          'Dedicated account manager',
        ],
        bestFor: [
          'Medium hotels (25-60 rooms)',
          'Resorts',
          'Sports complexes',
          'Large gyms',
          'Mid-size schools (200-800 students)',
          'Offices (20-60 people)',
        ],
      ),
      const PlanModel(
        id: 'forge',
        name: 'Forge',
        description: 'Enterprise-grade for large facilities',
        solarKw: 25.0,
        batteryKwh: 40.0,
        backupHours: '24+ hours',
        uptimeSla: 99.95,
        monthlyPrice: 28999,
        annualPrice: 299500,
        features: [
          'Real-time dashboard access',
          'Carbon footprint tracking',
          'Outage & savings alerts',
          'Support ticketing',
          'Priority 24×7 support',
          'Advanced analytics',
          'Dedicated account manager',
          'Custom SLA agreements',
        ],
        bestFor: [
          'Large hotels',
          'Banquet halls',
          'Big sports complexes',
          'Factories (small-medium)',
          'Colleges (800+ students)',
          'Corporate offices (60+ people)',
        ],
      ),
      const PlanModel(
        id: 'apex',
        name: 'Apex',
        description: 'Custom industrial solution with AI optimization',
        solarKw: 50.0,
        batteryKwh: 80.0,
        backupHours: '24/7 + AI optimization',
        uptimeSla: 99.99,
        monthlyPrice: 0, // Custom pricing
        annualPrice: 0, // Custom pricing
        features: [
          'Real-time dashboard access',
          'Carbon footprint tracking',
          'Outage & savings alerts',
          'Support ticketing',
          'Priority 24×7 support',
          'Advanced analytics',
          'Dedicated account manager',
          'Custom SLA agreements',
          'AI load optimization',
          'Predictive maintenance',
        ],
        bestFor: [
          'Industrial units',
          'Large factories',
          'Industrial parks',
          'Big educational campuses',
          'High-rise buildings',
          'Data centers',
          'Malls',
        ],
      ),
    ];
  }

  // Get recommended plan (Bloom for demo)
  static PlanModel getRecommendedPlan() {
    return getPlans().firstWhere((plan) => plan.isRecommended);
  }

  // Generate mock meter readings for the last 30 days
  static List<MeterReadingModel> getMeterReadings() {
    final now = DateTime.now();
    final readings = <MeterReadingModel>[];
    final random = Random(42); // Fixed seed for consistent data

    for (int i = 29; i >= 0; i--) {
      final timestamp = now.subtract(Duration(days: i));
      
      // Generate realistic data with some variation
      final solarGenerated = 15.0 + random.nextDouble() * 10.0; // 15-25 kWh
      final gridConsumed = 5.0 + random.nextDouble() * 8.0; // 5-13 kWh
      final batteryLevel = 60 + random.nextInt(35); // 60-95%
      final savings = solarGenerated * 10.5; // ₹10.5 per kWh
      final co2Saved = solarGenerated * 0.82; // 0.82 kg CO2 per kWh

      readings.add(MeterReadingModel(
        timestamp: timestamp,
        solarGeneratedKwh: double.parse(solarGenerated.toStringAsFixed(2)),
        gridConsumedKwh: double.parse(gridConsumed.toStringAsFixed(2)),
        batteryLevel: batteryLevel,
        backupActive: random.nextBool() && batteryLevel > 70,
        totalSavingsINR: double.parse(savings.toStringAsFixed(2)),
        co2SavedKg: double.parse(co2Saved.toStringAsFixed(2)),
      ));
    }

    return readings;
  }

  // Generate 24 hourly readings for today (realistic solar bell curve)
  static List<MeterReadingModel> getTodayHourlyReadings() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final random = Random(99); // fixed seed for consistent look
    final readings = <MeterReadingModel>[];

    // Solar output curve: 0 at night, bell-shaped peak ~13:00
    const List<double> solarCurve = [
      0.0, 0.0, 0.0, 0.0, 0.0, 0.0,       // 00–05 night
      0.3, 1.2, 3.5, 6.8, 9.4, 11.6,       // 06–11 morning rise
      13.0, 13.8, 13.2, 12.1, 10.0, 7.5,   // 12–17 peak & afternoon
      4.2, 1.8, 0.5, 0.0, 0.0, 0.0,        // 18–23 evening & night
    ];

    // Grid consumption: higher in morning & evening
    const List<double> gridBase = [
      1.2, 0.9, 0.8, 0.8, 0.9, 1.5,        // 00–05
      2.8, 3.5, 4.2, 3.8, 3.0, 2.5,        // 06–11
      2.2, 2.0, 2.1, 2.4, 2.8, 3.6,        // 12–17
      5.2, 6.8, 5.5, 4.0, 2.8, 1.8,        // 18–23
    ];

    for (int hour = 0; hour < 24; hour++) {
      final timestamp = today.add(Duration(hours: hour));
      final solar = solarCurve[hour] + (random.nextDouble() * 0.6 - 0.3);
      final grid = gridBase[hour] + (random.nextDouble() * 0.4 - 0.2);
      final solarClamped = solar.clamp(0.0, 20.0);
      final gridClamped = grid.clamp(0.0, 15.0);
      final battery = 60 + random.nextInt(35);

      readings.add(MeterReadingModel(
        timestamp: timestamp,
        solarGeneratedKwh: double.parse(solarClamped.toStringAsFixed(2)),
        gridConsumedKwh: double.parse(gridClamped.toStringAsFixed(2)),
        batteryLevel: battery,
        backupActive: false,
        totalSavingsINR: double.parse((solarClamped * 10.5).toStringAsFixed(2)),
        co2SavedKg: double.parse((solarClamped * 0.82).toStringAsFixed(2)),
      ));
    }

    return readings;
  }

  // Get today's stats
  static Map<String, dynamic> getTodayStats() {
    final readings = getMeterReadings();
    final today = readings.last;

    return {
      'todaySavings': today.totalSavingsINR,
      'co2Saved': today.co2SavedKg,
      'batteryLevel': today.batteryLevel,
      'solarGenerated': today.solarGeneratedKwh,
      'gridConsumed': today.gridConsumedKwh,
    };
  }

  // Get monthly totals
  static Map<String, dynamic> getMonthlyStats() {
    final readings = getMeterReadings();
    
    double totalSavings = 0;
    double totalCo2 = 0;
    double totalSolar = 0;
    double totalGrid = 0;

    for (final reading in readings) {
      totalSavings += reading.totalSavingsINR;
      totalCo2 += reading.co2SavedKg;
      totalSolar += reading.solarGeneratedKwh;
      totalGrid += reading.gridConsumedKwh;
    }

    return {
      'totalSavings': double.parse(totalSavings.toStringAsFixed(2)),
      'totalCo2': double.parse(totalCo2.toStringAsFixed(2)),
      'totalSolar': double.parse(totalSolar.toStringAsFixed(2)),
      'totalGrid': double.parse(totalGrid.toStringAsFixed(2)),
      'uptime': 99.7, // Mock uptime
    };
  }

  // Get weekly energy insights
  static List<Map<String, dynamic>> getEnergyInsights() {
    return [
      {
        'title': 'Solar Peak Efficiency',
        'message': 'Your system hit peak efficiency at 1:00 PM yesterday, generating 13.8 kWh.',
        'icon': 'solar',
        'isPositive': true,
      },
      {
        'title': 'Grid Independence',
        'message': 'You used 15% less grid power this week compared to last week.',
        'icon': 'trending_down',
        'isPositive': true,
      },
      {
        'title': 'Battery Health',
        'message': 'Battery charged to 100% cleanly every day. Health remains excellent at 99%.',
        'icon': 'battery',
        'isPositive': true,
      },
      {
        'title': 'Weather Alert',
        'message': 'Cloudy weather expected tomorrow. Grid usage may increase by ~5 kWh.',
        'icon': 'cloud',
        'isPositive': false, // Neutral/alert
      },
    ];
  }

  // Get weather and AI solar prediction for next 3 days
  static List<Map<String, dynamic>> getWeatherAndPrediction() {
    final now = DateTime.now();
    return [
      {
        'date': now.add(const Duration(days: 1)),
        'weather': 'Sunny',
        'tempMax': 32,
        'tempMin': 24,
        'predictedSolarKwh': 18.5,
        'icon': 'sunny',
      },
      {
        'date': now.add(const Duration(days: 2)),
        'weather': 'Partly Cloudy',
        'tempMax': 30,
        'tempMin': 23,
        'predictedSolarKwh': 14.2,
        'icon': 'cloudy',
      },
      {
        'date': now.add(const Duration(days: 3)),
        'weather': 'Rainy',
        'tempMax': 28,
        'tempMin': 22,
        'predictedSolarKwh': 8.5,
        'icon': 'rainy',
      },
    ];
  }
}
