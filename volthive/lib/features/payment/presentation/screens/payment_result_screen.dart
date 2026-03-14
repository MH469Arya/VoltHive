import 'package:flutter/material.dart';
import 'package:volthive/core/theme/app_colors.dart';
import 'package:volthive/core/theme/app_spacing.dart';
import 'package:volthive/features/payment/models/payment_result.dart';

/// Full-screen result screen shown after a payment attempt.
/// Shows animated success (✅) or failure (❌) + transaction details.
class PaymentResultScreen extends StatefulWidget {
  final PaymentResult result;
  final double amountInRupees;
  final String planName;

  const PaymentResultScreen({
    super.key,
    required this.result,
    required this.amountInRupees,
    required this.planName,
  });

  @override
  State<PaymentResultScreen> createState() => _PaymentResultScreenState();
}

class _PaymentResultScreenState extends State<PaymentResultScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _scaleAnim = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _isSuccess => widget.result.isSuccess;

  String get _formattedAmount {
    return '₹${widget.amountInRupees.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statusColor = _isSuccess ? Colors.green : AppColors.error;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            children: [
              const Spacer(),

              // Animated icon
              ScaleTransition(
                scale: _scaleAnim,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isSuccess ? Icons.check_circle_rounded : Icons.cancel_rounded,
                    size: 64,
                    color: statusColor,
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Status text
              FadeTransition(
                opacity: _fadeAnim,
                child: Column(
                  children: [
                    Text(
                      _isSuccess ? 'Payment Successful!' : 'Payment Failed',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      _isSuccess
                          ? 'Your ${widget.planName} plan is now active.'
                          : widget.result.errorMessage ?? 'Something went wrong. Please try again.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Transaction details card (success only)
              if (_isSuccess) ...[
                FadeTransition(
                  opacity: _fadeAnim,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        children: [
                          _detailRow(context, 'Amount Paid', _formattedAmount, isDark),
                          const Divider(height: AppSpacing.lg),
                          _detailRow(context, 'Plan', widget.planName, isDark),
                          const Divider(height: AppSpacing.lg),
                          _detailRow(
                            context,
                            'Transaction ID',
                            widget.result.transactionId ?? '—',
                            isDark,
                            isMonospace: true,
                          ),
                          const Divider(height: AppSpacing.lg),
                          _detailRow(
                            context,
                            'Date',
                            _formatDate(DateTime.now()),
                            isDark,
                          ),
                          const Divider(height: AppSpacing.lg),
                          _detailRow(context, 'Status', 'SUCCESS', isDark,
                              valueColor: Colors.green),
                        ],
                      ),
                    ),
                  ),
                ),
              ],

              const Spacer(),

              // CTA
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    // Pop back to caller with the result
                    Navigator.of(context).pop(widget.result);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isSuccess ? AppColors.primary : AppColors.error,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                  ),
                  child: Text(
                    _isSuccess ? 'Go to Billing' : 'Try Again',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),

              if (_isSuccess) ...[
                const SizedBox(height: AppSpacing.sm),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(widget.result),
                  child: const Text('Back to Home'),
                ),
              ],

              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(
    BuildContext context,
    String label,
    String value,
    bool isDark, {
    Color? valueColor,
    bool isMonospace = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: valueColor,
                fontFamily: isMonospace ? 'monospace' : null,
                fontSize: isMonospace ? 12 : null,
              ),
        ),
      ],
    );
  }

  String _formatDate(DateTime dt) {
    final months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${dt.day} ${months[dt.month]} ${dt.year}, ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
