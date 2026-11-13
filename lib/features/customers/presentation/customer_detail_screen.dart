import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/responsive.dart';
import '../../payments/presentation/payment_collection_dialog.dart';
import '../models/customer_detail_model.dart';
import '../providers/customer_providers.dart';

class CustomerDetailScreen extends ConsumerWidget {
  final String customerId;

  const CustomerDetailScreen({super.key, required this.customerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(customerDetailProvider(customerId));
    final isDesktop = MediaQuery.sizeOf(context).width >= 960;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Customer Ledger', style: AppTextStyles.h2),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.textPrimary),
            tooltip: 'Refresh',
            onPressed: () => ref.invalidate(customerDetailProvider(customerId)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: detailAsync.when(
        data: (detail) {
          final customer = detail.customer;
          final ledger = detail.ledgerItems;

          return SingleChildScrollView(
            child: ResponsiveCenter(
              maxWidth: 1360,
              padding: EdgeInsets.all(isDesktop ? 24.0 : 16.w),
              child: isDesktop
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left Column: Customer Profile + Financial Summary + Quick Actions
                        SizedBox(
                          width: 420,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildProfileCard(customer),
                              const SizedBox(height: 16),
                              _buildFinancialSummary(customer),
                              const SizedBox(height: 16),
                              _buildActionButtons(context, ref, customer),
                            ],
                          ),
                        ),
                        const SizedBox(width: 24),

                        // Right Column: Ledger Timeline
                        Expanded(
                          child: _buildLedgerCard(ledger),
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildProfileCard(customer),
                        SizedBox(height: 16.h),
                        _buildFinancialSummary(customer),
                        SizedBox(height: 16.h),
                        _buildActionButtons(context, ref, customer),
                        SizedBox(height: 24.h),
                        _buildLedgerCard(ledger),
                        SizedBox(height: 30.h),
                      ],
                    ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error loading customer ledger: $err', style: AppTextStyles.bodyMedium),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => ref.invalidate(customerDetailProvider(customerId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard(dynamic customer) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: AppColors.primarySurface,
                child: Text(
                  customer.name.isNotEmpty ? customer.name[0].toUpperCase() : 'C',
                  style: AppTextStyles.h1.copyWith(color: AppColors.primary),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(customer.name, style: AppTextStyles.h2),
                    const SizedBox(height: 4),
                    Text(
                      customer.phone.isNotEmpty ? customer.phone : 'Customer Account',
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 12),

          // Contact Info
          Row(
            children: [
              const Icon(Icons.phone_outlined, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 8),
              Text(customer.phone.isNotEmpty ? customer.phone : 'N/A', style: AppTextStyles.bodyMedium),
              if (customer.email.isNotEmpty) ...[
                const SizedBox(width: 16),
                const Icon(Icons.email_outlined, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    customer.email,
                    style: AppTextStyles.bodyMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
          if (customer.address.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.location_on_outlined, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(customer.address, style: AppTextStyles.bodySmall),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFinancialSummary(dynamic customer) {
    return Row(
      children: [
        Expanded(
          child: _SummaryBox(
            title: 'Total Billed',
            amount: customer.totalBilled,
            color: AppColors.billed,
            bgColor: AppColors.billedLight,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _SummaryBox(
            title: 'Total Paid',
            amount: customer.totalPaid,
            color: AppColors.received,
            bgColor: AppColors.receivedLight,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _SummaryBox(
            title: 'Outstanding',
            amount: customer.outstandingBalance,
            color: AppColors.outstanding,
            bgColor: AppColors.outstandingLight,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, WidgetRef ref, dynamic customer) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              context.push('/invoices/create?customer_id=${customer.id}');
            },
            icon: const Icon(Icons.add_shopping_cart, size: 18),
            label: const Text('New Invoice'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: customer.outstandingBalance <= 0
                ? null
                : () async {
                    final paid = await showDialog<bool>(
                      context: context,
                      builder: (_) => PaymentCollectionDialog(
                        customerId: customer.id,
                        customerName: customer.name,
                        dueAmount: customer.outstandingBalance,
                      ),
                    );
                    if (paid == true) {
                      ref.invalidate(customerDetailProvider(customerId));
                      ref.read(customerListProvider.notifier).refresh();
                    }
                  },
            icon: const Icon(Icons.payments_outlined, size: 18),
            label: const Text('Collect Payment'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.received,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLedgerCard(List<dynamic> ledger) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Ledger & Timeline', style: AppTextStyles.h3),
            Text(
              '${ledger.length} Transactions',
              style: AppTextStyles.caption,
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (ledger.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Center(
              child: Text(
                'No invoices or payment entries recorded yet.',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: ledger.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final item = ledger[index];
              final isInvoice = item.type == LedgerEntryType.invoice;

              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isInvoice ? AppColors.billedLight : AppColors.receivedLight,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isInvoice ? Icons.receipt_outlined : Icons.check_circle_outline,
                        color: isInvoice ? AppColors.billed : AppColors.received,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                item.referenceNumber,
                                style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(width: 8),
                              _StatusPill(
                                text: item.statusOrMode,
                                isPayment: !isInvoice,
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormatter.toDisplay(DateTime.tryParse(item.date)),
                            style: AppTextStyles.caption,
                          ),
                          if (item.description.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              item.description,
                              style: AppTextStyles.bodySmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${isInvoice ? "+" : "-"} ${CurrencyFormatter.formatCompact(item.amount)}',
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.w700,
                            color: isInvoice ? AppColors.billed : AppColors.received,
                          ),
                        ),
                        Text(
                          isInvoice ? 'Billed' : 'Received',
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }
}

class _SummaryBox extends StatelessWidget {
  final String title;
  final double amount;
  final Color color;
  final Color bgColor;

  const _SummaryBox({
    required this.title,
    required this.amount,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.caption.copyWith(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            CurrencyFormatter.formatCompact(amount),
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String text;
  final bool isPayment;

  const _StatusPill({required this.text, required this.isPayment});

  @override
  Widget build(BuildContext context) {
    Color bg = AppColors.background;
    Color fg = AppColors.textSecondary;

    if (text == 'PAID' || isPayment) {
      bg = AppColors.receivedLight;
      fg = AppColors.received;
    } else if (text == 'PARTIAL') {
      bg = AppColors.partialLight;
      fg = AppColors.partial;
    } else if (text == 'UNPAID') {
      bg = AppColors.outstandingLight;
      fg = AppColors.outstanding;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }
}
