import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/api/api_provider.dart';
import '../data/auth_repository.dart';
import '../models/user_model.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AuthRepository(apiClient);
});

class AuthNotifier extends AsyncNotifier<User?> {
  @override
  Future<User?> build() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final userRaw = prefs.getString('user_profile');

    if (token != null && token.isNotEmpty) {
      if (userRaw != null) {
        try {
          final json = jsonDecode(userRaw) as Map<String, dynamic>;
          return User.fromJson(json, token);
        } catch (_) {}
      }
      return User(
        id: 'usr_001',
        name: prefs.getString('user_name') ?? 'Admin User',
        email: prefs.getString('user_email') ?? 'admin@invox.com',
        businessName: prefs.getString('user_business') ?? 'Invox Tech Enterprises',
        gstin: prefs.getString('user_gstin') ?? '27AABCU9603R1ZM',
        currency: 'INR',
        token: token,
      );
    }
    return null;
  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    try {
      final repo = ref.read(authRepositoryProvider);
      final user = await repo.login(email: email, password: password);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', user.token);
      await prefs.setString('user_name', user.name);
      await prefs.setString('user_email', user.email);
      await prefs.setString('user_business', user.businessName);
      await prefs.setString('user_gstin', user.gstin);
      await prefs.setString('user_profile', jsonEncode(user.toJson()));

      state = AsyncData(user);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_profile');
    await prefs.remove('user_name');
    await prefs.remove('user_email');
    await prefs.remove('user_business');
    await prefs.remove('user_gstin');
    state = const AsyncData(null);
  }
}

final authProvider = AsyncNotifierProvider<AuthNotifier, User?>(() {
  return AuthNotifier();
});

