import 'customer_model.dart';

enum LedgerEntryType { invoice, payment }

class LedgerItem {
  final String id;
  final LedgerEntryType type;
  final String referenceNumber; // Invoice # or Payment Txn #
  final String date;
  final double amount;
  final String description;
  final String statusOrMode; // 'PAID'/'PARTIAL'/'UNPAID' for invoice, 'UPI'/'Bank Transfer' for payment

  LedgerItem({
    required this.id,
    required this.type,
    required this.referenceNumber,
    required this.date,
    required this.amount,
    required this.description,
    required this.statusOrMode,
  });
}

class CustomerDetail {
  final Customer customer;
  final List<Map<String, dynamic>> rawInvoices;
  final List<Map<String, dynamic>> rawPayments;
  final List<LedgerItem> ledgerItems;

  CustomerDetail({
    required this.customer,
    required this.rawInvoices,
    required this.rawPayments,
    required this.ledgerItems,
  });

  factory CustomerDetail.fromJson(Map<String, dynamic> json) {
    final customer = Customer.fromJson(json);
    final invoices = (json['invoices'] as List?)?.map((e) => e as Map<String, dynamic>).toList() ?? [];
    final payments = (json['payments'] as List?)?.map((e) => e as Map<String, dynamic>).toList() ?? [];

    final ledger = <LedgerItem>[];

    for (final inv in invoices) {
      ledger.add(
        LedgerItem(
          id: inv['id']?.toString() ?? '',
          type: LedgerEntryType.invoice,
          referenceNumber: inv['invoice_number']?.toString() ?? '',
          date: inv['date']?.toString() ?? '',
          amount: (inv['total_amount'] as num?)?.toDouble() ?? 0.0,
          description: inv['notes']?.toString() ?? 'Invoice Generated',
          statusOrMode: inv['status']?.toString() ?? 'UNPAID',
        ),
      );
    }

    for (final pay in payments) {
      ledger.add(
        LedgerItem(
          id: pay['id']?.toString() ?? '',
          type: LedgerEntryType.payment,
          referenceNumber: pay['reference_no']?.toString() ?? '',
          date: pay['payment_date']?.toString() ?? '',
          amount: (pay['amount'] as num?)?.toDouble() ?? 0.0,
          description: 'Payment for ${pay['invoice_number'] ?? 'Invoice'} (${pay['notes'] ?? ''})',
          statusOrMode: pay['payment_mode']?.toString() ?? 'Cash',
        ),
      );
    }

    // Sort descending by date
    ledger.sort((a, b) => b.date.compareTo(a.date));

    return CustomerDetail(
      customer: customer,
      rawInvoices: invoices,
      rawPayments: payments,
      ledgerItems: ledger,
    );
  }
}

