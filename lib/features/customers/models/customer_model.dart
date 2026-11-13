class Customer {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String address;
  final String gstin;
  final double totalBilled;
  final double totalPaid;
  final double outstandingBalance;
  final String? createdAt;

  Customer({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.address,
    required this.gstin,
    required this.totalBilled,
    required this.totalPaid,
    required this.outstandingBalance,
    this.createdAt,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      gstin: json['gstin']?.toString() ?? '',
      totalBilled: (json['total_billed'] as num?)?.toDouble() ?? 0.0,
      totalPaid: (json['total_paid'] as num?)?.toDouble() ?? 0.0,
      outstandingBalance: (json['outstanding_balance'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['created_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'address': address,
      'gstin': gstin,
      'total_billed': totalBilled,
      'total_paid': totalPaid,
      'outstanding_balance': outstandingBalance,
      if (createdAt != null) 'created_at': createdAt,
    };
  }
}

