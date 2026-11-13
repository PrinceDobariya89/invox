import 'package:flutter_test/flutter_test.dart';
import 'package:invox/core/utils/currency_formatter.dart';
import 'package:invox/features/analytics/models/analytics_summary_model.dart';
import 'package:invox/features/invoices/models/invoice_item_model.dart';
import 'package:invox/features/invoices/models/invoice_model.dart';

void main() {
  group('Non-GST Bill & Financial Calculations', () {
    test('InvoiceItem.calculate computes base and discount accurately without GST', () {
      // Qty: 5, Rate: 200, Disc: 10%
      // Base: 1000, Discount: 100 => Total: 900
      final item = InvoiceItem.calculate(
        description: 'Cotton Fabric Roll',
        qty: 5,
        rate: 200,
        discount: 10,
        tax: 0,
      );

      expect(item.amount, equals(900.0));
      expect(item.qty, equals(5.0));
      expect(item.rate, equals(200.0));
    });

    test('CurrencyFormatter formats INR amounts correctly', () {
      expect(CurrencyFormatter.formatShort(150000), equals('₹1.50 L'));
      expect(CurrencyFormatter.formatShort(25000), equals('₹25.0 K'));
    });

    test('Invoice overdue detection functions correctly', () {
      final pastDate = DateTime.now().subtract(const Duration(days: 5)).toIso8601String().split('T').first;
      final futureDate = DateTime.now().add(const Duration(days: 10)).toIso8601String().split('T').first;

      final overdueInvoice = Invoice(
        id: 'inv_test_1',
        customerId: 'cust_1',
        customerName: 'Test Customer',
        invoiceNumber: 'INV-TEST-001',
        date: '2026-01-01',
        dueDate: pastDate,
        status: 'UNPAID',
        subtotal: 1000,
        taxAmount: 0,
        discountAmount: 0,
        totalAmount: 1000,
        amountPaid: 0,
        balanceAmount: 1000,
        items: [],
      );

      final paidInvoice = Invoice(
        id: 'inv_test_2',
        customerId: 'cust_1',
        customerName: 'Test Customer',
        invoiceNumber: 'INV-TEST-002',
        date: '2026-01-01',
        dueDate: pastDate,
        status: 'PAID',
        subtotal: 1000,
        taxAmount: 0,
        discountAmount: 0,
        totalAmount: 1000,
        amountPaid: 1000,
        balanceAmount: 0,
        items: [],
      );

      final upcomingInvoice = Invoice(
        id: 'inv_test_3',
        customerId: 'cust_1',
        customerName: 'Test Customer',
        invoiceNumber: 'INV-TEST-003',
        date: '2026-01-01',
        dueDate: futureDate,
        status: 'UNPAID',
        subtotal: 1000,
        taxAmount: 0,
        discountAmount: 0,
        totalAmount: 1000,
        amountPaid: 0,
        balanceAmount: 1000,
        items: [],
      );

      expect(overdueInvoice.isOverdue, isTrue);
      expect(paidInvoice.isOverdue, isFalse);
      expect(upcomingInvoice.isOverdue, isFalse);
    });

    test('AnalyticsSummary computes collection rate accurately', () {
      final summary = AnalyticsSummary(
        totalBilled: 200000.0,
        totalCollected: 150000.0,
        totalOutstanding: 50000.0,
        overdueAmount: 10000.0,
      );

      expect(summary.collectionRate, equals(75.0));
    });
  });
}
