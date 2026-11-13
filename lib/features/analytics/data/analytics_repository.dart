import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../models/aging_report_model.dart';
import '../models/analytics_summary_model.dart';
import '../models/monthly_analytics_model.dart';
import '../models/yearly_analytics_model.dart';

class AnalyticsRepository {
  final ApiClient apiClient;

  AnalyticsRepository(this.apiClient);

  Future<AnalyticsSummary> getSummary() async {
    final response = await apiClient.get(ApiEndpoints.analyticsSummary);
    return AnalyticsSummary.fromJson(response as Map<String, dynamic>);
  }

  Future<MonthlyAnalytics> getMonthly({required int year, required int month}) async {
    final response = await apiClient.get(
      ApiEndpoints.analyticsMonthly,
      queryParameters: {
        'year': year,
        'month': month.toString().padLeft(2, '0'),
      },
    );
    return MonthlyAnalytics.fromJson(response as Map<String, dynamic>);
  }

  Future<YearlyAnalytics> getYearly({required int year}) async {
    final response = await apiClient.get(
      ApiEndpoints.analyticsYearly,
      queryParameters: {'year': year},
    );
    return YearlyAnalytics.fromJson(response as Map<String, dynamic>);
  }

  Future<AgingReport> getAgingReport() async {
    final response = await apiClient.get(ApiEndpoints.analyticsAging);
    return AgingReport.fromJson(response as Map<String, dynamic>);
  }
}

