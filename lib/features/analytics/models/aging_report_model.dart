class AgingReport {
  final double bucket0To30; // 0-30 days (Current)
  final double bucket31To60; // 31-60 days (Moderate Risk)
  final double bucket60Plus; // 60+ days (High Risk / Overdue)
  final double totalAgingOutstanding;

  AgingReport({
    required this.bucket0To30,
    required this.bucket31To60,
    required this.bucket60Plus,
    required this.totalAgingOutstanding,
  });

  factory AgingReport.fromJson(Map<String, dynamic> json) {
    final b1 = (json['bucket_0_30'] as num?)?.toDouble() ?? 0.0;
    final b2 = (json['bucket_31_60'] as num?)?.toDouble() ?? 0.0;
    final b3 = (json['bucket_60_plus'] as num?)?.toDouble() ?? 0.0;
    final total = (json['total_aging_outstanding'] as num?)?.toDouble() ?? (b1 + b2 + b3);

    return AgingReport(
      bucket0To30: b1,
      bucket31To60: b2,
      bucket60Plus: b3,
      totalAgingOutstanding: total,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bucket_0_30': bucket0To30,
      'bucket_31_60': bucket31To60,
      'bucket_60_plus': bucket60Plus,
      'total_aging_outstanding': totalAgingOutstanding,
    };
  }
}

