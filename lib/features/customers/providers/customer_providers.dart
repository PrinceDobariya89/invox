import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_provider.dart';
import '../data/customer_repository.dart';
import '../models/customer_model.dart';
import '../models/customer_detail_model.dart';

final customerRepositoryProvider = Provider<CustomerRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return CustomerRepository(apiClient);
});

final customerSearchQueryProvider = StateProvider<String>((ref) => '');

class CustomerListNotifier extends AsyncNotifier<List<Customer>> {
  @override
  Future<List<Customer>> build() async {
    final search = ref.watch(customerSearchQueryProvider);
    final repo = ref.watch(customerRepositoryProvider);
    return repo.getCustomers(search: search);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final search = ref.read(customerSearchQueryProvider);
      return ref.read(customerRepositoryProvider).getCustomers(search: search);
    });
  }

  Future<Customer> addCustomer({
    required String name,
    required String phone,
    required String address,
    required String gstin,
    String? email,
  }) async {
    final repo = ref.read(customerRepositoryProvider);
    final created = await repo.createCustomer(
      name: name,
      phone: phone,
      address: address,
      gstin: gstin,
      email: email,
    );
    // Refresh list
    ref.invalidateSelf();
    return created;
  }
}

final customerListProvider = AsyncNotifierProvider<CustomerListNotifier, List<Customer>>(() {
  return CustomerListNotifier();
});

final customerDetailProvider = FutureProvider.family<CustomerDetail, String>((ref, id) async {
  final repo = ref.watch(customerRepositoryProvider);
  return repo.getCustomerDetail(id);
});

