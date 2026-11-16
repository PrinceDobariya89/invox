import 'package:flutter_test/flutter_test.dart';
import 'package:invox/core/api/api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('API Logging System', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('ApiClient completes mock requests with logging enabled', () async {
      final client = ApiClient.create(enableMockFallback: true, enableLogging: true);

      // Make a GET request
      final res = await client.get('/customers');
      expect(res, isNotNull);
      expect(res, isA<List>());
    });

    test('ApiClient completes mock POST login with logging enabled', () async {
      final client = ApiClient.create(enableMockFallback: true, enableLogging: true);

      // Make a POST request
      final res = await client.post(
        '/auth/login',
        data: {'email': 'test@invox.com', 'password': 'password123'},
      );
      expect(res, isNotNull);
      expect(res, isA<Map>());
      expect((res as Map)['token'], isNotNull);
    });
  });
}
