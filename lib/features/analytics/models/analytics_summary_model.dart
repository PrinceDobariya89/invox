class AnalyticsSummary {
  final double totalBilled;
  final double totalCollected;
  final double totalOutstanding;
  final double overdueAmount;
  final int totalInvoicesCount;
  final int unpaidInvoicesCount;

  AnalyticsSummary({
    required this.totalBilled,
    required this.totalCollected,
    required this.totalOutstanding,
    required this.overdueAmount,
    this.totalInvoicesCount = 0,
    this.unpaidInvoicesCount = 0,
  });

  double get collectionRate =>
      totalBilled > 0 ? (totalCollected / totalBilled) * 100 : 0.0;

  factory AnalyticsSummary.fromJson(Map<String, dynamic> json) {
    return AnalyticsSummary(
      totalBilled: (json['total_billed'] as num?)?.toDouble() ?? 0.0,
      totalCollected: (json['total_collected'] as num?)?.toDouble() ?? 0.0,
      totalOutstanding: (json['total_outstanding'] as num?)?.toDouble() ?? 0.0,
      overdueAmount: (json['overdue_amount'] as num?)?.toDouble() ?? 0.0,
      totalInvoicesCount: (json['total_invoices_count'] as num?)?.toInt() ?? 0,
      unpaidInvoicesCount: (json['unpaid_invoices_count'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_billed': totalBilled,
      'total_collected': totalCollected,
      'total_outstanding': totalOutstanding,
      'overdue_amount': overdueAmount,
      'total_invoices_count': totalInvoicesCount,
      'unpaid_invoices_count': unpaidInvoicesCount,
    };
  }
}

