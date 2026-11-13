import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/responsive.dart';
import '../models/invoice_model.dart';
import '../providers/invoice_providers.dart';

class InvoiceListScreen extends ConsumerStatefulWidget {
  const InvoiceListScreen({super.key});

  @override
  ConsumerState<InvoiceListScreen> createState() => _InvoiceListScreenState();
}

class _InvoiceListScreenState extends ConsumerState<InvoiceListScreen> {
  final _searchController = TextEditingController();
  final List<String> _filterStatuses = ['ALL', 'UNPAID', 'PARTIAL', 'PAID', 'OVERDUE'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final invoicesAsync = ref.watch(invoiceListProvider);
    final activeStatus = ref.watch(invoiceFilterStatusProvider);
    final isDesktopOrTablet = context.isDesktopOrTablet;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Invoices', style: AppTextStyles.h2),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.textPrimary),
            tooltip: 'Refresh',
            onPressed: () => ref.read(invoiceListProvider.notifier).refresh(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: isDesktopOrTablet
          ? null
          : FloatingActionButton.extended(
              onPressed: () => context.push('/invoices/create'),
              backgroundColor: AppColors.primary,
              icon: const Icon(Icons.add, color: Colors.white),
              label: Text('Create Invoice', style: AppTextStyles.button),
            ),
      body: Column(
        children: [
          // Search & Status Filters Header
          Container(
            color: AppColors.surface,
            padding: EdgeInsets.symmetric(
              horizontal: isDesktopOrTablet ? 24.0 : 16.w,
              vertical: isDesktopOrTablet ? 16.0 : 12.h,
            ),
            child: ResponsiveCenter(
              maxWidth: 1360,
              child: isDesktopOrTablet
                  ? Row(
                      children: [
                        // Desktop Search Input
                        SizedBox(
                          width: 320,
                          child: TextField(
                            controller: _searchController,
                            onChanged: (val) {
                              ref.read(invoiceSearchQueryProvider.notifier).state = val;
                            },
                            decoration: InputDecoration(
                              hintText: 'Search invoice # or customer...',
                              hintStyle: AppTextStyles.bodySmall,
                              prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary, size: 20),
                              suffixIcon: _searchController.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear, size: 18),
                                      onPressed: () {
                                        _searchController.clear();
                                        ref.read(invoiceSearchQueryProvider.notifier).state = '';
                                      },
                                    )
                                  : null,
                              filled: true,
                              fillColor: AppColors.background,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Status Filter Chips
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: _filterStatuses.map((st) {
                                final isSelected = activeStatus == st;
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: ChoiceChip(
                                    label: Text(st),
                                    selected: isSelected,
                                    selectedColor: AppColors.primary,
                                    labelStyle: TextStyle(
                                      fontSize: 12,
                                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                      color: isSelected ? Colors.white : AppColors.textPrimary,
                                    ),
                                    onSelected: (selected) {
                                      if (selected) {
                                        ref.read(invoiceFilterStatusProvider.notifier).state = st;
                                      }
                                    },
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Inline Create Invoice Button
                        ElevatedButton.icon(
                          onPressed: () => context.push('/invoices/create'),
                          icon: const Icon(Icons.add, color: Colors.white, size: 18),
                          label: const Text('Create Invoice', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        // Mobile Search Bar
                        TextField(
                          controller: _searchController,
                          onChanged: (val) {
                            ref.read(invoiceSearchQueryProvider.notifier).state = val;
                          },
                          decoration: InputDecoration(
                            hintText: 'Search by invoice # or customer...',
                            hintStyle: AppTextStyles.bodySmall,
                            prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear, size: 18),
                                    onPressed: () {
                                      _searchController.clear();
                                      ref.read(invoiceSearchQueryProvider.notifier).state = '';
                                    },
                                  )
                                : null,
                            filled: true,
                            fillColor: AppColors.background,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                          ),
                        ),
                        SizedBox(height: 10.h),

                        // Mobile Horizontal Status Filters
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: _filterStatuses.map((st) {
                              final isSelected = activeStatus == st;
                              return Padding(
                                padding: EdgeInsets.only(right: 8.w),
                                child: ChoiceChip(
                                  label: Text(st),
                                  selected: isSelected,
                                  selectedColor: AppColors.primary,
                                  labelStyle: TextStyle(
                                    fontSize: 11.sp,
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                    color: isSelected ? Colors.white : AppColors.textPrimary,
                                  ),
                                  onSelected: (selected) {
                                    if (selected) {
                                      ref.read(invoiceFilterStatusProvider.notifier).state = st;
                                    }
                                  },
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          const Divider(height: 1, color: AppColors.border),

          // Invoices List / Grid
          Expanded(
            child: invoicesAsync.when(
              data: (invoices) {
                if (invoices.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long_outlined, size: isDesktopOrTablet ? 56 : 64.sp, color: AppColors.textMuted),
                        const SizedBox(height: 12),
                        Text('No invoices found', style: AppTextStyles.h3),
                        const SizedBox(height: 6),
                        Text('Create your first invoice to get started', style: AppTextStyles.bodySmall),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => ref.read(invoiceListProvider.notifier).refresh(),
                  child: ResponsiveCenter(
                    maxWidth: 1360,
                    padding: EdgeInsets.symmetric(
                      horizontal: isDesktopOrTablet ? 24.0 : 16.w,
                      vertical: isDesktopOrTablet ? 20.0 : 16.h,
                    ),
                    child: isDesktopOrTablet
                        ? GridView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: invoices.length,
                            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 460,
                              mainAxisExtent: 185,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                            itemBuilder: (context, index) {
                              return _InvoiceListItem(invoice: invoices[index], isGrid: true);
                            },
                          )
                        : ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: invoices.length,
                            itemBuilder: (context, index) {
                              return _InvoiceListItem(invoice: invoices[index], isGrid: false);
                            },
                          ),
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Failed to load invoices: $err', style: AppTextStyles.bodyMedium),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => ref.read(invoiceListProvider.notifier).refresh(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InvoiceListItem extends StatelessWidget {
  final Invoice invoice;
  final bool isGrid;

  const _InvoiceListItem({required this.invoice, this.isGrid = false});

  @override
  Widget build(BuildContext context) {
    final isOverdue = invoice.isOverdue;

    return Container(
      margin: EdgeInsets.only(bottom: isGrid ? 0 : 12.h),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isOverdue ? AppColors.overdue.withValues(alpha: 0.4) : AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16.r),
          onTap: () {
            context.push('/invoices/${invoice.id}');
          },
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top Row: Invoice # + Status Badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          invoice.invoiceNumber,
                          style: AppTextStyles.h3.copyWith(color: AppColors.primary),
                        ),
                        if (isOverdue) ...[
                          SizedBox(width: 8.w),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: AppColors.outstandingLight,
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Text(
                              'OVERDUE',
                              style: TextStyle(
                                fontSize: 9.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.overdue,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    _InvoiceStatusBadge(status: invoice.status),
                  ],
                ),
                SizedBox(height: 6.h),

                // Customer Name
                Text(
                  invoice.customerName,
                  style: AppTextStyles.bodyLarge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),

                // Dates: Issue Date & Due Date
                Row(
                  children: [
                    Icon(Icons.calendar_today_outlined, size: 13.sp, color: AppColors.textSecondary),
                    SizedBox(width: 4.w),
                    Text(
                      'Issued: ${DateFormatter.toDisplay(DateTime.tryParse(invoice.date))}',
                      style: AppTextStyles.bodySmall,
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      'Due: ${DateFormatter.toDisplay(DateTime.tryParse(invoice.dueDate))}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isOverdue ? AppColors.overdue : AppColors.textSecondary,
                        fontWeight: isOverdue ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                const Divider(height: 1, color: AppColors.border),
                SizedBox(height: 8.h),

                // Financial Summary Row: Total Amount & Balance Due
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Total Amount', style: AppTextStyles.caption),
                        Text(
                          CurrencyFormatter.format(invoice.totalAmount),
                          style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Balance Due', style: AppTextStyles.caption),
                        Text(
                          CurrencyFormatter.format(invoice.balanceAmount),
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.w700,
                            color: invoice.balanceAmount > 0 ? AppColors.outstanding : AppColors.received,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InvoiceStatusBadge extends StatelessWidget {
  final String status;

  const _InvoiceStatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg = AppColors.background;
    Color fg = AppColors.textSecondary;

    switch (status) {
      case 'PAID':
        bg = AppColors.receivedLight;
        fg = AppColors.received;
        break;
      case 'PARTIAL':
        bg = AppColors.partialLight;
        fg = AppColors.partial;
        break;
      case 'UNPAID':
        bg = AppColors.outstandingLight;
        fg = AppColors.outstanding;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: fg.withValues(alpha: 0.4)),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }
}
