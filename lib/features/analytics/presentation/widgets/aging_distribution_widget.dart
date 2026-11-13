import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../models/aging_report_model.dart';

class AgingDistributionWidget extends StatelessWidget {
  final AgingReport aging;

  const AgingDistributionWidget({super.key, required this.aging});

  @override
  Widget build(BuildContext context) {
    final total = aging.totalAgingOutstanding > 0 ? aging.totalAgingOutstanding : 1.0;
    final p1 = (aging.bucket0To30 / total).clamp(0.0, 1.0);
    final p2 = (aging.bucket31To60 / total).clamp(0.0, 1.0);
    final p3 = (aging.bucket60Plus / total).clamp(0.0, 1.0);

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
              Text('Receivables Aging', style: AppTextStyles.h3),
              Text(
                'Total: ${CurrencyFormatter.formatCompact(aging.totalAgingOutstanding)}',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.outstanding,
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),

          // Proportional Multi-color Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: SizedBox(
              height: 12.h,
              child: Row(
                children: [
                  if (p1 > 0)
                    Expanded(
                      flex: (p1 * 100).toInt().clamp(1, 100),
                      child: Container(color: AppColors.received),
                    ),
                  if (p2 > 0)
                    Expanded(
                      flex: (p2 * 100).toInt().clamp(1, 100),
                      child: Container(color: AppColors.partial),
                    ),
                  if (p3 > 0)
                    Expanded(
                      flex: (p3 * 100).toInt().clamp(1, 100),
                      child: Container(color: AppColors.overdue),
                    ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16.h),

          // 3 Aging Bucket Cards
          Row(
            children: [
              Expanded(
                child: _BucketCard(
                  title: '0 - 30 Days',
                  amount: aging.bucket0To30,
                  label: 'Current',
                  color: AppColors.received,
                  bgColor: AppColors.receivedLight,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _BucketCard(
                  title: '31 - 60 Days',
                  amount: aging.bucket31To60,
                  label: 'Moderate',
                  color: AppColors.partial,
                  bgColor: AppColors.partialLight,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _BucketCard(
                  title: '60+ Days',
                  amount: aging.bucket60Plus,
                  label: 'Critical',
                  color: AppColors.overdue,
                  bgColor: AppColors.outstandingLight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BucketCard extends StatelessWidget {
  final String title;
  final double amount;
  final String label;
  final Color color;
  final Color bgColor;

  const _BucketCard({
    required this.title,
    required this.amount,
    required this.label,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600)),
              Container(
                width: 6.w,
                height: 6.w,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            CurrencyFormatter.formatCompact(amount),
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 2.h),
          Text(label, style: AppTextStyles.caption.copyWith(fontSize: 9.sp, color: color)),
        ],
      ),
    );
  }
}

