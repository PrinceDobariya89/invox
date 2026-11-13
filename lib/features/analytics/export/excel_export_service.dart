import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:printing/printing.dart';
import '../models/aging_report_model.dart';
import '../models/analytics_summary_model.dart';
import '../models/yearly_analytics_model.dart';

class ExcelExportService {
  static Future<void> exportYearlyReport({
    required int year,
    required AnalyticsSummary summary,
    required YearlyAnalytics yearly,
    required AgingReport aging,
  }) async {
    final excel = Excel.createExcel();
    final defaultSheet = excel.getDefaultSheet();
    if (defaultSheet != null) {
      excel.delete(defaultSheet);
    }

    // 1. Sheet: Executive Summary
    final Sheet summarySheet = excel['Executive Summary'];
    summarySheet.appendRow(['INVOX EXECUTIVE FINANCIAL SUMMARY', '']);
    summarySheet.appendRow(['Report Period (Year)', year]);
    summarySheet.appendRow(['Generated On', DateTime.now().toIso8601String()]);
    summarySheet.appendRow(['']);
    summarySheet.appendRow(['Metric', 'Amount (INR)']);
    summarySheet.appendRow(['Total Billed', summary.totalBilled]);
    summarySheet.appendRow(['Total Collected', summary.totalCollected]);
    summarySheet.appendRow(['Total Outstanding', summary.totalOutstanding]);
    summarySheet.appendRow(['Overdue Amount', summary.overdueAmount]);
    summarySheet.appendRow(['Collection Efficiency (%)', '${summary.collectionRate.toStringAsFixed(1)}%']);
    summarySheet.appendRow(['Total Invoices Count', summary.totalInvoicesCount]);

    // 2. Sheet: 12-Month Cashflow
    final Sheet cashflowSheet = excel['Monthly Performance'];
    cashflowSheet.appendRow(['Month #', 'Month Name', 'Billed (INR)', 'Collected (INR)', 'Outstanding (INR)']);
    for (final m in yearly.trends) {
      cashflowSheet.appendRow([
        m.month,
        m.monthName,
        m.billed,
        m.collected,
        m.outstanding,
      ]);
    }

    // 3. Sheet: Accounts Receivable Aging
    final Sheet agingSheet = excel['Aging Analysis'];
    agingSheet.appendRow(['Aging Bucket', 'Outstanding Amount (INR)', 'Risk Category']);
    agingSheet.appendRow(['0 - 30 Days', aging.bucket0To30, 'Current / Healthy']);
    agingSheet.appendRow(['31 - 60 Days', aging.bucket31To60, 'Moderate Risk / Follow-up']);
    agingSheet.appendRow(['60+ Days', aging.bucket60Plus, 'High Risk / Immediate Action']);
    agingSheet.appendRow(['Total Aging Outstanding', aging.totalAgingOutstanding, '']);

    final fileBytes = excel.encode();
    if (fileBytes != null) {
      await Printing.sharePdf(
        bytes: Uint8List.fromList(fileBytes),
        filename: 'Invox_Annual_Financial_Summary_$year.xlsx',
      );
    }
  }
}

