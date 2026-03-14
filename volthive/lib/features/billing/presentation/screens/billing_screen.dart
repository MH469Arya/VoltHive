import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:volthive/core/theme/app_colors.dart';
import 'package:volthive/core/theme/app_spacing.dart';
import 'package:volthive/core/widgets/custom_button.dart';
import 'package:volthive/features/billing/data/models/invoice_model.dart';
import 'package:volthive/core/widgets/stat_card.dart';
import 'package:volthive/features/payment/models/payment_result.dart';
import 'package:volthive/features/payment/presentation/screens/payment_sheet.dart';
import 'package:volthive/providers/auth_provider.dart';
import 'package:volthive/services/firestore_service.dart';
import 'package:volthive/services/invoice_pdf_service.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

/// Billing screen — user-aware.
/// Rahul (hasActivePlan: true)  → full billing UI with seeded history + PDF download
/// Sarth (hasActivePlan: false) → "No Active Plan" empty state
/// Sarth (hasActivePlan: true)  → billing view with Firestore invoice stream
class BillingScreen extends ConsumerStatefulWidget {
  final VoidCallback? onNavigateToPlans;

  const BillingScreen({super.key, this.onNavigateToPlans});

  @override
  ConsumerState<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends ConsumerState<BillingScreen> {
  // Track per-invoice loading state to show spinner while generating PDF
  final Map<String, bool> _pdfLoading = {};

  // ─── Helpers ────────────────────────────────────────────────────────────────

  String _getPlanDisplayName(String? planId) {
    const names = {
      'spark': 'Spark', 'bloom': 'Bloom', 'thrive': 'Thrive',
      'surge': 'Surge', 'forge': 'Forge', 'apex': 'Apex',
    };
    return names[planId] ?? 'Custom';
  }

  double _getPlanPrice(String? planId) {
    const prices = {
      'spark': 3999.0, 'bloom': 6799.0, 'thrive': 11999.0,
      'surge': 17999.0, 'forge': 28999.0, 'apex': 0.0,
    };
    return prices[planId] ?? 0.0;
  }

  Future<void> _downloadInvoice(InvoiceModel invoice, UserModel user) async {
    setState(() => _pdfLoading[invoice.id] = true);
    try {
      await InvoicePdfService.sharePdf(
        invoice: invoice,
        userName: user.name,
        userEmail: user.email,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Could not generate PDF: $e'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ));
      }
    } finally {
      if (mounted) setState(() => _pdfLoading[invoice.id] = false);
    }
  }

  Future<void> _downloadAllInvoices(
      List<InvoiceModel> invoices, UserModel user) async {
    for (final inv in invoices) {
      await _downloadInvoice(inv, user);
    }
  }

  // ─── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = ref.watch(currentUserProvider);
    final hasActivePlan = user?.hasActivePlan ?? false;

    return Scaffold(
      appBar: AppBar(title: const Text('Billing')),
      body: hasActivePlan
          ? _buildActiveBillingView(context, isDark, user!)
          : _buildNoPlanView(context, isDark),
    );
  }

