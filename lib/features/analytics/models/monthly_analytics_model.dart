class MonthlyAnalytics {
  final int year;
  final int month;
  final double sales;
  final double collections;
  final int pendingInvoicesCount;
  final double pendingAmount;
  final int paidInvoicesCount;

  MonthlyAnalytics({
    required this.year,
    required this.month,
    required this.sales,
    required this.collections,
    required this.pendingInvoicesCount,
    required this.pendingAmount,
    required this.paidInvoicesCount,
  });

  factory MonthlyAnalytics.fromJson(Map<String, dynamic> json) {
    return MonthlyAnalytics(
      year: (json['year'] as num?)?.toInt() ?? 2026,
      month: (json['month'] as num?)?.toInt() ?? 1,
      sales: (json['sales'] as num?)?.toDouble() ?? 0.0,
      collections: (json['collections'] as num?)?.toDouble() ?? 0.0,
      pendingInvoicesCount: (json['pending_invoices_count'] as num?)?.toInt() ?? 0,
      pendingAmount: (json['pending_amount'] as num?)?.toDouble() ?? 0.0,
      paidInvoicesCount: (json['paid_invoices_count'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'year': year,
      'month': month,
      'sales': sales,
      'collections': collections,
      'pending_invoices_count': pendingInvoicesCount,
      'pending_amount': pendingAmount,
      'paid_invoices_count': paidInvoicesCount,
    };
  }
}

