class User {
  final String id;
  final String name;
  final String email;
  final String businessName;
  final String gstin;
  final String currency;
  final String token;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.businessName,
    required this.gstin,
    required this.currency,
    required this.token,
  });

  factory User.fromJson(Map<String, dynamic> json, String token) {
    return User(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      businessName: json['business_name']?.toString() ?? 'Invox Business',
      gstin: json['gstin']?.toString() ?? '',
      currency: json['currency']?.toString() ?? 'INR',
      token: token,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'business_name': businessName,
      'gstin': gstin,
      'currency': currency,
      'token': token,
    };
  }
}

