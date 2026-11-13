import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_provider.dart';
import '../../customers/providers/customer_providers.dart';
import '../../invoices/providers/invoice_providers.dart';
import '../data/payment_repository.dart';
import '../models/payment_model.dart';

final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  return PaymentRepository(client);
});

final paymentsByInvoiceProvider = FutureProvider.family<List<Payment>, String>((ref, invoiceId) async {
  final repo = ref.watch(paymentRepositoryProvider);
  return repo.getPayments(invoiceId: invoiceId);
});

class PaymentNotifier extends StateNotifier<AsyncValue<Payment?>> {
  final Ref ref;

  PaymentNotifier(this.ref) : super(const AsyncData(null));

  Future<Payment> recordPayment({
    required String invoiceId,
    required String customerId,
    required double amount,
    required String paymentMode,
    required String referenceNo,
    required String paymentDate,
    String notes = '',
  }) async {
    state = const AsyncLoading();
    try {
      final repo = ref.read(paymentRepositoryProvider);
      final payment = await repo.recordPayment(
        invoiceId: invoiceId,
        customerId: customerId,
        amount: amount,
        paymentMode: paymentMode,
        referenceNo: referenceNo,
        paymentDate: paymentDate,
        notes: notes,
      );

      state = AsyncData(payment);

      // Invalidate related states to immediately sync invoices and customers
      ref.invalidate(invoiceListProvider);
      ref.invalidate(invoiceDetailProvider(invoiceId));
      ref.invalidate(customerListProvider);
      ref.invalidate(customerDetailProvider(customerId));
      ref.invalidate(paymentsByInvoiceProvider(invoiceId));

      return payment;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}

final paymentNotifierProvider = StateNotifierProvider<PaymentNotifier, AsyncValue<Payment?>>((ref) {
  return PaymentNotifier(ref);
});

