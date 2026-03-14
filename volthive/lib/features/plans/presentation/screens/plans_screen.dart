import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:volthive/core/theme/app_colors.dart';
import 'package:volthive/core/theme/app_spacing.dart';
import 'package:volthive/core/widgets/custom_button.dart';
import 'package:volthive/core/widgets/stat_card.dart';
import 'package:volthive/features/plans/data/models/plan_model.dart';
import 'package:volthive/features/payment/models/payment_result.dart';
import 'package:volthive/features/payment/presentation/screens/payment_sheet.dart';
import 'package:volthive/providers/auth_provider.dart';
import 'package:volthive/providers/mock_data_provider.dart';

/// Plans screen – user-aware:
///   Rahul  → current plan highlighted, others show "Select Plan"
///   Sarth  → first-time banner, all plans show active "Select Plan" buttons
class PlansScreen extends ConsumerStatefulWidget {
  const PlansScreen({super.key});

  @override
  ConsumerState<PlansScreen> createState() => _PlansScreenState();
}

class _PlansScreenState extends ConsumerState<PlansScreen> {
  bool _showAnnual = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final plans = MockDataProvider.getPlans();
    final user = ref.watch(currentUserProvider);
    final hasActivePlan = user?.hasActivePlan ?? false;
    final activePlanId = user?.activePlanId;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscription Plans'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // First-time user banner (Sarth)
            if (!hasActivePlan) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: AppColors.primary),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        'Get started — choose a plan to activate your service.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],

            // Header
            Text(
              'Choose Your Plan',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),

            const SizedBox(height: AppSpacing.sm),

            Text(
              'Select the perfect energy solution for your needs',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Monthly / Annual Toggle
            Center(
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildToggleButton(
                      context,
                      'Monthly',
                      !_showAnnual,
                      () => setState(() => _showAnnual = false),
                    ),
                    _buildToggleButton(
                      context,
                      'Annual (Save 13%)',
                      _showAnnual,
                      () => setState(() => _showAnnual = true),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            // Plan cards
            ...plans.map((plan) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: _buildPlanCard(
                    context,
                    plan,
                    isDark,
                    activePlanId: activePlanId,
                    hasActivePlan: hasActivePlan,
                  ),
                )),

            // PAYG Option
            const SizedBox(height: AppSpacing.md),
            _buildPaygCard(context, isDark),

            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleButton(
    BuildContext context,
    String label,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isSelected
                    ? Colors.white
                    : Theme.of(context).textTheme.bodyMedium?.color,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
        ),
      ),
    );
  }

  Widget _buildPlanCard(
    BuildContext context,
    PlanModel plan,
    bool isDark, {
    required String? activePlanId,
    required bool hasActivePlan,
  }) {
    final price = _showAnnual ? plan.annualPrice : plan.monthlyPrice;
    final isApex = plan.id == 'apex';
    final isCurrentPlan = hasActivePlan && plan.id == activePlanId;

    return Card(
      child: Container(
        decoration: isCurrentPlan
            ? BoxDecoration(
                border: Border.all(color: AppColors.primary, width: 2),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              )
            : null,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Plan Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          plan.name,
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          plan.description,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  if (isCurrentPlan)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                      ),
                      child: Text(
                        'CURRENT PLAN',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    )
                  else if (plan.isRecommended && !hasActivePlan)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                      ),
                      child: Text(
                        'RECOMMENDED',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: AppSpacing.lg),

              // Plan Specs
              Row(
                children: [
                  Expanded(
                    child: _buildSpec(
                      context,
                      Icons.wb_sunny,
                      '${plan.solarKw} kW',
                      'Solar',
                      AppColors.solarProduction,
                    ),
                  ),
                  Expanded(
                    child: _buildSpec(
                      context,
                      Icons.battery_charging_full,
                      '${plan.batteryKwh} kWh',
                      'Battery',
                      AppColors.batteryTech,
                    ),
                  ),
                  Expanded(
                    child: _buildSpec(
                      context,
                      Icons.schedule,
                      plan.backupHours,
                      'Backup',
                      AppColors.gridConsumption,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.lg),

              // Features
              Text(
                'Features:',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),

              const SizedBox(height: AppSpacing.sm),

              ...plan.features.take(3).map((feature) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Expanded(
                          child: Text(
                            feature,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  )),

              if (plan.features.length > 3)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.xs),
                  child: Text(
                    '+${plan.features.length - 3} more features',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ),

              const SizedBox(height: AppSpacing.lg),

              // Price and CTA
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!isApex) ...[
                        Text(
                          formatCurrency(price.toDouble()),
                          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                        ),
                        Text(
                          _showAnnual ? '/year' : '/month',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary,
                              ),
                        ),
                      ] else
                        Text(
                          'Custom Pricing',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                        ),
                    ],
                  ),
                  CustomButton(
                    text: isCurrentPlan ? 'Current Plan' : 'Select Plan',
                    onPressed: isCurrentPlan
                        ? null
                        : () async {
                            final price = (_showAnnual
                                    ? plan.annualPrice
                                    : plan.monthlyPrice)
                                .toDouble();
                            final result = await showPaymentSheet(
                              context,
                              amountInRupees: price,
                              planName: plan.name,
                            );
                            if (result != null &&
                                result.status == PaymentStatus.success) {
                              await ref
                                  .read(authProvider.notifier)
                                  .confirmPayment(plan.id);
                            }
                          },
                    type: isCurrentPlan ? ButtonType.secondary : ButtonType.primary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpec(
    BuildContext context,
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: AppSpacing.iconMd),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
          textAlign: TextAlign.center,
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildPaygCard(BuildContext context, bool isDark) {
    return Card(
      color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  child: const Icon(
                    Icons.payments,
                    color: AppColors.primary,
                    size: AppSpacing.iconMd,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pay-As-You-Go',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'No subscription needed. Pay only for what you use.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.md),

            Row(
              children: [
                const Icon(Icons.check_circle, size: 16, color: AppColors.primary),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  '₹12/kWh for solar energy',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.xs),

            Row(
              children: [
                const Icon(Icons.check_circle, size: 16, color: AppColors.primary),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  'No monthly commitment',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.md),

            CustomButton(
              text: 'Learn More',
              onPressed: () {},
              type: ButtonType.secondary,
              width: double.infinity,
            ),
          ],
        ),
      ),
    );
  }
}
