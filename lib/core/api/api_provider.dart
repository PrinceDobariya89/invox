import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_client.dart';

/// Set to false when connecting to the live Laravel backend (php artisan serve).
/// Set to true for standalone preview / offline demo mode.
final isMockBackendEnabledProvider = StateProvider<bool>((ref) => false);

final apiClientProvider = Provider<ApiClient>((ref) {
  final useMock = ref.watch(isMockBackendEnabledProvider);
  return ApiClient.create(enableMockFallback: useMock);
});
