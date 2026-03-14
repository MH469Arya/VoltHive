import 'package:flutter/material.dart';
import 'package:volthive/core/theme/app_colors.dart';
import 'package:volthive/core/theme/app_spacing.dart';
import 'package:volthive/features/support/data/models/support_ticket_model.dart';
import 'package:intl/intl.dart';

/// Support screen with tickets, FAQs and live chat
class SupportScreen extends StatefulWidget {
  final VoidCallback? onOpenChat;

  const SupportScreen({super.key, this.onOpenChat});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  late List<SupportTicketModel> _tickets;
  String _faqSearchQuery = '';
  bool _isDiagnosticRunning = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _tickets = [
      SupportTicketModel(
        id: 'TKT-001',
        title: 'Battery level showing incorrect reading',
        description: 'The battery level is stuck at 85% for the past 2 hours',
        status: 'in_progress',
        priority: 'medium',
        createdAt: now.subtract(const Duration(hours: 3)),
      ),
      SupportTicketModel(
        id: 'TKT-002',
        title: 'Question about plan upgrade',
        description: 'I want to upgrade from Bloom to Thrive plan',
        status: 'resolved',
        priority: 'low',
        createdAt: now.subtract(const Duration(days: 2)),
        resolvedAt: now.subtract(const Duration(days: 1)),
      ),
    ];
  }

  void _openNewTicketSheet() {
    final formKey = GlobalKey<FormState>();
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    String selectedPriority = 'medium';
    String selectedCategory = 'Hardware';
    final categories = ['Hardware', 'Software', 'Billing', 'Other'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return StatefulBuilder(
          builder: (ctx, setSheetState) => Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Drag handle
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white24 : Colors.black12,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Text(
                      'Create New Ticket',
                      style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 20),

                    // Title field
                    TextFormField(
                      controller: titleCtrl,
                      decoration: InputDecoration(
                        labelText: 'Issue Title',
                        hintText: 'e.g. Battery not charging',
                        prefixIcon: const Icon(Icons.title),
                        filled: true,
                        fillColor: isDark
                            ? const Color(0xFF0F0F1A)
                            : const Color(0xFFF3F4F6),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Title is required' : null,
                    ),
                    const SizedBox(height: 14),

                    // Category dropdown
                    DropdownButtonFormField<String>(
                      initialValue: selectedCategory,
                      decoration: InputDecoration(
                        labelText: 'Issue Category',
                        prefixIcon: const Icon(Icons.category_outlined),
                        filled: true,
                        fillColor: isDark
                            ? const Color(0xFF0F0F1A)
                            : const Color(0xFFF3F4F6),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      items: categories.map((cat) {
                        return DropdownMenuItem(
                          value: cat,
                          child: Text(cat),
                        );
                      }).toList(),
                      onChanged: (v) {
                        if (v != null) {
                          setSheetState(() => selectedCategory = v);
                        }
                      },
                    ),
                    const SizedBox(height: 14),

                    // Description field
                    TextFormField(
                      controller: descCtrl,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        hintText: 'Describe your issue in detail...',
                        prefixIcon: const Padding(
                          padding: EdgeInsets.only(bottom: 40),
                          child: Icon(Icons.description_outlined),
                        ),
                        filled: true,
                        fillColor: isDark
                            ? const Color(0xFF0F0F1A)
                            : const Color(0xFFF3F4F6),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Description is required' : null,
                    ),
                    const SizedBox(height: 14),

                    // Priority selector
                    Text('Priority',
                        style: Theme.of(ctx).textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            )),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _priorityChip(ctx, setSheetState, 'low', 'Low',
                            const Color(0xFF22C55E), selectedPriority, (v) {
                          setSheetState(() => selectedPriority = v);
                        }),
                        const SizedBox(width: 8),
                        _priorityChip(ctx, setSheetState, 'medium', 'Medium',
                            const Color(0xFFF59E0B), selectedPriority, (v) {
                          setSheetState(() => selectedPriority = v);
                        }),
                        const SizedBox(width: 8),
                        _priorityChip(ctx, setSheetState, 'high', 'High',
                            const Color(0xFFEF4444), selectedPriority, (v) {
                          setSheetState(() => selectedPriority = v);
                        }),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Submit button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            final newTicket = SupportTicketModel(
                              id: 'TKT-${(_tickets.length + 1).toString().padLeft(3, '0')}',
                              title: titleCtrl.text.trim(),
                              description: descCtrl.text.trim(),
                              status: 'open',
                              priority: selectedPriority,
                              createdAt: DateTime.now(),
                            );
                            setState(() => _tickets.insert(0, newTicket));
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Ticket created successfully!'),
                                backgroundColor: AppColors.primary,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Submit Ticket',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _priorityChip(
    BuildContext ctx,
    StateSetter setSheetState,
    String value,
    String label,
    Color color,
    String selected,
    ValueChanged<String> onSelect,
  ) {
    final isSelected = selected == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => onSelect(value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha: 0.15) : Colors.transparent,
            border: Border.all(
              color: isSelected ? color : Colors.grey.withValues(alpha: 0.3),
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? color : Colors.grey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Support'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quick Actions
            Text(
              'How can we help?',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),

            const SizedBox(height: AppSpacing.md),

            Row(
              children: [
                Expanded(
                  child: _buildQuickAction(
                    context,
                    icon: Icons.add_circle_outline,
                    label: 'New Ticket',
                    onTap: _openNewTicketSheet,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _buildQuickAction(
                    context,
                    icon: Icons.chat_bubble_outline,
                    label: 'Live Chat',
                    onTap: () => widget.onOpenChat?.call(),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.sm),

            // Diagnostic Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isDiagnosticRunning
                    ? null
                    : () async {
                        setState(() => _isDiagnosticRunning = true);
                        await Future.delayed(const Duration(seconds: 3));
                        if (!mounted) return;
                        setState(() => _isDiagnosticRunning = false);
                        
                        if (!context.mounted) return;

                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Row(
                              children: [
                                Icon(Icons.check_circle, color: AppColors.success),
                                SizedBox(width: 8),
                                Text('System Diagnostics'),
                              ],
                            ),
                            content: const Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('• Solar Panels: OK (Generating Expected KwH)'),
                                SizedBox(height: 4),
                                Text('• Battery Unit: OK (Charging Normally)'),
                                SizedBox(height: 4),
                                Text('• Grid Connection: OK (Stable)'),
                                SizedBox(height: 12),
                                Text('No hardware issues detected. If you re experiencing software problems, please open a ticket.', 
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: const Text('Close'),
                              ),
                            ],
                          ),
                        );
                      },
                icon: _isDiagnosticRunning
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.health_and_safety_outlined),
                label: Text(
                  _isDiagnosticRunning ? 'Running Diagnostics...' : 'Run System Diagnostics',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? AppColors.gridConsumption.withValues(alpha: 0.8) : AppColors.gridConsumption,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.sm),

            Row(
              children: [
                Expanded(
                  child: _buildQuickAction(
                    context,
                    icon: Icons.phone_outlined,
                    label: 'Call Us',
                    onTap: () {},
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _buildQuickAction(
                    context,
                    icon: Icons.email_outlined,
                    label: 'Email',
                    onTap: () {},
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.xl),

            // My Tickets
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'My Tickets',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text('View All'),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.md),

            if (_tickets.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 64,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          'No active tickets',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'You\'re all set! Create a ticket if you need help.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              ..._tickets.map((ticket) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: _buildTicketCard(context, ticket, isDark),
                  )),

            const SizedBox(height: AppSpacing.xl),

            // FAQs
            Text(
              'Frequently Asked Questions',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),

            const SizedBox(height: AppSpacing.md),
            
            // Searchable FAQ
            TextField(
              decoration: InputDecoration(
                hintText: 'Search FAQs...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: (val) {
                setState(() {
                  _faqSearchQuery = val.toLowerCase();
                });
              },
            ),

            const SizedBox(height: AppSpacing.md),

            // Filtered FAQ Items
            if ('How do I upgrade my plan?'.toLowerCase().contains(_faqSearchQuery) || 
                'You can upgrade your plan anytime'.toLowerCase().contains(_faqSearchQuery))
              _buildFaqItem(
                context,
                'How do I upgrade my plan?',
                'You can upgrade your plan anytime from the Plans tab. Changes take effect from the next billing cycle.',
                isDark,
              ),

            if ('What happens during a power outage?'.toLowerCase().contains(_faqSearchQuery) || 
                'battery backup will automatically activate'.toLowerCase().contains(_faqSearchQuery))
              _buildFaqItem(
                context,
                'What happens during a power outage?',
                'Your battery backup will automatically activate, providing power for the duration specified in your plan.',
                isDark,
              ),

            if ('How is my solar generation calculated?'.toLowerCase().contains(_faqSearchQuery) || 
                'measured in real-time by our smart meters'.toLowerCase().contains(_faqSearchQuery))
              _buildFaqItem(
                context,
                'How is my solar generation calculated?',
                'Solar generation is measured in real-time by our smart meters and updated every 15 minutes on your dashboard.',
                isDark,
              ),

            if ('Can I cancel my subscription?'.toLowerCase().contains(_faqSearchQuery) || 
                'You can cancel anytime'.toLowerCase().contains(_faqSearchQuery))
              _buildFaqItem(
                context,
                'Can I cancel my subscription?',
                'Yes, you can cancel anytime. Your service will continue until the end of your current billing period.',
                isDark,
              ),

            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            children: [
              Icon(
                icon,
                color: AppColors.primary,
                size: AppSpacing.iconLg,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTicketCard(
    BuildContext context,
    SupportTicketModel ticket,
    bool isDark,
  ) {
    final statusColor = ticket.status == 'resolved'
        ? AppColors.primary
        : ticket.status == 'in_progress'
            ? AppColors.solarProduction
            : ticket.status == 'open'
                ? AppColors.batteryTech
                : AppColors.gridConsumption;

    final priorityColor = ticket.priority == 'high'
        ? AppColors.error
        : ticket.priority == 'medium'
            ? AppColors.solarProduction
            : AppColors.gridConsumption;

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
            ticket.status == 'resolved'
                ? Icons.check_circle
                : ticket.status == 'in_progress'
                    ? Icons.pending
                    : Icons.help_outline,
            color: statusColor,
          ),
        ),
        title: Text(
          ticket.title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.xs),
            Text(
              ticket.description,
              style: Theme.of(context).textTheme.bodySmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
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
                    ticket.status.toUpperCase().replaceAll('_', ' '),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xs,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: priorityColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  child: Text(
                    ticket.priority.toUpperCase(),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: priorityColor,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                const Spacer(),
                Text(
                  DateFormat('MMM dd').format(ticket.createdAt),
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
        onTap: () {},
      ),
    );
  }

  Widget _buildFaqItem(
    BuildContext context,
    String question,
    String answer,
    bool isDark,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        title: Text(
          question,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              0,
              AppSpacing.md,
              AppSpacing.md,
            ),
            child: Text(
              answer,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
