import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:volthive/core/theme/app_colors.dart';
import 'package:volthive/core/theme/app_spacing.dart';
import 'package:volthive/providers/mock_data_provider.dart';
import 'package:intl/intl.dart';

/// Dashboard screen with real-time energy monitoring and charts
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _selectedPeriod = 'Today'; // Today, Weekly, Monthly

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final readings = MockDataProvider.getMeterReadings();
    final todayStats = MockDataProvider.getTodayStats();
    final weatherPredictions = MockDataProvider.getWeatherAndPrediction();
    final energyInsights = MockDataProvider.getEnergyInsights();

    // Data source based on selected period
    final filteredReadings = _selectedPeriod == 'Today'
        ? MockDataProvider.getTodayHourlyReadings()
        : _selectedPeriod == 'Weekly'
            ? readings.sublist(readings.length - 7)
            : readings; // Monthly — all
    final isToday = _selectedPeriod == 'Today';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                // Refresh data
              });
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.delayed(const Duration(seconds: 1));
          setState(() {});
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Real-time Stats
              Text(
                'Real-Time Overview',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),

              const SizedBox(height: AppSpacing.md),

              // Quick stats row
              Row(
                children: [
                  Expanded(
                    child: _buildCompactStat(
                      context,
                      icon: Icons.bolt,
                      label: 'Live Power',
                      value: '${(todayStats['solarGenerated'] / 24).toStringAsFixed(1)} kW',
                      color: AppColors.solarProduction,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _buildCompactStat(
                      context,
                      icon: Icons.battery_charging_full,
                      label: 'Battery',
                      value: '${todayStats['batteryLevel']}%',
                      color: AppColors.batteryTech,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.xl),
              
              _buildEnergyFlowAnimation(context, isDark),
              const SizedBox(height: AppSpacing.md),
              
              _buildWeatherPredictionWidget(context, weatherPredictions, isDark),
              const SizedBox(height: AppSpacing.md),

              const SizedBox(height: AppSpacing.sm),

              // Energy Monitoring Combined Chart
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header row with dropdown
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.bolt,
                                color: AppColors.solarProduction,
                                size: AppSpacing.iconSm,
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Text(
                                'Energy Monitoring',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ],
                          ),
                          // Period dropdown
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedPeriod,
                                isDense: true,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                                items: const [
                                  DropdownMenuItem(value: 'Today', child: Text('Today')),
                                  DropdownMenuItem(value: 'Weekly', child: Text('Weekly')),
                                  DropdownMenuItem(value: 'Monthly', child: Text('Monthly')),
                                ],
                                onChanged: (value) {
                                  if (value != null) setState(() => _selectedPeriod = value);
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      // Legend
                      Row(
                        children: [
                          Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: AppColors.solarProduction.withValues(alpha: 0.3),
                              border: Border.all(color: AppColors.solarProduction, width: 2),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Generation',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.solarProduction,
                                ),
                          ),
                          const SizedBox(width: AppSpacing.lg),
                          Container(
                            width: 14,
                            height: 3,
                            color: AppColors.gridConsumption,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Consumption',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.gridConsumption,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      SizedBox(
                        height: 220,
                        child: LineChart(
                          _buildEnergyMonitoringChart(filteredReadings, isDark, isToday),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.md),
              
              _buildGreenImpactUI(context, filteredReadings, isDark),
              const SizedBox(height: AppSpacing.md),
              
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildEnergyIndependenceChart(context, filteredReadings, isDark)),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              _buildFinancialSavingsChart(context, filteredReadings, isDark, isToday),
              const SizedBox(height: AppSpacing.md),

              // Battery Status Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.battery_std,
                            color: AppColors.batteryTech,
                            size: AppSpacing.iconSm,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            'Battery Status',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      _buildBatteryStatus(context, todayStats['batteryLevel'] as int, isDark),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.md),
              
              _buildEnergyInsights(context, energyInsights, isDark),

              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompactStat(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: Icon(icon, color: color, size: AppSpacing.iconMd),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Custom horizontal battery indicator widget
  Widget _buildBatteryStatus(BuildContext context, int batteryPercent, bool isDark) {
    // Determine color based on charge level
    final Color fillColor = batteryPercent >= 80
        ? AppColors.batteryTech
        : batteryPercent >= 40
            ? const Color(0xFFF59E0B) // amber
            : const Color(0xFFEF4444); // red

    // Determine status label
    final String statusLabel;
    final IconData statusIcon;
    if (batteryPercent >= 95) {
      statusLabel = 'Fully Charged';
      statusIcon = Icons.battery_full;
    } else if (batteryPercent >= 60) {
      statusLabel = 'Charging';
      statusIcon = Icons.battery_charging_full;
    } else if (batteryPercent >= 30) {
      statusLabel = 'Discharging';
      statusIcon = Icons.battery_4_bar;
    } else {
      statusLabel = 'Low Battery';
      statusIcon = Icons.battery_alert;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Percentage + Status row
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '$batteryPercent%',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: fillColor,
                  ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Icon(statusIcon, color: fillColor, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    statusLabel,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: fillColor,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.md),

        // Horizontal battery body
        LayoutBuilder(
          builder: (context, constraints) {
            final totalWidth = constraints.maxWidth - 12; // leave room for terminal nub
            final fillWidth = (totalWidth * batteryPercent / 100).clamp(0.0, totalWidth);
            final bg = isDark ? const Color(0xFF2A2A3A) : const Color(0xFFE5E7EB);

            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Battery shell
                Expanded(
                  child: Container(
                    height: 36,
                    decoration: BoxDecoration(
                      color: bg,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: fillColor.withValues(alpha: 0.5),
                        width: 2,
                      ),
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: Stack(
                      children: [
                        // Fill bar
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 600),
                          curve: Curves.easeOut,
                          width: fillWidth,
                          height: 36,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                fillColor.withValues(alpha: 0.85),
                                fillColor,
                              ],
                            ),
                          ),
                        ),
                        // Percentage label inside bar
                        Center(
                          child: Text(
                            '$batteryPercent%',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: batteryPercent > 20
                                  ? Colors.white
                                  : (isDark ? Colors.white70 : Colors.black54),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Battery terminal (positive nub)
                const SizedBox(width: 3),
                Container(
                  width: 9,
                  height: 18,
                  decoration: BoxDecoration(
                    color: fillColor.withValues(alpha: 0.7),
                    borderRadius: const BorderRadius.horizontal(
                      right: Radius.circular(3),
                    ),
                  ),
                ),
              ],
            );
          },
        ),

        const SizedBox(height: AppSpacing.md),

        // Sub-info row
        Row(
          children: [
            _batteryInfoChip(
              context,
              icon: Icons.solar_power,
              label: 'Solar Input',
              value: batteryPercent >= 60 ? 'Active' : 'Low',
              color: AppColors.solarProduction,
              isDark: isDark,
            ),
            const SizedBox(width: AppSpacing.sm),
            _batteryInfoChip(
              context,
              icon: Icons.home,
              label: 'Home Load',
              value: 'Normal',
              color: AppColors.gridConsumption,
              isDark: isDark,
            ),
          ],
        ),
      ],
    );
  }

  Widget _batteryInfoChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required bool isDark,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(fontSize: 10, color: isDark ? Colors.white54 : Colors.black45)),
                Text(value,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(fontWeight: FontWeight.w600, color: color)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  LineChartData _buildEnergyMonitoringChart(List readings, bool isDark, bool isToday) {
    final solarSpots = readings
        .asMap()
        .entries
        .map((entry) => FlSpot(
              entry.key.toDouble(),
              entry.value.solarGeneratedKwh,
            ))
        .toList();

    final gridSpots = readings
        .asMap()
        .entries
        .map((entry) => FlSpot(
              entry.key.toDouble(),
              entry.value.gridConsumedKwh,
            ))
        .toList();

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: 5,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: isDark ? AppColors.chartGrid : AppColors.lightDivider,
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 42,
            interval: isToday ? 6 : (readings.length > 7 ? 5 : 1),
            getTitlesWidget: (value, meta) {
              if (value.toInt() >= readings.length) return const Text('');
              final date = readings[value.toInt()].timestamp;
              return Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  isToday
                      ? DateFormat('ha').format(date)  // e.g. 6am, 12pm
                      : DateFormat('d').format(date),  // day number
                  style: TextStyle(
                    fontSize: 10,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
              );
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            interval: 10,
            getTitlesWidget: (value, meta) {
              return Text(
                '${value.toInt()}',
                style: TextStyle(
                  fontSize: 10,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      minX: 0,
      maxX: (readings.length - 1).toDouble(),
      minY: 0,
      maxY: 30,
      lineTouchData: LineTouchData(
        handleBuiltInTouches: true,
        touchTooltipData: LineTouchTooltipData(
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((spot) {
              final isSolar = spot.barIndex == 0;
              return LineTooltipItem(
                '${spot.y.toStringAsFixed(1)} kWh',
                TextStyle(
                  color: isSolar ? AppColors.solarProduction : AppColors.gridConsumption,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              );
            }).toList();
          },
        ),
        // Keep touched dot the SAME size as the resting dot — no grow effect
        getTouchedSpotIndicator: (barData, spotIndexes) {
          return spotIndexes.map((index) {
            final isGrid = barData.color == AppColors.gridConsumption;
            final dotColor = isGrid ? AppColors.gridConsumption : AppColors.solarProduction;
            return TouchedSpotIndicatorData(
              const FlLine(strokeWidth: 0, color: Colors.transparent), // no vertical line
              FlDotData(
                show: true,
                getDotPainter: (spot, percent, bar, idx) => FlDotCirclePainter(
                  radius: 2.5,
                  color: dotColor,
                  strokeWidth: 0,
                  strokeColor: Colors.transparent,
                ),
              ),
            );
          }).toList();
        },
      ),
      lineBarsData: [
        // Solar Generation — orange, area shaded, small dots
        LineChartBarData(
          spots: solarSpots,
          isCurved: true,
          color: AppColors.solarProduction,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
              radius: 2.5,
              color: AppColors.solarProduction,
              strokeWidth: 0,
              strokeColor: Colors.transparent,
            ),
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                AppColors.solarProduction.withValues(alpha: 0.25),
                AppColors.solarProduction.withValues(alpha: 0.0),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        // Grid Consumption — blue line with small dots
        LineChartBarData(
          spots: gridSpots,
          isCurved: true,
          color: AppColors.gridConsumption,
          barWidth: 2,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
              radius: 2.5,
              color: AppColors.gridConsumption,
              strokeWidth: 0,
              strokeColor: Colors.transparent,
            ),
          ),
          belowBarData: BarAreaData(show: false),
        ),
      ],
    );
  }

  Widget _buildEnergyFlowAnimation(BuildContext context, bool isDark) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Live Power Flow',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildFlowNode(context, Icons.solar_power, 'Solar', AppColors.solarProduction),
                _buildFlowArrow(context, AppColors.solarProduction),
                _buildFlowNode(context, Icons.home, 'Home', isDark ? Colors.white : Colors.black),
                _buildFlowArrow(context, AppColors.batteryTech),
                _buildFlowNode(context, Icons.battery_charging_full, 'Battery', AppColors.batteryTech),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFlowNode(BuildContext context, IconData icon, String label, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: 0.1),
            border: Border.all(color: color.withValues(alpha: 0.5), width: 2),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: 8),
        Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildFlowArrow(BuildContext context, Color color) {
    return Expanded(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            height: 2,
            color: color.withValues(alpha: 0.3),
          ),
          Icon(Icons.arrow_forward, color: color, size: 16),
        ],
      ),
    );
  }

  Widget _buildWeatherPredictionWidget(BuildContext context, List<Map<String, dynamic>> predictions, bool isDark) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.auto_awesome, color: AppColors.primary, size: AppSpacing.iconSm),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'AI Solar Prediction',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: predictions.map((p) {
                return _buildWeatherDay(context, p, isDark);
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherDay(BuildContext context, Map<String, dynamic> p, bool isDark) {
    final date = p['date'] as DateTime;
    final isTomorrow = date.day == DateTime.now().add(const Duration(days: 1)).day;
    final dayName = isTomorrow ? 'Tomorrow' : DateFormat('EEE').format(date);
    
    IconData icon;
    if (p['icon'] == 'sunny') {
      icon = Icons.wb_sunny;
    } else if (p['icon'] == 'cloudy') {
      icon = Icons.cloud;
    } else {
      icon = Icons.water_drop;
    }

    return Column(
      children: [
        Text(dayName, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 4),
        Icon(icon, color: p['icon'] == 'sunny' ? Colors.orange : Colors.grey, size: 28),
        const SizedBox(height: 8),
        Text('${p['tempMax']}° / ${p['tempMin']}°', style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 4),
        Text(
          '~${p['predictedSolarKwh']} kWh',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.solarProduction,
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  Widget _buildEnergyIndependenceChart(BuildContext context, List readings, bool isDark) {
    double totalSolar = 0;
    double totalGrid = 0;
    for (var r in readings) {
      totalSolar += r.solarGeneratedKwh;
      totalGrid += r.gridConsumedKwh;
    }
    
    final total = totalSolar + totalGrid;
    final solarPercent = total == 0 ? 0 : (totalSolar / total) * 100;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Energy Independence',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              height: 180,
              child: Stack(
                children: [
                  PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 60,
                      startDegreeOffset: -90,
                      sections: [
                        PieChartSectionData(
                          color: AppColors.solarProduction,
                          value: totalSolar,
                          title: '',
                          radius: 20,
                        ),
                        PieChartSectionData(
                          color: AppColors.gridConsumption,
                          value: totalGrid,
                          title: '',
                          radius: 15,
                        ),
                      ],
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${solarPercent.toStringAsFixed(0)}%',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.solarProduction,
                              ),
                        ),
                        Text(
                          'Solar Powered',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem(context, 'Solar (${totalSolar.toStringAsFixed(1)} kWh)', AppColors.solarProduction),
                const SizedBox(width: AppSpacing.lg),
                _buildLegendItem(context, 'Grid (${totalGrid.toStringAsFixed(1)} kWh)', AppColors.gridConsumption),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(BuildContext context, String label, Color color) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  Widget _buildFinancialSavingsChart(BuildContext context, List readings, bool isDark, bool isToday) {
    if (readings.isEmpty) return const SizedBox.shrink();
    
    final barGroups = readings.asMap().entries.map((entry) {
      return BarChartGroupData(
        x: entry.key,
        barRods: [
          BarChartRodData(
            toY: entry.value.totalSavingsINR,
            color: AppColors.success,
            width: isToday ? 8 : (readings.length > 7 ? 4 : 12),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ],
      );
    }).toList();

    double totalSavings = 0;
    for (var r in readings) totalSavings += r.totalSavingsINR;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Financial Savings',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                Text(
                  '₹${totalSavings.toStringAsFixed(0)}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.success,
                      ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              height: 150,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: isToday ? 250 : 300,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= readings.length || value.toInt() < 0) return const Text('');
                          if (isToday && value.toInt() % 6 != 0) return const Text(''); // Show every 6 hours today
                          if (!isToday && readings.length > 7 && value.toInt() % 5 != 0) return const Text(''); // Distribute
                          
                          final date = readings[value.toInt()].timestamp;
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              isToday ? DateFormat('ha').format(date) : DateFormat('d').format(date),
                              style: TextStyle(
                                fontSize: 10,
                                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: barGroups,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGreenImpactUI(BuildContext context, List readings, bool isDark) {
    double totalCo2 = 0;
    for (var r in readings) totalCo2 += r.co2SavedKg;
    
    // Approx calculations: 1 tree absorbs ~21kg CO2 per year (so maybe 1 tree per 20kg for visual).
    int treesPlanted = (totalCo2 / 20).floor();
    if (treesPlanted < 1 && totalCo2 > 0) treesPlanted = 1;

    return Card(
      color: isDark ? const Color(0xFF1E3A2F) : const Color(0xFFE8F5E9),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.park, color: Colors.green, size: 32),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Green Impact',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    '${totalCo2.toStringAsFixed(1)} kg CO₂ avoided',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    'Equivalent to $treesPlanted trees planted!',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnergyInsights(BuildContext context, List<Map<String, dynamic>> insights, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Text(
            'Weekly Insights',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          height: 130,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: insights.length,
            itemBuilder: (context, index) {
              final insight = insights[index];
              return Container(
                width: 260,
                margin: const EdgeInsets.only(right: AppSpacing.md),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              _getInsightIcon(insight['icon']),
                              color: insight['isPositive'] ? AppColors.success : Colors.amber,
                              size: 18,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Text(
                              insight['title'],
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            insight['message'],
                            style: Theme.of(context).textTheme.bodySmall,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  IconData _getInsightIcon(String iconStr) {
    switch (iconStr) {
      case 'solar': return Icons.wb_sunny;
      case 'trending_down': return Icons.trending_down;
      case 'battery': return Icons.battery_charging_full;
      case 'cloud': return Icons.cloud;
      default: return Icons.info_outline;
    }
  }
}

