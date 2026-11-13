class Payment {
  final String id;
  final String invoiceId;
  final String invoiceNumber;
  final String customerId;
  final String customerName;
  final double amount;
  final String paymentMode; // 'UPI', 'Bank Transfer', 'Cash', 'Cheque'
  final String referenceNo;
  final String paymentDate;
  final String notes;

  Payment({
    required this.id,
    required this.invoiceId,
    required this.invoiceNumber,
    required this.customerId,
    required this.customerName,
    required this.amount,
    required this.paymentMode,
    required this.referenceNo,
    required this.paymentDate,
    this.notes = '',
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id']?.toString() ?? '',
      invoiceId: json['invoice_id']?.toString() ?? '',
      invoiceNumber: json['invoice_number']?.toString() ?? '',
      customerId: json['customer_id']?.toString() ?? '',
      customerName: json['customer_name']?.toString() ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      paymentMode: json['payment_mode']?.toString() ?? 'UPI',
      referenceNo: json['reference_no']?.toString() ?? '',
      paymentDate: json['payment_date']?.toString() ?? '',
      notes: json['notes']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'invoice_id': invoiceId,
      'invoice_number': invoiceNumber,
      'customer_id': customerId,
      'customer_name': customerName,
      'amount': amount,
      'payment_mode': paymentMode,
      'reference_no': referenceNo,
      'payment_date': paymentDate,
      'notes': notes,
    };
  }
}

