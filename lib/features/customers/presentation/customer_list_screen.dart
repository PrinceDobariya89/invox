import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/responsive.dart';
import '../models/customer_model.dart';
import '../providers/customer_providers.dart';
import 'widgets/add_customer_dialog.dart';

class CustomerListScreen extends ConsumerStatefulWidget {
  const CustomerListScreen({super.key});

  @override
  ConsumerState<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends ConsumerState<CustomerListScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openAddCustomerDialog() {
    showDialog<Customer>(
      context: context,
      builder: (_) => const AddCustomerDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final customersAsync = ref.watch(customerListProvider);
    final isDesktopOrTablet = context.isDesktopOrTablet;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Customer Directory', style: AppTextStyles.h2),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.textPrimary),
            tooltip: 'Refresh',
            onPressed: () => ref.read(customerListProvider.notifier).refresh(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: isDesktopOrTablet
          ? null
          : FloatingActionButton.extended(
              onPressed: _openAddCustomerDialog,
              backgroundColor: AppColors.primary,
              icon: const Icon(Icons.person_add_alt_1, color: Colors.white),
              label: Text('New Customer', style: AppTextStyles.button),
            ),
      body: Column(
        children: [
          // Search & Filter Header
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktopOrTablet ? 24.0 : 16.w,
              vertical: isDesktopOrTablet ? 16.0 : 12.h,
            ),
            color: AppColors.surface,
            child: ResponsiveCenter(
              maxWidth: 1360,
              child: isDesktopOrTablet
                  ? Row(
                      children: [
                        SizedBox(
                          width: 360,
                          child: TextField(
                            controller: _searchController,
                            onChanged: (val) {
                              ref.read(customerSearchQueryProvider.notifier).state = val;
                            },
                            decoration: InputDecoration(
                              hintText: 'Search customer name or phone...',
                              hintStyle: AppTextStyles.bodySmall,
                              prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary, size: 20),
                              suffixIcon: _searchController.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear, size: 18),
                                      onPressed: () {
                                        _searchController.clear();
                                        ref.read(customerSearchQueryProvider.notifier).state = '';
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
                        const Spacer(),
                        ElevatedButton.icon(
                          onPressed: _openAddCustomerDialog,
                          icon: const Icon(Icons.person_add_alt_1, color: Colors.white, size: 18),
                          label: const Text(
                            'New Customer',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ],
                    )
                  : TextField(
                      controller: _searchController,
                      onChanged: (val) {
                        ref.read(customerSearchQueryProvider.notifier).state = val;
                      },
                      decoration: InputDecoration(
                        hintText: 'Search by customer name or phone...',
                        hintStyle: AppTextStyles.bodySmall,
                        prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  ref.read(customerSearchQueryProvider.notifier).state = '';
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: AppColors.background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                      ),
                    ),
            ),
          ),
          const Divider(height: 1, color: AppColors.border),

          // Customers List / Grid
          Expanded(
            child: customersAsync.when(
              data: (customers) {
                if (customers.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.people_outline, size: isDesktopOrTablet ? 56 : 64.sp, color: AppColors.textMuted),
                        const SizedBox(height: 12),
                        Text('No customers found', style: AppTextStyles.h3),
                        const SizedBox(height: 6),
                        Text(
                          'Add your first customer to start invoicing',
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => ref.read(customerListProvider.notifier).refresh(),
                  child: ResponsiveCenter(
                    maxWidth: 1360,
                    padding: EdgeInsets.symmetric(
                      horizontal: isDesktopOrTablet ? 24.0 : 16.w,
                      vertical: isDesktopOrTablet ? 20.0 : 16.h,
                    ),
                    child: isDesktopOrTablet
                        ? GridView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: customers.length,
                            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 460,
                              mainAxisExtent: 180,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                            itemBuilder: (context, index) {
                              return _CustomerCard(customer: customers[index], isGrid: true);
                            },
                          )
                        : ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: customers.length,
                            itemBuilder: (context, index) {
                              return _CustomerCard(customer: customers[index], isGrid: false);
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
                    Text('Failed to load customers: $err', style: AppTextStyles.bodyMedium),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => ref.read(customerListProvider.notifier).refresh(),
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

class _CustomerCard extends StatelessWidget {
  final Customer customer;
  final bool isGrid;

  const _CustomerCard({required this.customer, this.isGrid = false});

  @override
  Widget build(BuildContext context) {
    final hasOutstanding = customer.outstandingBalance > 0;

    return Container(
      margin: EdgeInsets.only(bottom: isGrid ? 0 : 12.h),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: hasOutstanding
              ? AppColors.outstanding.withValues(alpha: 0.3)
              : AppColors.border,
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
            context.push('/customers/${customer.id}');
          },
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top Row: Avatar + Name + Outstanding Chip
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 20.r,
                      backgroundColor: AppColors.primarySurface,
                      child: Text(
                        customer.name.isNotEmpty ? customer.name[0].toUpperCase() : 'C',
                        style: AppTextStyles.h3.copyWith(color: AppColors.primary),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            customer.name,
                            style: AppTextStyles.h3,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            customer.phone.isNotEmpty ? customer.phone : 'No phone provided',
                            style: AppTextStyles.bodySmall,
                          ),
                        ],
                      ),
                    ),

                    // Prominent Outstanding Balance Chip
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: hasOutstanding ? AppColors.outstandingLight : AppColors.receivedLight,
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(
                          color: hasOutstanding
                              ? AppColors.outstanding.withValues(alpha: 0.5)
                              : AppColors.received.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            hasOutstanding ? 'OUTSTANDING' : 'SETTLED',
                            style: AppTextStyles.caption.copyWith(
                              fontSize: 9.sp,
                              fontWeight: FontWeight.w700,
                              color: hasOutstanding ? AppColors.outstanding : AppColors.received,
                            ),
                          ),
                          Text(
                            CurrencyFormatter.formatCompact(customer.outstandingBalance),
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.w700,
                              color: hasOutstanding ? AppColors.outstanding : AppColors.received,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                const Divider(height: 1, color: AppColors.border),
                SizedBox(height: 10.h),

                // Bottom Row: Location + Billed vs Paid
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (customer.address.isNotEmpty)
                      Expanded(
                        child: Row(
                          children: [
                            Icon(Icons.location_on_outlined, size: 14.sp, color: AppColors.textSecondary),
                            SizedBox(width: 4.w),
                            Expanded(
                              child: Text(
                                customer.address,
                                style: AppTextStyles.caption,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      const Spacer(),
                    Row(
                      children: [
                        Text('Billed: ', style: AppTextStyles.caption),
                        Text(
                          CurrencyFormatter.formatCompact(customer.totalBilled),
                          style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600),
                        ),
                        SizedBox(width: 8.w),
                        Text('•', style: AppTextStyles.caption),
                        SizedBox(width: 8.w),
                        Text('Paid: ', style: AppTextStyles.caption),
                        Text(
                          CurrencyFormatter.formatCompact(customer.totalPaid),
                          style: AppTextStyles.bodySmall.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.received,
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
