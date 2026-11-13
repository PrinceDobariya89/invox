import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';

class KpiSummaryCard extends StatelessWidget {
  final String title;
  final double amount;
  final Color primaryColor;
  final Color backgroundColor;
  final IconData icon;
  final String? subtitle;

  const KpiSummaryCard({
    super.key,
    required this.title,
    required this.amount,
    required this.primaryColor,
    required this.backgroundColor,
    required this.icon,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: primaryColor.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title.toUpperCase(),
                style: AppTextStyles.caption.copyWith(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w700,
                  color: primaryColor,
                  letterSpacing: 0.5,
                ),
              ),
              Container(
                padding: EdgeInsets.all(6.w),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: primaryColor, size: 16.sp),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            CurrencyFormatter.format(amount),
            style: AppTextStyles.currencyLarge.copyWith(
              color: primaryColor,
              fontSize: 18.sp,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (subtitle != null) ...[
            SizedBox(height: 2.h),
            Text(
              subtitle!,
              style: AppTextStyles.caption.copyWith(
                color: primaryColor.withValues(alpha: 0.8),
                fontSize: 9.sp,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
