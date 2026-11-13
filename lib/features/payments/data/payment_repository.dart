import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../models/payment_model.dart';

class PaymentRepository {
  final ApiClient apiClient;

  PaymentRepository(this.apiClient);

  Future<Payment> recordPayment({
    required String invoiceId,
    required String customerId,
    required double amount,
    required String paymentMode,
    required String referenceNo,
    required String paymentDate,
    String notes = '',
  }) async {
    final response = await apiClient.post(
      ApiEndpoints.payments,
      data: {
        'invoice_id': invoiceId,
        'customer_id': customerId,
        'amount': amount,
        'payment_mode': paymentMode,
        'reference_no': referenceNo,
        'payment_date': paymentDate,
        'notes': notes,
      },
    );

    return Payment.fromJson(response as Map<String, dynamic>);
  }

  Future<List<Payment>> getPayments({String? invoiceId}) async {
    final params = <String, dynamic>{
      if (invoiceId != null && invoiceId.isNotEmpty) 'invoice_id': invoiceId,
    };

    final response = await apiClient.get(
      ApiEndpoints.payments,
      queryParameters: params,
    );

    final list = response as List;
    return list.map((e) => Payment.fromJson(e as Map<String, dynamic>)).toList();
  }
}

