import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:volthive/core/theme/app_colors.dart';
import 'package:volthive/core/theme/app_spacing.dart';
import 'package:volthive/features/payment/models/payment_method.dart';
import 'package:volthive/features/payment/models/payment_result.dart';
import 'package:volthive/features/payment/services/volthive_payment_service.dart';
import 'package:volthive/features/payment/presentation/widgets/card_preview_widget.dart';
import 'package:volthive/features/payment/presentation/widgets/upi_logo_widget.dart';
import 'package:volthive/features/payment/presentation/screens/payment_result_screen.dart';

/// Shows the VoltHive Payment Gateway as a modal bottom sheet.
/// Returns a [PaymentResult] when the sheet is dismissed.
Future<PaymentResult?> showPaymentSheet(
  BuildContext context, {
  required double amountInRupees,
  required String planName,
}) {
  return showModalBottomSheet<PaymentResult>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => PaymentSheet(
      amountInRupees: amountInRupees,
      planName: planName,
    ),
  );
}

class PaymentSheet extends StatefulWidget {
  final double amountInRupees;
  final String planName;

  const PaymentSheet({
    super.key,
    required this.amountInRupees,
    required this.planName,
  });

  @override
  State<PaymentSheet> createState() => _PaymentSheetState();
}

class _PaymentSheetState extends State<PaymentSheet>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  bool _isProcessing = false;

  // UPI
  final _upiController = TextEditingController();
  String? _selectedUpiApp;

  // Card
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _cardNameController = TextEditingController();

  // Net Banking
  String? _selectedBank;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _upiController.dispose();
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _cardNameController.dispose();
    super.dispose();
  }

  String get _formattedAmount {
    return '₹${widget.amountInRupees.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';
  }

  Future<void> _processPayment(String methodLabel) async {
    setState(() => _isProcessing = true);

    final result = await VoltHivePaymentService().processPayment(
      amountInRupees: widget.amountInRupees,
      methodLabel: methodLabel,
    );

    if (!mounted) return;
    setState(() => _isProcessing = false);

    // Push result screen on top of the sheet (keeps sheet in route stack).
    // When the result screen pops, we then pop the sheet with the result.
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PaymentResultScreen(
          result: result,
          amountInRupees: widget.amountInRupees,
          planName: widget.planName,
        ),
        fullscreenDialog: true,
      ),
    );

    // Now pop the sheet with the result so the caller gets it.
    if (mounted) Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkBackground : Colors.white;
    final screenH = MediaQuery.of(context).size.height;

    return Container(
      height: screenH * 0.88,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag handle
          const SizedBox(height: AppSpacing.sm),
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Header
          _buildHeader(isDark),

          const Divider(),

          // Tab bar
          _buildTabBar(isDark),

          // Tab views
          Expanded(
            child: _isProcessing
                ? _buildProcessingOverlay()
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildUpiTab(isDark),
                      _buildCardTab(isDark),
                      _buildNetBankingTab(isDark),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: [
          // VoltHive logo mark
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.bolt, color: Colors.white, size: 24),
          ),
          const SizedBox(width: AppSpacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'VoltHive Pay',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
              ),
              Text(
                'Secure Payment Gateway',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
              ),
            ],
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formattedAmount,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
              ),
              Text(
                widget.planName,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(bool isDark) {
    return TabBar(
      controller: _tabController,
      labelColor: AppColors.primary,
      unselectedLabelColor:
          isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
      indicatorColor: AppColors.primary,
      indicatorSize: TabBarIndicatorSize.label,
      tabs: const [
        Tab(text: 'UPI'),
        Tab(text: 'Card'),
        Tab(text: 'Net Banking'),
      ],
    );
  }

  // ── UPI TAB ─────────────────────────────────────────────────────────────────
  Widget _buildUpiTab(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.sm),

          // Quick app selector
          Text(
            'Pay with UPI App',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: AppSpacing.md),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: upiApps.map((app) {
              final isSelected = _selectedUpiApp == app.name;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedUpiApp = app.name;
                    _upiController.clear();
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 72,
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: 0.1)
                        : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? AppColors.primary : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                      width: isSelected ? 1.5 : 1,
                    ),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      upiAppLogo(app.name, size: 36),
                      const SizedBox(height: 6),
                      Text(
                        app.name,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                              color: isSelected ? AppColors.primary : null,
                            ),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: AppSpacing.xl),

          // OR divider
          Row(
            children: [
              const Expanded(child: Divider()),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                child: Text('OR', style: Theme.of(context).textTheme.bodySmall),
              ),
              const Expanded(child: Divider()),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          // UPI ID input
          Text(
            'Enter UPI ID',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: AppSpacing.sm),

          TextFormField(
            controller: _upiController,
            onChanged: (_) => setState(() => _selectedUpiApp = null),
            keyboardType: TextInputType.emailAddress,
            style: Theme.of(context).textTheme.bodyMedium,
            decoration: InputDecoration(
              hintText: 'yourname@upi',
              prefixIcon: const Icon(Icons.account_balance_wallet_outlined, color: AppColors.primary),
              suffixText: '@upi',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                borderSide: const BorderSide(color: AppColors.primary, width: 2),
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          // Verify & Pay button
          _buildPayButton(
            label: 'Verify & Pay  $_formattedAmount',
            onTap: () {
              final method = _selectedUpiApp ?? '${_upiController.text}@upi';
              _processPayment('UPI: $method');
            },
          ),

          const SizedBox(height: AppSpacing.md),
          _buildSecureBadge(),
        ],
      ),
    );
  }

  // ── CARD TAB ────────────────────────────────────────────────────────────────
  Widget _buildCardTab(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          // Live card preview
          CardPreviewWidget(
            cardNumber: _cardNumberController.text,
            cardName: _cardNameController.text,
            expiry: _expiryController.text,
          ),

          const SizedBox(height: AppSpacing.lg),

          // Card number
          TextFormField(
            controller: _cardNumberController,
            onChanged: (_) => setState(() {}),
            keyboardType: TextInputType.number,
            maxLength: 19,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              _CardNumberFormatter(),
            ],
            decoration: _inputDecoration(
              'Card Number',
              Icons.credit_card,
              hint: '0000 0000 0000 0000',
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _expiryController,
                  onChanged: (_) => setState(() {}),
                  keyboardType: TextInputType.number,
                  maxLength: 5,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    _ExpiryFormatter(),
                  ],
                  decoration: _inputDecoration(
                    'MM/YY',
                    Icons.calendar_today_outlined,
                    hint: '12/28',
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: TextFormField(
                  controller: _cvvController,
                  keyboardType: TextInputType.number,
                  maxLength: 3,
                  obscureText: true,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: _inputDecoration(
                    'CVV',
                    Icons.lock_outline,
                    hint: '•••',
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          TextFormField(
            controller: _cardNameController,
            onChanged: (_) => setState(() {}),
            textCapitalization: TextCapitalization.characters,
            decoration: _inputDecoration(
              'Name on Card',
              Icons.person_outline,
              hint: 'RAHUL SHARMA',
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          _buildPayButton(
            label: 'Pay Securely  $_formattedAmount',
            onTap: () => _processPayment('Card: ${_maskedCardNumber()}'),
          ),

          const SizedBox(height: AppSpacing.md),
          _buildSecureBadge(),
        ],
      ),
    );
  }

  String _maskedCardNumber() {
    final raw = _cardNumberController.text.replaceAll(' ', '');
    if (raw.length >= 4) return '•••• ${raw.substring(raw.length - 4)}';
    return 'Card';
  }

  // ── NET BANKING TAB ─────────────────────────────────────────────────────────
  Widget _buildNetBankingTab(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select your Bank',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: AppSpacing.md),

          ...popularBanks.map(
            (bank) => InkWell(
              onTap: () => setState(() => _selectedBank = bank.code),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Radio<String>(
                      value: bank.code,
                      groupValue: _selectedBank,
                      onChanged: (v) => setState(() => _selectedBank = v),
                      fillColor: WidgetStateProperty.resolveWith(
                        (states) => states.contains(WidgetState.selected)
                            ? AppColors.primary
                            : null,
                      ),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    Image.asset(
                      bank.logoAsset,
                      width: 24,
                      height: 24,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.account_balance, size: 24, color: Colors.grey),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        bank.name,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          _buildPayButton(
            label: 'Pay via Net Banking  $_formattedAmount',
            onTap: _selectedBank == null
                ? null
                : () => _processPayment(
                      'Net Banking: ${popularBanks.firstWhere((b) => b.code == _selectedBank!).name}',
                    ),
          ),

          const SizedBox(height: AppSpacing.md),
          _buildSecureBadge(),
        ],
      ),
    );
  }

  // ── SHARED HELPERS ───────────────────────────────────────────────────────────
  Widget _buildPayButton({
    required String label,
    required VoidCallback? onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.4),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
      ),
    );
  }

  Widget _buildSecureBadge() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.lock, size: 14, color: Colors.green),
        const SizedBox(width: 4),
        Text(
          '256-bit SSL secured · VoltHive Pay',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.green,
                fontSize: 11,
              ),
        ),
      ],
    );
  }

  Widget _buildProcessingOverlay() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 64,
            height: 64,
            child: CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Processing Payment…',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Please do not close this screen',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(
    String label,
    IconData icon, {
    String? hint,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
      counterText: '',
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
    );
  }
}

// ── Input Formatters ──────────────────────────────────────────────────────────

class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(' ', '');
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(digits[i]);
    }
    final formatted = buffer.toString();
    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class _ExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll('/', '');
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i == 2) buffer.write('/');
      buffer.write(digits[i]);
    }
    final formatted = buffer.toString();
    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
