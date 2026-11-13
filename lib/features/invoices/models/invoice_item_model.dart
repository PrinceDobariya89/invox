class InvoiceItem {
  final String description;
  final double qty;
  final double rate;
  final double discount; // Percentage (e.g. 5.0 for 5%)
  final double tax; // Optional/0.0 for non-GST bills
  final double amount; // Final line amount

  InvoiceItem({
    required this.description,
    required this.qty,
    required this.rate,
    this.discount = 0.0,
    this.tax = 0.0,
    required this.amount,
  });

  factory InvoiceItem.calculate({
    required String description,
    required double qty,
    required double rate,
    double discount = 0.0,
    double tax = 0.0,
  }) {
    final base = qty * rate;
    final discountAmount = base * (discount / 100);
    final taxable = base - discountAmount;
    final taxAmount = taxable * (tax / 100);
    final total = taxable + taxAmount;

    return InvoiceItem(
      description: description,
      qty: qty,
      rate: rate,
      discount: discount,
      tax: tax,
      amount: total,
    );
  }

  factory InvoiceItem.fromJson(Map<String, dynamic> json) {
    return InvoiceItem(
      description: json['description']?.toString() ?? '',
      qty: (json['qty'] as num?)?.toDouble() ?? 1.0,
      rate: (json['rate'] as num?)?.toDouble() ?? 0.0,
      discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
      tax: (json['tax'] as num?)?.toDouble() ?? 0.0,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'qty': qty,
      'rate': rate,
      'discount': discount,
      'tax': tax,
      'amount': amount,
    };
  }
}
