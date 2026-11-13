import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:printing/printing.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/responsive.dart';
import '../../auth/providers/auth_provider.dart';
import '../export/excel_export_service.dart';
import '../export/financial_report_pdf_builder.dart';
import '../models/analytics_summary_model.dart';
import '../providers/analytics_providers.dart';
import 'widgets/aging_distribution_widget.dart';
import 'widgets/kpi_summary_card.dart';
import 'widgets/monthly_cashflow_chart.dart';
import 'widgets/yearly_trend_chart.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final List<String> _monthNames = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  Future<void> _exportExcel() async {
    final summary = await ref.read(analyticsSummaryProvider.future);
    final yearly = await ref.read(yearlyAnalyticsProvider.future);
    final aging = await ref.read(agingReportProvider.future);
    final year = ref.read(selectedAnalyticsYearProvider);

    await ExcelExportService.exportYearlyReport(
      year: year,
      summary: summary,
      yearly: yearly,
      aging: aging,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Excel summary exported successfully!'),
          backgroundColor: AppColors.received,
        ),
      );
    }
  }

  Future<void> _exportPdf() async {
    final summary = await ref.read(analyticsSummaryProvider.future);
    final yearly = await ref.read(yearlyAnalyticsProvider.future);
    final aging = await ref.read(agingReportProvider.future);
    final year = ref.read(selectedAnalyticsYearProvider);

    final pdfBytes = await FinancialReportPdfBuilder.buildPdf(
      year: year,
      summary: summary,
      yearly: yearly,
      aging: aging,
    );

    await Printing.sharePdf(
      bytes: pdfBytes,
      filename: 'Invox_Financial_Report_$year.pdf',
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).value;
    final summaryAsync = ref.watch(analyticsSummaryProvider);
    final monthlyAsync = ref.watch(monthlyAnalyticsProvider);
    final yearlyAsync = ref.watch(yearlyAnalyticsProvider);
    final agingAsync = ref.watch(agingReportProvider);

    final selectedYear = ref.watch(selectedAnalyticsYearProvider);
    final selectedMonth = ref.watch(selectedAnalyticsMonthProvider);
    final isDesktopOrTablet = context.isDesktopOrTablet;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Invox Cashflow', style: AppTextStyles.h2),
            Text(
              user?.businessName ?? 'Invox Tech Enterprises',
              style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          if (isDesktopOrTablet) ...[
            OutlinedButton.icon(
              onPressed: _exportExcel,
              icon: const Icon(Icons.table_chart_outlined, color: AppColors.received, size: 18),
              label: const Text('Export Excel', style: TextStyle(color: AppColors.received, fontWeight: FontWeight.w600)),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.received.withValues(alpha: 0.4)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton.icon(
              onPressed: _exportPdf,
              icon: const Icon(Icons.picture_as_pdf_outlined, color: Colors.white, size: 18),
              label: const Text('Export PDF', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              ),
            ),
            const SizedBox(width: 14),
          ] else ...[
            PopupMenuButton<String>(
              icon: const Icon(Icons.file_download_outlined, color: AppColors.primary),
              tooltip: 'Export Financial Reports',
              onSelected: (val) {
                if (val == 'excel') {
                  _exportExcel();
                } else if (val == 'pdf') {
                  _exportPdf();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'excel',
                  child: Row(
                    children: [
                      Icon(Icons.table_chart_outlined, color: AppColors.received, size: 20),
                      SizedBox(width: 10),
                      Text('Export to Excel (.xlsx)'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'pdf',
                  child: Row(
                    children: [
                      Icon(Icons.picture_as_pdf_outlined, color: AppColors.primary, size: 20),
                      SizedBox(width: 10),
                      Text('Export Executive PDF'),
                    ],
                  ),
                ),
              ],
            ),
          ],
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.textSecondary),
            tooltip: 'Logout',
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) context.go('/login');
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(analyticsSummaryProvider);
          ref.invalidate(monthlyAnalyticsProvider);
          ref.invalidate(yearlyAnalyticsProvider);
          ref.invalidate(agingReportProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ResponsiveCenter(
            maxWidth: 1360,
            padding: EdgeInsets.symmetric(
              horizontal: isDesktopOrTablet ? 24.0 : 16.w,
              vertical: isDesktopOrTablet ? 24.0 : 16.h,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top 4 Summary Cards (Responsive: 1 row on Desktop/Tablet, 2x2 on Mobile)
                summaryAsync.when(
                  data: (summary) => _buildResponsiveKpis(summary, isDesktopOrTablet),
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  error: (e, _) => Center(child: Text('Error loading summary: $e')),
                ),
                SizedBox(height: isDesktopOrTablet ? 28.0 : 24.h),

                // Responsive Charts Section
                if (isDesktopOrTablet) ...[
                  // Tablet & Desktop: Side-by-Side 2-Column Analytics
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Column 1: Monthly Performance & Cashflow
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildMonthSelectorHeader(selectedYear),
                            const SizedBox(height: 10),
                            _buildMonthChips(selectedMonth),
                            const SizedBox(height: 14),
                            monthlyAsync.when(
                              data: (monthly) => MonthlyCashflowChart(monthly: monthly),
                              loading: () => const SizedBox(
                                height: 260,
                                child: Center(child: CircularProgressIndicator()),
                              ),
                              error: (e, _) => Text('Error loading monthly cashflow: $e'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),

                      // Column 2: Annual Trends Chart
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Performance Trends', style: AppTextStyles.h3),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.primarySurface,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '12-Month',
                                    style: AppTextStyles.caption.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            yearlyAsync.when(
                              data: (yearly) => YearlyTrendChart(yearly: yearly),
                              loading: () => const SizedBox(
                                height: 260,
                                child: Center(child: CircularProgressIndicator()),
                              ),
                              error: (e, _) => Text('Error loading annual trends: $e'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  // Mobile: Vertical Stacked Analytics
                  _buildMonthSelectorHeader(selectedYear),
                  SizedBox(height: 10.h),
                  _buildMonthChips(selectedMonth),
                  SizedBox(height: 14.h),
                  monthlyAsync.when(
                    data: (monthly) => MonthlyCashflowChart(monthly: monthly),
                    loading: () => SizedBox(
                      height: 160.h,
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    error: (e, _) => Text('Error loading monthly cashflow: $e'),
                  ),
                  SizedBox(height: 24.h),
                  yearlyAsync.when(
                    data: (yearly) => YearlyTrendChart(yearly: yearly),
                    loading: () => SizedBox(
                      height: 190.h,
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    error: (e, _) => Text('Error loading annual trends: $e'),
                  ),
                ],
                SizedBox(height: isDesktopOrTablet ? 28.0 : 24.h),

                // Accounts Receivable Aging Report (Full Width)
                agingAsync.when(
                  data: (aging) => AgingDistributionWidget(aging: aging),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Text('Error loading aging data: $e'),
                ),
                SizedBox(height: isDesktopOrTablet ? 40.0 : 30.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResponsiveKpis(AnalyticsSummary summary, bool isDesktopOrTablet) {
    if (isDesktopOrTablet) {
      return Row(
        children: [
          Expanded(
            child: KpiSummaryCard(
              title: 'Billed',
              amount: summary.totalBilled,
              primaryColor: AppColors.billed,
              backgroundColor: AppColors.billedLight,
              icon: Icons.receipt_long,
              subtitle: '${summary.totalInvoicesCount} Invoices',
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: KpiSummaryCard(
              title: 'Received',
              amount: summary.totalCollected,
              primaryColor: AppColors.received,
              backgroundColor: AppColors.receivedLight,
              icon: Icons.check_circle_outline,
              subtitle: '${summary.collectionRate.toStringAsFixed(0)}% Rate',
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: KpiSummaryCard(
              title: 'Outstanding',
              amount: summary.totalOutstanding,
              primaryColor: AppColors.outstanding,
              backgroundColor: AppColors.outstandingLight,
              icon: Icons.pending_actions,
              subtitle: '${summary.unpaidInvoicesCount} Pending',
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: KpiSummaryCard(
              title: 'Overdue',
              amount: summary.overdueAmount,
              primaryColor: AppColors.overdue,
              backgroundColor: AppColors.outstandingLight,
              icon: Icons.warning_amber_rounded,
              subtitle: 'Needs Attention',
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: KpiSummaryCard(
                title: 'Billed',
                amount: summary.totalBilled,
                primaryColor: AppColors.billed,
                backgroundColor: AppColors.billedLight,
                icon: Icons.receipt_long,
                subtitle: '${summary.totalInvoicesCount} Invoices',
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: KpiSummaryCard(
                title: 'Received',
                amount: summary.totalCollected,
                primaryColor: AppColors.received,
                backgroundColor: AppColors.receivedLight,
                icon: Icons.check_circle_outline,
                subtitle: '${summary.collectionRate.toStringAsFixed(0)}% Rate',
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: KpiSummaryCard(
                title: 'Outstanding',
                amount: summary.totalOutstanding,
                primaryColor: AppColors.outstanding,
                backgroundColor: AppColors.outstandingLight,
                icon: Icons.pending_actions,
                subtitle: '${summary.unpaidInvoicesCount} Pending',
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: KpiSummaryCard(
                title: 'Overdue',
                amount: summary.overdueAmount,
                primaryColor: AppColors.overdue,
                backgroundColor: AppColors.outstandingLight,
                icon: Icons.warning_amber_rounded,
                subtitle: 'Needs Attention',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMonthSelectorHeader(int selectedYear) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Monthly Performance', style: AppTextStyles.h3),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primarySurface,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'Year $selectedYear',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMonthChips(int selectedMonth) {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 12,
        itemBuilder: (context, idx) {
          final monthNum = idx + 1;
          final isSelected = selectedMonth == monthNum;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(_monthNames[idx]),
              selected: isSelected,
              selectedColor: AppColors.primary,
              labelStyle: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
              onSelected: (selected) {
                if (selected) {
                  ref.read(selectedAnalyticsMonthProvider.notifier).state = monthNum;
                }
              },
            ),
          );
        },
      ),
    );
  }
}
