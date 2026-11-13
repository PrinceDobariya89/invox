import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../models/invoice_model.dart';

class InvoicePdfBuilder {
  static Future<Uint8List> buildPdf(Invoice invoice) async {
    final pdf = pw.Document();

    // Load fonts safely using Printing
    final fontRegular = await PdfGoogleFonts.poppinsRegular();
    final fontBold = await PdfGoogleFonts.poppinsBold();
    final fontMedium = await PdfGoogleFonts.poppinsMedium();

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
              // 1. Header (Company Info & Non-GST Invoice / Bill Title)
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'INVOX ENTERPRISES',
                        style: pw.TextStyle(
                          font: fontBold,
                          fontSize: 18,
                          color: PdfColor.fromHex('#4338CA'),
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'Commercial & Business Invoicing',
                        style: pw.TextStyle(font: fontMedium, fontSize: 10, color: PdfColors.grey700),
                      ),
                      pw.Text(
                        'Plot 108, Cyber City, Bandra Kurla Complex, Mumbai 400051',
                        style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
                      ),
                      pw.Text(
                        'Phone: +91 99887 76655 | Email: accounts@invox.io',
                        style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'INVOICE / BILL',
                        style: pw.TextStyle(
                          font: fontBold,
                          fontSize: 20,
                          color: PdfColors.blueGrey800,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: pw.BoxDecoration(
                          color: invoice.status == 'PAID'
                              ? PdfColor.fromHex('#ECFDF5')
                              : (invoice.status == 'PARTIAL'
                                  ? PdfColor.fromHex('#FFFBEB')
                                  : PdfColor.fromHex('#FEF2F2')),
                          borderRadius: pw.BorderRadius.circular(4),
                          border: pw.Border.all(
                            color: invoice.status == 'PAID'
                                ? PdfColor.fromHex('#10B981')
                                : (invoice.status == 'PARTIAL'
                                    ? PdfColor.fromHex('#F59E0B')
                                    : PdfColor.fromHex('#EF4444')),
                          ),
                        ),
                        child: pw.Text(
                          invoice.status,
                          style: pw.TextStyle(
                            font: fontBold,
                            fontSize: 10,
                            color: invoice.status == 'PAID'
                                ? PdfColor.fromHex('#10B981')
                                : (invoice.status == 'PARTIAL'
                                    ? PdfColor.fromHex('#F59E0B')
                                    : PdfColor.fromHex('#EF4444')),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 16),
              pw.Divider(color: PdfColors.grey300),
              pw.SizedBox(height: 12),

              // 2. Metadata & Bill To
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Bill To
                  pw.Container(
                    width: 250,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'BILLED TO:',
                          style: pw.TextStyle(
                            font: fontBold,
                            fontSize: 10,
                            color: PdfColors.grey700,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          invoice.customerName,
                          style: pw.TextStyle(font: fontBold, fontSize: 13),
                        ),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          'Customer ID: ${invoice.customerId}',
                          style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
                        ),
                      ],
                    ),
                  ),

                  // Invoice Details
                  pw.Table(
                    children: [
                      pw.TableRow(children: [
                        pw.Text('Bill / Inv No: ', style: pw.TextStyle(font: fontBold, fontSize: 10)),
                        pw.Text(invoice.invoiceNumber, style: pw.TextStyle(font: fontBold, fontSize: 10)),
                      ]),
                      pw.TableRow(children: [
                        pw.Text('Date: ', style: const pw.TextStyle(fontSize: 10)),
                        pw.Text(DateFormatter.toDisplay(DateTime.tryParse(invoice.date)),
                            style: const pw.TextStyle(fontSize: 10)),
                      ]),
                      pw.TableRow(children: [
                        pw.Text('Due Date: ', style: const pw.TextStyle(fontSize: 10)),
                        pw.Text(DateFormatter.toDisplay(DateTime.tryParse(invoice.dueDate)),
                            style: const pw.TextStyle(fontSize: 10)),
                      ]),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 20),

              // 3. Line Items Table (Simple Non-GST: #, Description, Qty, Rate, Discount, Total)
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
                children: [
                  // Table Header
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: PdfColor.fromHex('#F1F5F9')),
                    children: [
                      _th('#', fontBold, align: pw.TextAlign.center),
                      _th('Item Description', fontBold),
                      _th('Qty', fontBold, align: pw.TextAlign.center),
                      _th('Rate (₹)', fontBold, align: pw.TextAlign.right),
                      _th('Disc %', fontBold, align: pw.TextAlign.right),
                      _th('Total (₹)', fontBold, align: pw.TextAlign.right),
                    ],
                  ),
                  // Table Rows
                  ...invoice.items.asMap().entries.map((entry) {
                    final idx = entry.key + 1;
                    final item = entry.value;
                    return pw.TableRow(
                      children: [
                        _td('$idx', align: pw.TextAlign.center),
                        _td(item.description),
                        _td(item.qty.toStringAsFixed(0), align: pw.TextAlign.center),
                        _td(item.rate.toStringAsFixed(2), align: pw.TextAlign.right),
                        _td(item.discount > 0 ? '${item.discount.toStringAsFixed(0)}%' : '-',
                            align: pw.TextAlign.right),
                        _td(item.amount.toStringAsFixed(2), align: pw.TextAlign.right),
                      ],
                    );
                  }),
                ],
              ),
              pw.SizedBox(height: 16),

              // 4. Totals Breakdown & Notes
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  // Notes & Payment terms
                  pw.Container(
                    width: 250,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Notes & Terms:', style: pw.TextStyle(font: fontBold, fontSize: 9)),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          invoice.notes.isNotEmpty ? invoice.notes : 'Payment is due within payment terms.',
                          style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
                        ),
                        pw.SizedBox(height: 12),
                        pw.Text('Payment Details (UPI / Bank):',
                            style: pw.TextStyle(font: fontBold, fontSize: 9)),
                        pw.Text('Bank: HDFC Bank | A/C: 50200012345678',
                            style: const pw.TextStyle(fontSize: 8)),
                        pw.Text('IFSC: HDFC0001234 | UPI ID: invox@hdfcbank',
                            style: const pw.TextStyle(fontSize: 8)),
                      ],
                    ),
                  ),

                  // Totals Table (No GST row)
                  pw.Container(
                    width: 220,
                    child: pw.Table(
                      children: [
                        pw.TableRow(children: [
                          pw.Text('Subtotal: ', style: const pw.TextStyle(fontSize: 10)),
                          pw.Text(CurrencyFormatter.formatCompact(invoice.subtotal),
                              style: const pw.TextStyle(fontSize: 10), textAlign: pw.TextAlign.right),
                        ]),
                        if (invoice.discountAmount > 0)
                          pw.TableRow(children: [
                            pw.Text('Discount: ', style: const pw.TextStyle(fontSize: 10)),
                            pw.Text('- ${CurrencyFormatter.formatCompact(invoice.discountAmount)}',
                                style: const pw.TextStyle(fontSize: 10), textAlign: pw.TextAlign.right),
                          ]),
                        pw.TableRow(children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.symmetric(vertical: 4),
                            child: pw.Text('Grand Total: ',
                                style: pw.TextStyle(font: fontBold, fontSize: 12)),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.symmetric(vertical: 4),
                            child: pw.Text(CurrencyFormatter.format(invoice.totalAmount),
                                style: pw.TextStyle(font: fontBold, fontSize: 12),
                                textAlign: pw.TextAlign.right),
                          ),
                        ]),
                        pw.TableRow(children: [
                          pw.Text('Amount Paid: ',
                              style: pw.TextStyle(fontSize: 10, color: PdfColor.fromHex('#10B981'))),
                          pw.Text(CurrencyFormatter.format(invoice.amountPaid),
                              style: pw.TextStyle(fontSize: 10, color: PdfColor.fromHex('#10B981')),
                              textAlign: pw.TextAlign.right),
                        ]),
                        pw.TableRow(children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.symmetric(vertical: 4),
                            child: pw.Text('Balance Due: ',
                                style: pw.TextStyle(
                                    font: fontBold, fontSize: 11, color: PdfColor.fromHex('#EF4444'))),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.symmetric(vertical: 4),
                            child: pw.Text(CurrencyFormatter.format(invoice.balanceAmount),
                                style: pw.TextStyle(
                                    font: fontBold, fontSize: 11, color: PdfColor.fromHex('#EF4444')),
                                textAlign: pw.TextAlign.right),
                          ),
                        ]),
                      ],
                    ),
                  ),
                ],
              ),
              pw.Spacer(),

              // 5. Signature & Footer
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text('Thank you for choosing Invox!',
                      style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey500)),
                  pw.Column(
                    children: [
                      pw.Container(
                        width: 140,
                        decoration: const pw.BoxDecoration(
                          border: pw.Border(top: pw.BorderSide(color: PdfColors.grey500, width: 1)),
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text('Authorized Signatory',
                          style: pw.TextStyle(font: fontMedium, fontSize: 9)),
                    ],
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _th(String text, pw.Font fontBold, {pw.TextAlign align = pw.TextAlign.left}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      child: pw.Text(
        text,
        style: pw.TextStyle(font: fontBold, fontSize: 9),
        textAlign: align,
      ),
    );
  }

  static pw.Widget _td(String text, {pw.TextAlign align = pw.TextAlign.left}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      child: pw.Text(
        text,
        style: const pw.TextStyle(fontSize: 8),
        textAlign: align,
      ),
    );
  }
}
