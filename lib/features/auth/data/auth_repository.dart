import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../models/user_model.dart';

class AuthRepository {
  final ApiClient apiClient;

  AuthRepository(this.apiClient);

  Future<User> login({required String email, required String password}) async {
    final response = await apiClient.post(
      ApiEndpoints.login,
      data: {
        'email': email,
        'password': password,
      },
    );

    final data = response as Map<String, dynamic>;
    final token = data['token'] as String;
    final userData = data['user'] as Map<String, dynamic>;

    return User.fromJson(userData, token);
  }
}
