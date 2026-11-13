import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../../core/utils/currency_formatter.dart';
import '../models/aging_report_model.dart';
import '../models/analytics_summary_model.dart';
import '../models/yearly_analytics_model.dart';

class FinancialReportPdfBuilder {
  static Future<Uint8List> buildPdf({
    required int year,
    required AnalyticsSummary summary,
    required YearlyAnalytics yearly,
    required AgingReport aging,
  }) async {
    final pdf = pw.Document();

    final fontRegular = await PdfGoogleFonts.poppinsRegular();
    final fontBold = await PdfGoogleFonts.poppinsBold();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        theme: pw.ThemeData.withFont(
          base: fontRegular,
          bold: fontBold,
        ),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'INVOX FINANCIAL INTELLIGENCE',
                        style: pw.TextStyle(
                          font: fontBold,
                          fontSize: 16,
                          color: PdfColor.fromHex('#4338CA'),
                        ),
                      ),
                      pw.Text('Executive Cashflow & Outstanding Summary',
                          style: const pw.TextStyle(
                              fontSize: 10, color: PdfColors.grey600)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('ANNUAL REPORT $year',
                          style: pw.TextStyle(font: fontBold, fontSize: 14)),
                      pw.Text(
                          'Generated: ${DateTime.now().toLocal().toString().split('.').first}',
                          style: const pw.TextStyle(
                              fontSize: 8, color: PdfColors.grey600)),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 14),
              pw.Divider(color: PdfColors.grey300),
              pw.SizedBox(height: 12),

              // KPI Metric Boxes (4 Boxes)
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  _kpiBox(
                      'TOTAL BILLED',
                      CurrencyFormatter.format(summary.totalBilled),
                      PdfColor.fromHex('#2563EB'),
                      fontBold),
                  _kpiBox(
                      'TOTAL COLLECTED',
                      CurrencyFormatter.format(summary.totalCollected),
                      PdfColor.fromHex('#10B981'),
                      fontBold),
                  _kpiBox(
                      'OUTSTANDING',
                      CurrencyFormatter.format(summary.totalOutstanding),
                      PdfColor.fromHex('#EF4444'),
                      fontBold),
                  _kpiBox(
                      'OVERDUE',
                      CurrencyFormatter.format(summary.overdueAmount),
                      PdfColor.fromHex('#DC2626'),
                      fontBold),
                ],
              ),
              pw.SizedBox(height: 20),

              // 12 Months Breakdown Table
              pw.Text('12-Month Cashflow Breakdown',
                  style: pw.TextStyle(font: fontBold, fontSize: 12)),
              pw.SizedBox(height: 8),
              pw.Table(
                border:
                    pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
                children: [
                  pw.TableRow(
                    decoration:
                        pw.BoxDecoration(color: PdfColor.fromHex('#F1F5F9')),
                    children: [
                      _th('Month', fontBold),
                      _th('Billed (₹)', fontBold, align: pw.TextAlign.right),
                      _th('Collected (₹)', fontBold, align: pw.TextAlign.right),
                      _th('Outstanding (₹)', fontBold,
                          align: pw.TextAlign.right),
                      _th('Collection %', fontBold, align: pw.TextAlign.right),
                    ],
                  ),
                  ...yearly.trends.map((m) {
                    final rate =
                        m.billed > 0 ? (m.collected / m.billed) * 100 : 100.0;
                    return pw.TableRow(
                      children: [
                        _td(m.monthName),
                        _td(CurrencyFormatter.formatCompact(m.billed),
                            align: pw.TextAlign.right),
                        _td(CurrencyFormatter.formatCompact(m.collected),
                            align: pw.TextAlign.right),
                        _td(CurrencyFormatter.formatCompact(m.outstanding),
                            align: pw.TextAlign.right),
                        _td('${rate.toStringAsFixed(0)}%',
                            align: pw.TextAlign.right),
                      ],
                    );
                  }),
                ],
              ),
              pw.SizedBox(height: 18),

              // Aging Analysis Section
              pw.Text('Accounts Receivable Aging Analysis',
                  style: pw.TextStyle(font: fontBold, fontSize: 12)),
              pw.SizedBox(height: 8),
              pw.Table(
                border:
                    pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
                children: [
                  pw.TableRow(
                    decoration:
                        pw.BoxDecoration(color: PdfColor.fromHex('#F1F5F9')),
                    children: [
                      _th('Aging Bucket', fontBold),
                      _th('Outstanding Amount (₹)', fontBold,
                          align: pw.TextAlign.right),
                      _th('Risk Level', fontBold),
                    ],
                  ),
                  pw.TableRow(children: [
                    _td('0 - 30 Days (Current)'),
                    _td(CurrencyFormatter.format(aging.bucket0To30),
                        align: pw.TextAlign.right),
                    _td('Low / Normal'),
                  ]),
                  pw.TableRow(children: [
                    _td('31 - 60 Days (Moderate)'),
                    _td(CurrencyFormatter.format(aging.bucket31To60),
                        align: pw.TextAlign.right),
                    _td('Moderate Risk'),
                  ]),
                  pw.TableRow(children: [
                    _td('60+ Days (Overdue)'),
                    _td(CurrencyFormatter.format(aging.bucket60Plus),
                        align: pw.TextAlign.right),
                    _td('High Risk / Urgent Attention'),
                  ]),
                ],
              ),
              pw.Spacer(),
              pw.Text(
                  'Report produced automatically by Invox - Enterprise Financial Architecture',
                  style: const pw.TextStyle(
                      fontSize: 8, color: PdfColors.grey500)),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _kpiBox(
      String title, String value, PdfColor color, pw.Font fontBold) {
    return pw.Container(
      width: 120,
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: color, width: 1),
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(title,
              style: pw.TextStyle(fontSize: 7, font: fontBold, color: color)),
          pw.SizedBox(height: 3),
          pw.Text(value, style: pw.TextStyle(fontSize: 10, font: fontBold)),
        ],
      ),
    );
  }

  static pw.Widget _th(String text, pw.Font fontBold,
      {pw.TextAlign align = pw.TextAlign.left}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(5),
      child: pw.Text(text,
          style: pw.TextStyle(font: fontBold, fontSize: 8), textAlign: align),
    );
  }

  static pw.Widget _td(String text, {pw.TextAlign align = pw.TextAlign.left}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(5),
      child: pw.Text(text,
          style: const pw.TextStyle(fontSize: 8), textAlign: align),
    );
  }
}
