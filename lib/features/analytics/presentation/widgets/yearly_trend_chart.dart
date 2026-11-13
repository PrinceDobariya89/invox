import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../models/yearly_analytics_model.dart';

class YearlyTrendChart extends StatelessWidget {
  final YearlyAnalytics yearly;

  const YearlyTrendChart({super.key, required this.yearly});

  @override
  Widget build(BuildContext context) {
    if (yearly.trends.isEmpty) {
      return const SizedBox.shrink();
    }

    final billedSpots = <FlSpot>[];
    final collectedSpots = <FlSpot>[];
    double maxVal = 0.0;

    for (int i = 0; i < yearly.trends.length; i++) {
      final t = yearly.trends[i];
      billedSpots.add(FlSpot(i.toDouble(), t.billed));
      collectedSpots.add(FlSpot(i.toDouble(), t.collected));
      maxVal = max(maxVal, max(t.billed, t.collected));
    }

    final double effectiveMaxY = (maxVal * 1.25) > 0 ? (maxVal * 1.25) : 500000.0;

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
              Text('Annual Trends (${yearly.year})', style: AppTextStyles.h3),
              Row(
                children: [
                  const _Legend(color: AppColors.primary, label: 'Billed'),
                  SizedBox(width: 12.w),
                  const _Legend(color: AppColors.received, label: 'Collected'),
                ],
              ),
            ],
          ),
          SizedBox(height: 20.h),

          // Line Chart
          SizedBox(
            height: 190.h,
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: effectiveMaxY,
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        final isBilled = spot.barIndex == 0;
                        final monthIdx = spot.x.toInt();
                        final monthName = monthIdx < yearly.trends.length
                            ? yearly.trends[monthIdx].monthName
                            : '';
                        return LineTooltipItem(
                          '$monthName ${isBilled ? "Billed" : "Collected"}\n${CurrencyFormatter.formatCompact(spot.y)}',
                          TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 10.sp,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => const FlLine(
                    color: AppColors.border,
                    strokeWidth: 0.8,
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 45.w,
                      getTitlesWidget: (value, meta) {
                        if (value == 0 || value == effectiveMaxY) return const SizedBox.shrink();
                        return Text(
                          CurrencyFormatter.formatShort(value),
                          style: AppTextStyles.caption.copyWith(fontSize: 8.sp),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx >= 0 && idx < yearly.trends.length) {
                          // Display every 2nd month if compact
                          if (idx % 2 == 0) {
                            return Padding(
                              padding: EdgeInsets.only(top: 6.h),
                              child: Text(
                                yearly.trends[idx].monthName,
                                style: AppTextStyles.caption.copyWith(fontSize: 9.sp),
                              ),
                            );
                          }
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
                lineBarsData: [
                  // Billed Line
                  LineChartBarData(
                    spots: billedSpots,
                    isCurved: true,
                    color: AppColors.primary,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.primary.withValues(alpha: 0.08),
                    ),
                  ),
                  // Collected Line
                  LineChartBarData(
                    spots: collectedSpots,
                    isCurved: true,
                    color: AppColors.received,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.received.withValues(alpha: 0.08),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;

  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12.w,
          height: 3.h,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2.r)),
        ),
        SizedBox(width: 4.w),
        Text(label, style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }
}

