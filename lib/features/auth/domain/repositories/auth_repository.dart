import '../entities/auth_entities.dart';

abstract class AuthRepository {
  Future<AuthResponse> login(String login, String password);
  Future<void> logout();
  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();
  Future<bool> isAuthenticated();
}
