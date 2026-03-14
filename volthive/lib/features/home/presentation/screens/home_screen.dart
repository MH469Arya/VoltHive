import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:volthive/core/theme/app_colors.dart';
import 'package:volthive/core/theme/app_spacing.dart';
import 'package:volthive/core/widgets/stat_card.dart';
import 'package:volthive/providers/mock_data_provider.dart';
import 'package:volthive/providers/auth_provider.dart';
import 'package:volthive/services/fcm_service.dart';

/// Home screen with quick stats and energy overview
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key, required this.onNavigateToPlans});

  final VoidCallback onNavigateToPlans;

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

/// Simple model for a notification item
class _NotificationItem {
  final String title;
  final String message;
  final String time;
  final IconData icon;
  final Color color;
  bool isRead;

  _NotificationItem({
    required this.title,
    required this.message,
    required this.time,
    required this.icon,
    required this.color,
    this.isRead = false,
  });
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final GlobalKey _profileIconKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // Hook into FCM foreground messages
    FcmService.onForegroundMessage = (RemoteMessage message) {
      if (!mounted) return;
      final notification = message.notification;
      if (notification == null) return;

      // Add to notifications panel
      setState(() {
        _notifications.insert(
          0,
          _NotificationItem(
            title: notification.title ?? 'VoltHive Alert',
            message: notification.body ?? '',
            time: 'Just now',
            icon: _iconForType(message.data['type']),
            color: _colorForType(message.data['type']),
          ),
        );
      });

      // Show in-app banner
      _showFcmBanner(
        title: notification.title ?? 'VoltHive Alert',
        body: notification.body ?? '',
        type: message.data['type'],
      );
    };
  }

  @override
  void dispose() {
    FcmService.onForegroundMessage = null;
    super.dispose();
  }

  IconData _iconForType(String? type) {
    switch (type) {
      case 'batteryAlert': return Icons.battery_alert;
      case 'billReady': return Icons.receipt_long_outlined;
      case 'paymentSuccess': return Icons.check_circle_outline;
      case 'gridOutage': return Icons.power_off_outlined;
      default: return Icons.notifications_outlined;
    }
  }

  Color _colorForType(String? type) {
    switch (type) {
      case 'batteryAlert': return const Color(0xFFEF4444);
      case 'billReady': return const Color(0xFF8B5CF6);
      case 'paymentSuccess': return const Color(0xFF10B981);
      case 'gridOutage': return const Color(0xFF3B82F6);
      default: return AppColors.primary;
    }
  }

  void _showFcmBanner({
    required String title,
    required String body,
    String? type,
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => Positioned(
        top: MediaQuery.of(context).padding.top + 8,
        left: 16,
        right: 16,
        child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _colorForType(type),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(_iconForType(type), color: Colors.white, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(title,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14)),
                      if (body.isNotEmpty)
                        Text(body,
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 12),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => entry.remove(),
                  child: const Icon(Icons.close, color: Colors.white70, size: 18),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    overlay.insert(entry);
    // Auto-dismiss after 4 seconds
    Future.delayed(const Duration(seconds: 4), () {
      if (entry.mounted) entry.remove();
    });
  }

  final List<_NotificationItem> _notifications = [
    _NotificationItem(
      title: 'Peak Solar Generation',
      message: 'Your system hit a record 8.4 kW output today at 1:02 PM.',
      time: '2 min ago',
      icon: Icons.wb_sunny,
      color: Color(0xFFF59E0B),
    ),
    _NotificationItem(
      title: 'Battery at 70%',
      message: 'Battery storage is comfortably charged. No grid draw needed.',
      time: '18 min ago',
      icon: Icons.battery_charging_full,
      color: Color(0xFF10B981),
    ),
    _NotificationItem(
      title: 'Grid Switched Off',
      message: 'Running fully on solar + battery. Estimated 6 hrs of backup.',
      time: '1 hr ago',
      icon: Icons.power_off_outlined,
      color: Color(0xFF3B82F6),
    ),
    _NotificationItem(
      title: 'Low Battery Warning',
      message: 'Battery dropped below 20%. Grid will kick in automatically.',
      time: '3 hrs ago',
      icon: Icons.battery_alert,
      color: Color(0xFFEF4444),
      isRead: true,
    ),
    _NotificationItem(
      title: 'Monthly Bill Ready',
      message: 'Your bill for January is ₹1,840. Tap to view details.',
      time: 'Yesterday',
      icon: Icons.receipt_long_outlined,
      color: Color(0xFF8B5CF6),
      isRead: true,
    ),
    _NotificationItem(
      title: 'CO₂ Milestone Reached',
      message: 'You\'ve prevented 100 kg of CO₂ this month. 🌱 Great work!',
      time: '2 days ago',
      icon: Icons.eco_outlined,
      color: Color(0xFF10B981),
      isRead: true,
    ),
  ];

  int get _unreadCount => _notifications.where((n) => !n.isRead).length;

  void _showNotificationsPanel() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final bgColor = isDark
              ? const Color(0xFF1E293B)
              : Colors.white;
          final textSecondary = isDark
              ? const Color(0xFF94A3B8)
              : const Color(0xFF64748B);

          return Container(
            height: MediaQuery.of(context).size.height * 0.75,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                // Drag handle
                Container(
                  margin: const EdgeInsets.only(top: 10),
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: textSecondary.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 12, 0),
                  child: Row(
                    children: [
                      Text(
                        'Notifications',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? const Color(0xFFF8FAFC)
                              : const Color(0xFF0F172A),
                        ),
                      ),
                      if (_notifications.any((n) => !n.isRead))
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981)
                                .withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${_notifications.where((n) => !n.isRead).length} new',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF10B981),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            for (final n in _notifications) {
                              n.isRead = true;
                            }
                          });
                          setSheetState(() {});
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF10B981),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          textStyle: const TextStyle(fontSize: 13),
                        ),
                        child: const Text('Mark all read'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                const Divider(height: 1, indent: 20, endIndent: 20),
                // Notification list
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: _notifications.length,
                    separatorBuilder: (_, index) => const Divider(
                        height: 1, indent: 72, endIndent: 20),
                    itemBuilder: (context, index) {
                      final notif = _notifications[index];
                      return InkWell(
                        onTap: () {
                          setState(() => notif.isRead = true);
                          setSheetState(() {});
                        },
                        child: Container(
                          color: notif.isRead
                              ? Colors.transparent
                              : notif.color.withValues(alpha: isDark ? 0.06 : 0.04),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 14),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Icon circle
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: notif.color.withValues(alpha: 0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(notif.icon,
                                    color: notif.color, size: 20),
                              ),
                              const SizedBox(width: 12),
                              // Text block
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            notif.title,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: notif.isRead
                                                  ? FontWeight.w500
                                                  : FontWeight.w700,
                                              color: isDark
                                                  ? const Color(0xFFF8FAFC)
                                                  : const Color(0xFF0F172A),
                                            ),
                                          ),
                                        ),
                                        if (!notif.isRead)
                                          Container(
                                            width: 8,
                                            height: 8,
                                            margin: const EdgeInsets.only(
                                                left: 6, top: 2),
                                            decoration: BoxDecoration(
                                              color: notif.color,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      notif.message,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: textSecondary,
                                        height: 1.4,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      notif.time,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: textSecondary
                                            .withValues(alpha: 0.7),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showProfileMenu() {
    final RenderBox renderBox =
        _profileIconKey.currentContext!.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    final Size size = renderBox.size;

    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy + size.height,
        offset.dx + size.width,
        offset.dy + size.height + 4,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      elevation: 8,
      items: [
        PopupMenuItem<String>(
          value: 'profile',
          child: Row(
            children: [
              Icon(Icons.person_outline,
                  color: AppColors.primary, size: AppSpacing.iconMd),
              const SizedBox(width: AppSpacing.sm),
              const Text('My Profile'),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'plan',
          child: Row(
            children: [
              Icon(Icons.layers_outlined,
                  color: AppColors.primary, size: AppSpacing.iconMd),
              const SizedBox(width: AppSpacing.sm),
              const Text('My Plan'),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem<String>(
          value: 'logout',
          child: Row(
            children: [
              Icon(Icons.logout, color: Colors.redAccent, size: AppSpacing.iconMd),
              const SizedBox(width: AppSpacing.sm),
              const Text('Logout',
                  style: TextStyle(color: Colors.redAccent)),
            ],
          ),
        ),
      ],
    ).then((value) async {
      if (value == null) return;
      if (!mounted) return;
      switch (value) {
        case 'profile':
          _showProfileDialog();
          break;
        case 'plan':
          _showPlanDialog();
          break;
        case 'logout':
          await ref.read(authProvider.notifier).logout();
          if (mounted) context.go('/login');
          break;
      }
    });
  }

  void _showProfileDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        title: const Row(
          children: [
            Icon(Icons.person, color: AppColors.primary),
            SizedBox(width: AppSpacing.sm),
            Text('My Profile'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _profileRow(Icons.badge_outlined, 'Name', 'Rahul Sharma'),
            const SizedBox(height: AppSpacing.sm),
            _profileRow(Icons.email_outlined, 'Email', 'rahul@example.com'),
            const SizedBox(height: AppSpacing.sm),
            _profileRow(Icons.phone_outlined, 'Phone', '+91 90000 00000'),
            const SizedBox(height: AppSpacing.sm),
            _profileRow(Icons.location_on_outlined, 'Location', 'Mumbai, MH'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _profileRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: AppSpacing.sm),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(fontSize: 11, color: Colors.grey)),
            Text(value,
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w500)),
          ],
        )
      ],
    );
  }

  void _showPlanDialog() {
    final plan = MockDataProvider.getRecommendedPlan();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        title: const Row(
          children: [
            Icon(Icons.layers, color: AppColors.primary),
            SizedBox(width: AppSpacing.sm),
            Text('My Plan'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: Text('ACTIVE',
                  style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 11)),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(plan.name,
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: AppSpacing.xs),
            Text(plan.description, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _planStat(
                    Icons.wb_sunny, '${plan.solarKw} kW', AppColors.solarProduction),
                _planStat(Icons.battery_charging_full,
                    '${plan.batteryKwh} kWh', AppColors.batteryTech),
                _planStat(Icons.schedule, plan.backupHours,
                    AppColors.gridConsumption),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Monthly', style: TextStyle(color: Colors.grey)),
                Text('₹${plan.monthlyPrice}/mo',
                    style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _planStat(IconData icon, String value, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(
                color: color, fontWeight: FontWeight.w600, fontSize: 13)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = ref.watch(authProvider);
    final todayStats = MockDataProvider.getTodayStats();
    final monthlyStats = MockDataProvider.getMonthlyStats();
    final recommendedPlan = MockDataProvider.getRecommendedPlan();

    final hour = DateTime.now().hour;
    String greeting = 'Good Evening';
    if (hour < 12) {
      greeting = 'Good Morning';
    } else if (hour < 17) {
      greeting = 'Good Afternoon';
    }

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('VoltHive'),
            Text(
              '$greeting, ${user?.name ?? 'User'}!',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
            ),
          ],
        ),
        actions: [
          Stack(
            alignment: Alignment.topRight,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: _showNotificationsPanel,
              ),
              if (_unreadCount > 0)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEF4444),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '$_unreadCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            key: _profileIconKey,
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: _showProfileMenu,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // TODO: Refresh data
          await Future.delayed(const Duration(seconds: 1));
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Quick Stats Section
              Text(
                'Today\'s Overview',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),

              const SizedBox(height: AppSpacing.md),

              // Stats Grid
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: AppSpacing.md,
                crossAxisSpacing: AppSpacing.md,
                childAspectRatio: 1.25, // Slightly increased height to prevent overflow
                children: [
                  StatCard(
                    title: 'Today\'s Savings',
                    value: formatCurrency(todayStats['todaySavings']),
                    subtitle: '+${formatNumber(todayStats['todaySavings'] / monthlyStats['totalSavings'] * 100, decimals: 0)}% of monthly',
                    icon: Icons.savings_outlined,
                    iconColor: AppColors.primary,
                  ),
                  StatCard(
                    title: 'CO₂ Saved',
                    value: '${formatNumber(todayStats['co2Saved'])} kg',
                    subtitle: '🌱 ${(todayStats['co2Saved'] / 21.77).toStringAsFixed(1)} trees',
                    icon: Icons.eco_outlined,
                    iconColor: AppColors.primary,
                  ),
                  StatCard(
                    title: 'Battery Level',
                    value: '${todayStats['batteryLevel']}%',
                    subtitle: todayStats['batteryLevel'] > 70 ? 'Healthy' : 'Low',
                    icon: Icons.battery_charging_full,
                    iconColor: todayStats['batteryLevel'] > 70
                        ? AppColors.batteryTech
                        : AppColors.error,
                  ),
                  StatCard(
                    title: 'Solar Generated',
                    value: '${formatNumber(todayStats['solarGenerated'])} kWh',
                    subtitle: 'Grid: ${formatNumber(todayStats['gridConsumed'])} kWh',
                    icon: Icons.wb_sunny,
                    iconColor: AppColors.solarProduction,
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.xl),

              // Recommended Plan Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Your Plan',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: widget.onNavigateToPlans,
                    child: const Text('View All Plans'),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.md),

              // Recommended Plan Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Plan badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                        ),
                        child: Text(
                          'CURRENT PLAN',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),

                      const SizedBox(height: AppSpacing.md),

                      // Plan name
                      Text(
                        recommendedPlan.name,
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),

                      const SizedBox(height: AppSpacing.xs),

                      // Plan description
                      Text(
                        recommendedPlan.description,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                            ),
                      ),

                      const SizedBox(height: AppSpacing.lg),

                      // Plan specs
                      Row(
                        children: [
                          Expanded(
                            child: _buildPlanSpec(
                              context,
                              icon: Icons.wb_sunny,
                              label: 'Solar',
                              value: '${recommendedPlan.solarKw} kW',
                              color: AppColors.solarProduction,
                            ),
                          ),
                          Expanded(
                            child: _buildPlanSpec(
                              context,
                              icon: Icons.battery_charging_full,
                              label: 'Battery',
                              value: '${recommendedPlan.batteryKwh} kWh',
                              color: AppColors.batteryTech,
                            ),
                          ),
                          Expanded(
                            child: _buildPlanSpec(
                              context,
                              icon: Icons.schedule,
                              label: 'Backup',
                              value: recommendedPlan.backupHours,
                              color: AppColors.gridConsumption,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: AppSpacing.lg),

                      // Monthly price
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Monthly Subscription',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: isDark
                                          ? AppColors.darkTextSecondary
                                          : AppColors.lightTextSecondary,
                                    ),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                formatCurrency(recommendedPlan.monthlyPrice.toDouble()),
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                              ),
                            ],
                          ),
                          OutlinedButton(
                            onPressed: widget.onNavigateToPlans,
                            child: const Text('Manage'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Monthly Summary Section
              Text(
                'This Month',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),

              const SizedBox(height: AppSpacing.md),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    children: [
                      _buildMonthlyStat(
                        context,
                        icon: Icons.savings,
                        label: 'Total Savings',
                        value: formatCurrency(monthlyStats['totalSavings']),
                        color: AppColors.primary,
                      ),
                      const Divider(height: AppSpacing.lg),
                      _buildMonthlyStat(
                        context,
                        icon: Icons.eco,
                        label: 'CO₂ Reduced',
                        value: '${formatNumber(monthlyStats['totalCo2'])} kg',
                        color: AppColors.primary,
                      ),
                      const Divider(height: AppSpacing.lg),
                      _buildMonthlyStat(
                        context,
                        icon: Icons.wb_sunny,
                        label: 'Solar Generated',
                        value: '${formatNumber(monthlyStats['totalSolar'])} kWh',
                        color: AppColors.solarProduction,
                      ),
                      const Divider(height: AppSpacing.lg),
                      _buildMonthlyStat(
                        context,
                        icon: Icons.check_circle,
                        label: 'Uptime',
                        value: '${monthlyStats['uptime']}%',
                        color: AppColors.batteryTech,
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }



  Widget _buildPlanSpec(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: AppSpacing.iconMd),
        const SizedBox(height: AppSpacing.xs),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildMonthlyStat(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          ),
          child: Icon(icon, color: color, size: AppSpacing.iconMd),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }
}
