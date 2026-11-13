import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../models/customer_model.dart';
import '../models/customer_detail_model.dart';

class CustomerRepository {
  final ApiClient apiClient;

  CustomerRepository(this.apiClient);

  Future<List<Customer>> getCustomers({String? search, int page = 1}) async {
    final queryParams = <String, dynamic>{'page': page};
    if (search != null && search.trim().isNotEmpty) {
      queryParams['search'] = search.trim();
    }

    final response = await apiClient.get(
      ApiEndpoints.customers,
      queryParameters: queryParams,
    );

    final list = response as List;
    return list.map((item) => Customer.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<Customer> createCustomer({
    required String name,
    required String phone,
    required String address,
    required String gstin,
    String? email,
  }) async {
    final response = await apiClient.post(
      ApiEndpoints.customers,
      data: {
        'name': name,
        'phone': phone,
        'address': address,
        'gstin': gstin,
        if (email != null) 'email': email,
      },
    );

    return Customer.fromJson(response as Map<String, dynamic>);
  }

  Future<CustomerDetail> getCustomerDetail(String id) async {
    final response = await apiClient.get(ApiEndpoints.customerDetail(id));
    return CustomerDetail.fromJson(response as Map<String, dynamic>);
  }
}

