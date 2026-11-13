import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_provider.dart';
import '../data/analytics_repository.dart';
import '../models/aging_report_model.dart';
import '../models/analytics_summary_model.dart';
import '../models/monthly_analytics_model.dart';
import '../models/yearly_analytics_model.dart';

final analyticsRepositoryProvider = Provider<AnalyticsRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  return AnalyticsRepository(client);
});

final selectedAnalyticsYearProvider = StateProvider<int>((ref) => DateTime.now().year);
final selectedAnalyticsMonthProvider = StateProvider<int>((ref) => DateTime.now().month);

final analyticsSummaryProvider = FutureProvider<AnalyticsSummary>((ref) async {
  final repo = ref.watch(analyticsRepositoryProvider);
  return repo.getSummary();
});

final monthlyAnalyticsProvider = FutureProvider<MonthlyAnalytics>((ref) async {
  final repo = ref.watch(analyticsRepositoryProvider);
  final year = ref.watch(selectedAnalyticsYearProvider);
  final month = ref.watch(selectedAnalyticsMonthProvider);
  return repo.getMonthly(year: year, month: month);
});

final yearlyAnalyticsProvider = FutureProvider<YearlyAnalytics>((ref) async {
  final repo = ref.watch(analyticsRepositoryProvider);
  final year = ref.watch(selectedAnalyticsYearProvider);
  return repo.getYearly(year: year);
});

final agingReportProvider = FutureProvider<AgingReport>((ref) async {
  final repo = ref.watch(analyticsRepositoryProvider);
  return repo.getAgingReport();
});

