class MonthTrend {
  final int month;
  final String monthName;
  final double billed;
  final double collected;
  final double outstanding;

  MonthTrend({
    required this.month,
    required this.monthName,
    required this.billed,
    required this.collected,
    required this.outstanding,
  });

  factory MonthTrend.fromJson(Map<String, dynamic> json) {
    return MonthTrend(
      month: (json['month'] as num?)?.toInt() ?? 1,
      monthName: json['month_name']?.toString() ?? 'M',
      billed: (json['billed'] as num?)?.toDouble() ?? 0.0,
      collected: (json['collected'] as num?)?.toDouble() ?? 0.0,
      outstanding: (json['outstanding'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'month': month,
      'month_name': monthName,
      'billed': billed,
      'collected': collected,
      'outstanding': outstanding,
    };
  }
}

class YearlyAnalytics {
  final int year;
  final List<MonthTrend> trends;

  YearlyAnalytics({
    required this.year,
    required this.trends,
  });

  factory YearlyAnalytics.fromJson(Map<String, dynamic> json) {
    final rawTrends = json['trends'] as List? ?? [];
    return YearlyAnalytics(
      year: (json['year'] as num?)?.toInt() ?? 2026,
      trends: rawTrends.map((e) => MonthTrend.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'year': year,
      'trends': trends.map((e) => e.toJson()).toList(),
    };
  }
}

