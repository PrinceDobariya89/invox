import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_provider.dart';
import '../../customers/providers/customer_providers.dart';
import '../data/invoice_repository.dart';
import '../models/invoice_model.dart';

final invoiceRepositoryProvider = Provider<InvoiceRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  return InvoiceRepository(client);
});

final invoiceFilterStatusProvider = StateProvider<String>((ref) => 'ALL');
final invoiceSearchQueryProvider = StateProvider<String>((ref) => '');

class InvoiceListNotifier extends AsyncNotifier<List<Invoice>> {
  @override
  Future<List<Invoice>> build() async {
    final repo = ref.watch(invoiceRepositoryProvider);
    final status = ref.watch(invoiceFilterStatusProvider);
    final search = ref.watch(invoiceSearchQueryProvider);

    return repo.getInvoices(
      status: status == 'ALL' ? null : status,
      search: search,
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(invoiceRepositoryProvider);
      final status = ref.read(invoiceFilterStatusProvider);
      final search = ref.read(invoiceSearchQueryProvider);
      return repo.getInvoices(
        status: status == 'ALL' ? null : status,
        search: search,
      );
    });
  }

  Future<Invoice> createInvoice({
    required String customerId,
    required String invoiceNumber,
    required String date,
    required String dueDate,
    required List<Map<String, dynamic>> items,
    String notes = '',
  }) async {
    final repo = ref.read(invoiceRepositoryProvider);
    final invoice = await repo.createInvoice(
      customerId: customerId,
      invoiceNumber: invoiceNumber,
      date: date,
      dueDate: dueDate,
      items: items,
      notes: notes,
    );

    // Invalidate invoice list & customer lists to keep state synced
    ref.invalidateSelf();
    ref.invalidate(customerListProvider);
    return invoice;
  }
}

final invoiceListProvider = AsyncNotifierProvider<InvoiceListNotifier, List<Invoice>>(() {
  return InvoiceListNotifier();
});

final invoiceDetailProvider = FutureProvider.family<Invoice, String>((ref, id) async {
  final repo = ref.watch(invoiceRepositoryProvider);
  return repo.getInvoiceDetail(id);
});

