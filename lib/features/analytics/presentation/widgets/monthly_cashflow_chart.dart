import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../models/monthly_analytics_model.dart';

class MonthlyCashflowChart extends StatelessWidget {
  final MonthlyAnalytics monthly;

  const MonthlyCashflowChart({super.key, required this.monthly});

  @override
  Widget build(BuildContext context) {
    final double maxVal = (monthly.sales > monthly.collections ? monthly.sales : monthly.collections) * 1.25;
    final effectiveMax = maxVal == 0 ? 100000.0 : maxVal;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Cashflow Comparison', style: AppTextStyles.h3),
              Row(
                children: [
                  const _Indicator(color: AppColors.billed, text: 'Billed'),
                  SizedBox(width: 12.w),
                  const _Indicator(color: AppColors.received, text: 'Collected'),
                ],
              ),
            ],
          ),
          SizedBox(height: 18.h),

          // Chart
          SizedBox(
            height: 160.h,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.center,
                maxY: effectiveMax,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final isBilled = rodIndex == 0;
                      return BarTooltipItem(
                        '${isBilled ? "Billed" : "Collected"}\n${CurrencyFormatter.format(rod.toY)}',
                        TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 11.sp,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 45.w,
                      getTitlesWidget: (value, meta) {
                        if (value == 0 || value == effectiveMax) return const SizedBox.shrink();
                        return Text(
                          CurrencyFormatter.formatShort(value),
                          style: AppTextStyles.caption.copyWith(fontSize: 9.sp),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Padding(
                          padding: EdgeInsets.only(top: 8.h),
                          child: Text(
                            'Month ${monthly.month}/${monthly.year}',
                            style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => const FlLine(
                    color: AppColors.border,
                    strokeWidth: 0.8,
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: [
                  BarChartGroupData(
                    x: 0,
                    barsSpace: 12.w,
                    barRods: [
                      BarChartRodData(
                        toY: monthly.sales,
                        color: AppColors.billed,
                        width: 24.w,
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      BarChartRodData(
                        toY: monthly.collections,
                        color: AppColors.received,
                        width: 24.w,
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 12.h),

          // Monthly Key Stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatMini(
                label: 'Pending Invoices',
                value: '${monthly.pendingInvoicesCount} Invoices',
                color: AppColors.outstanding,
              ),
              _StatMini(
                label: 'Pending Amount',
                value: CurrencyFormatter.formatCompact(monthly.pendingAmount),
                color: AppColors.outstanding,
              ),
              _StatMini(
                label: 'Settled Invoices',
                value: '${monthly.paidInvoicesCount} Invoices',
                color: AppColors.received,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Indicator extends StatelessWidget {
  final Color color;
  final String text;

  const _Indicator({required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10.w,
          height: 10.w,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: 4.w),
        Text(text, style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _StatMini extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatMini({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: AppTextStyles.caption),
        SizedBox(height: 2.h),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w700, color: color),
        ),
      ],
    );
  }
}

