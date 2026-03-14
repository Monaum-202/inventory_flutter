import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../../features/auth/data/providers/auth_provider.dart';

// This will be overridden by the actual auth provider once auth is initialized
final accessTokenProvider = StateProvider<String?>((ref) {
  return null;
});

/// Api service provider that includes the current access token if available.
/// The token is automatically added to the Authorization header of requests.
final apiServiceProvider = Provider<ApiService>((ref) {
  final token = ref.watch(accessTokenProvider);
    return ApiService(
    baseUrl: 'http://192.168.0.102:9091',
    accessToken: token,
  );
});

