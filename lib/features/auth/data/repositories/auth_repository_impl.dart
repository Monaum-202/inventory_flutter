import 'dart:convert';

import '../../../../core/services/api_service.dart';
import '../../domain/entities/auth_entities.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/token_local_datasource.dart';
import '../models/auth_response_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required ApiService apiService,
    required TokenLocalDataSource tokenLocalDataSource,
  })  : _apiService = apiService,
        _tokenLocalDataSource = tokenLocalDataSource;

  final ApiService _apiService;
  final TokenLocalDataSource _tokenLocalDataSource;

  @override
  Future<AuthResponse> login(String login, String password) async {
    final body = {'login': login, 'password': password};
    final response = await _apiService.post('/api/auth/authenticate', body);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final authResponse = AuthResponseModel.fromJson(json);
      await _tokenLocalDataSource.saveTokens(
        authResponse.accessToken,
        authResponse.refreshToken,
      );
      return authResponse;
    } else {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      throw Exception(json['message'] ?? 'Authentication failed');
    }
  }

  @override
  Future<void> logout() async {
    await _tokenLocalDataSource.clearTokens();
  }

  @override
  Future<String?> getAccessToken() async {
    return _tokenLocalDataSource.getAccessToken();
  }

  @override
  Future<String?> getRefreshToken() async {
    return _tokenLocalDataSource.getRefreshToken();
  }

  @override
  Future<bool> isAuthenticated() async {
    final token = _tokenLocalDataSource.getAccessToken();
    return token != null && token.isNotEmpty;
  }
}
