import 'invoice_item_model.dart';

enum InvoiceStatus { unpaid, partial, paid }

class Invoice {
  final String id;
  final String customerId;
  final String customerName;
  final String invoiceNumber;
  final String date;
  final String dueDate;
  final String status; // 'UNPAID', 'PARTIAL', 'PAID'
  final double subtotal;
  final double taxAmount;
  final double discountAmount;
  final double totalAmount;
  final double amountPaid;
  final double balanceAmount;
  final String notes;
  final List<InvoiceItem> items;

  Invoice({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.invoiceNumber,
    required this.date,
    required this.dueDate,
    required this.status,
    required this.subtotal,
    required this.taxAmount,
    required this.discountAmount,
    required this.totalAmount,
    required this.amountPaid,
    required this.balanceAmount,
    this.notes = '',
    required this.items,
  });

  bool get isOverdue {
    if (status == 'PAID' || balanceAmount <= 0) return false;
    final due = DateTime.tryParse(dueDate);
    if (due == null) return false;
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day).isAfter(DateTime(due.year, due.month, due.day));
  }

  factory Invoice.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List? ?? [];
    final items = rawItems.map((e) => InvoiceItem.fromJson(e as Map<String, dynamic>)).toList();

    return Invoice(
      id: json['id']?.toString() ?? '',
      customerId: json['customer_id']?.toString() ?? '',
      customerName: json['customer_name']?.toString() ?? 'Customer',
      invoiceNumber: json['invoice_number']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      dueDate: json['due_date']?.toString() ?? '',
      status: (json['status']?.toString() ?? 'UNPAID').toUpperCase(),
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      taxAmount: (json['tax_amount'] as num?)?.toDouble() ?? 0.0,
      discountAmount: (json['discount_amount'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
      amountPaid: (json['amount_paid'] as num?)?.toDouble() ?? 0.0,
      balanceAmount: (json['balance_amount'] as num?)?.toDouble() ?? 0.0,
      notes: json['notes']?.toString() ?? '',
      items: items,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_id': customerId,
      'customer_name': customerName,
      'invoice_number': invoiceNumber,
      'date': date,
      'due_date': dueDate,
      'status': status,
      'subtotal': subtotal,
      'tax_amount': taxAmount,
      'discount_amount': discountAmount,
      'total_amount': totalAmount,
      'amount_paid': amountPaid,
      'balance_amount': balanceAmount,
      'notes': notes,
      'items': items.map((i) => i.toJson()).toList(),
    };
  }
}