  // ─── No plan state (Sarth before choosing a plan) ───────────────────────────
  Widget _buildNoPlanView(BuildContext context, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.receipt_long_outlined,
                size: 64,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'No Active Plan',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'You don\'t have an active subscription yet. Choose a plan to activate your energy service and start monitoring your usage.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            CustomButton(
              text: 'Choose a Plan',
              onPressed: () => widget.onNavigateToPlans?.call(),
              type: ButtonType.primary,
              width: double.infinity,
            ),
          ],
        ),
      ),
    );
  }

  // ─── Full billing view ──────────────────────────────────────────────────────
  Widget _buildActiveBillingView(
      BuildContext context, bool isDark, UserModel user) {
    final planName = _getPlanDisplayName(user.activePlanId);
    final isRahul = user.email.toLowerCase() == 'rahul@gmail.com';

    // Rahul uses seeded invoices; Sarth streams Firestore
    final invoiceWidget = isRahul
        ? _buildInvoiceSection(
            context, isDark, user, InvoiceModel.seededInvoicesForRahul())
        : _buildFirestoreInvoiceSection(context, isDark, user);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Current Subscription ─────────────────────────────────────────
          Text(
            'Current Subscription',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppSpacing.md),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$planName Plan',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              'Monthly Subscription',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.lightTextSecondary,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusSm),
                        ),
                        child: Text(
                          'ACTIVE',
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Next Billing Date',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.lightTextSecondary,
                                  ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              DateFormat('MMM dd, yyyy').format(
                                DateTime(
                                  DateTime.now().year,
                                  DateTime.now().month + 1,
                                  1,
                                ),
                              ),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Amount',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.lightTextSecondary,
                                ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            formatCurrency(_getPlanPrice(user.activePlanId)),
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          text: 'Change Plan',
                          onPressed: () => widget.onNavigateToPlans?.call(),
                          type: ButtonType.secondary,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: CustomButton(
                          text: 'Pay Now',
                          onPressed: () async {
                            final price =
                                _getPlanPrice(user.activePlanId);
                            final pName =
                                _getPlanDisplayName(user.activePlanId);
                            final result = await showPaymentSheet(
                              context,
                              amountInRupees: price,
                              planName: '$pName Plan',
                            );
                            if (result != null &&
                                result.status == PaymentStatus.success) {
                              if (!context.mounted) return;
                              // Confirm payment — this also creates the invoice in Firestore
                              await ref
                                  .read(authProvider.notifier)
                                  .confirmPayment(user.activePlanId!);
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Payment of ${formatCurrency(price)} received! Invoice generated.',
                                  ),
                                  backgroundColor: Colors.green,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          },
                          type: ButtonType.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.xl),
          _buildProjectedBillWidget(context, isDark, user),
          const SizedBox(height: AppSpacing.xl),
          _buildExpenseBreakdownChart(context, isDark, user),
          const SizedBox(height: AppSpacing.xl),

          // ── Invoice Section ──────────────────────────────────────────────
          invoiceWidget,

          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  // ─── Rahul: seeded invoices ──────────────────────────────────────────────────
  Widget _buildInvoiceSection(BuildContext context, bool isDark,
      UserModel user, List<InvoiceModel> invoices) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Billing History',
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            TextButton.icon(
              onPressed: () => _downloadAllInvoices(invoices, user),
              icon: const Icon(Icons.download, size: 18),
              label: const Text('Download All'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        ...invoices.map((invoice) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _buildInvoiceCard(context, invoice, isDark, user),
            )),
      ],
    );
  }

  // ─── Sarth: Firestore invoice stream ────────────────────────────────────────
  Widget _buildFirestoreInvoiceSection(
      BuildContext context, bool isDark, UserModel user) {
    final firestoreService = FirestoreService();

    return StreamBuilder<List<InvoiceModel>>(
      stream: firestoreService.streamInvoices(user.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final invoices = snapshot.data ?? [];

        if (invoices.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: AppColors.primary),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Your first invoice will appear here after your next payment.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Billing History',
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  onPressed: () => _downloadAllInvoices(invoices, user),
                  icon: const Icon(Icons.download, size: 18),
                  label: const Text('Download All'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            ...invoices.map((invoice) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: _buildInvoiceCard(context, invoice, isDark, user),
                )),
          ],
        );
      },
    );
  }

  // ─── Invoice Card ────────────────────────────────────────────────────────────
  Widget _buildInvoiceCard(
      BuildContext context, InvoiceModel invoice, bool isDark, UserModel user) {
    final isLoading = _pdfLoading[invoice.id] ?? false;
    final statusColor = invoice.status == 'paid'
        ? AppColors.primary
        : invoice.status == 'pending'
            ? AppColors.solarProduction
            : AppColors.error;

    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(AppSpacing.md),
        leading: Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          ),
          child: Icon(
            invoice.status == 'paid' ? Icons.check_circle : Icons.pending,
            color: statusColor,
          ),
        ),
        title: Text(
          invoice.id,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.xs),
            Text(
              '${invoice.planName} • ${invoice.period}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Due: ${DateFormat('MMM dd, yyyy').format(invoice.dueDate)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              formatCurrency(invoice.amount),
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.xs),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xs,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: Text(
                invoice.status.toUpperCase(),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ],
        ),
        // Tap to download PDF
        onTap: isLoading ? null : () => _downloadInvoice(invoice, user),
        // Download icon on the far right
        isThreeLine: false,
      ),
    );
  }

  // ─── Projected Bill Widget ───────────────────────────────────────────────────
  Widget _buildProjectedBillWidget(
      BuildContext context, bool isDark, UserModel user) {
    if (user.email.toLowerCase() != 'rahul@gmail.com') {
      return const SizedBox.shrink();
    }

    final basePrice = _getPlanPrice(user.activePlanId);
    final projectedDiscount = 299.0;
    final projectedTotal = basePrice - projectedDiscount;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
              : [const Color(0xFFE0E7FF), const Color(0xFFDBEAFE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: isDark
              ? Colors.white12
              : AppColors.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.auto_awesome, color: AppColors.primary),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Projected Next Bill',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                ),
                const SizedBox(height: 4),
                RichText(
                  text: TextSpan(
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isDark ? Colors.white60 : Colors.black54,
                          height: 1.4,
                        ),
                    children: [
                      const TextSpan(
                          text: 'Based on current usage, expect roughly '),
                      TextSpan(
                        text: formatCurrency(projectedTotal),
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary),
                      ),
                      TextSpan(
                        text:
                            ' (₹${projectedDiscount.toInt()} less than base!)',
                        style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.success),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Expense Breakdown Chart ─────────────────────────────────────────────────
  Widget _buildExpenseBreakdownChart(
      BuildContext context, bool isDark, UserModel user) {
    if (user.email.toLowerCase() != 'rahul@gmail.com') {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Expense Breakdown',
          style: Theme.of(context)
              .textTheme
              .headlineMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppSpacing.md),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                SizedBox(
                  height: 120,
                  width: 120,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 35,
                      startDegreeOffset: -90,
                      sections: [
                        PieChartSectionData(
                          color: AppColors.primary,
                          value: 70,
                          title: '70%',
                          radius: 18,
                          titleStyle: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        PieChartSectionData(
                          color: AppColors.solarProduction,
                          value: 20,
                          title: '20%',
                          radius: 16,
                          titleStyle: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        PieChartSectionData(
                          color: AppColors.gridConsumption,
                          value: 10,
                          title: '10%',
                          radius: 14,
                          titleStyle: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.xl),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _legendItem(context, 'Base Plan', AppColors.primary),
                      const SizedBox(height: AppSpacing.sm),
                      _legendItem(context, 'Grid Overage',
                          AppColors.solarProduction),
                      const SizedBox(height: AppSpacing.sm),
                      _legendItem(
                          context, 'Taxes/Fees', AppColors.gridConsumption),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _legendItem(BuildContext context, String title, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(title,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(fontWeight: FontWeight.w500)),
      ],
    );
  }
}
