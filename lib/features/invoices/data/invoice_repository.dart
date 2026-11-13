import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../models/invoice_model.dart';

class InvoiceRepository {
  final ApiClient apiClient;

  InvoiceRepository(this.apiClient);

  Future<List<Invoice>> getInvoices({
    String? customerId,
    String? status,
    int? month,
    int? year,
    String? search,
    int page = 1,
  }) async {
    final params = <String, dynamic>{
      'page': page,
      if (customerId != null && customerId.isNotEmpty) 'customer_id': customerId,
      if (status != null && status.isNotEmpty) 'status': status,
      if (month != null) 'month': month,
      if (year != null) 'year': year,
      if (search != null && search.isNotEmpty) 'search': search,
    };

    final response = await apiClient.get(
      ApiEndpoints.invoices,
      queryParameters: params,
    );

    final list = response as List;
    return list.map((e) => Invoice.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Invoice> createInvoice({
    required String customerId,
    required String invoiceNumber,
    required String date,
    required String dueDate,
    required List<Map<String, dynamic>> items,
    String notes = '',
  }) async {
    final response = await apiClient.post(
      ApiEndpoints.invoices,
      data: {
        'customer_id': customerId,
        'invoice_number': invoiceNumber,
        'date': date,
        'due_date': dueDate,
        'items': items,
        'notes': notes,
      },
    );

    return Invoice.fromJson(response as Map<String, dynamic>);
  }

  Future<Invoice> getInvoiceDetail(String id) async {
    final response = await apiClient.get(ApiEndpoints.invoiceDetail(id));
    return Invoice.fromJson(response as Map<String, dynamic>);
  }
}

