import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/providers/api_provider.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/token_local_datasource.dart';
import '../repositories/auth_repository_impl.dart';

/// Provides SharedPreferences instance
final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) async {
  return SharedPreferences.getInstance();
});

/// Provides TokenLocalDataSource
final tokenLocalDataSourceProvider = FutureProvider<TokenLocalDataSource>((ref) async {
  final prefs = await ref.watch(sharedPreferencesProvider.future);
  return TokenLocalDataSource(prefs);
});

/// Provides AuthRepository instance
final authRepositoryProvider = FutureProvider<AuthRepository>((ref) async {
  final api = ref.watch(apiServiceProvider);
  final tokenDataSource = await ref.watch(tokenLocalDataSourceProvider.future);
  return AuthRepositoryImpl(apiService: api, tokenLocalDataSource: tokenDataSource);
});

/// Manages authentication state: loading, error, or authenticated
final authStateProvider = StateNotifierProvider<AuthStateNotifier, AuthState>((ref) {
  final authRepositoryAsync = ref.watch(authRepositoryProvider);
  return AuthStateNotifier(authRepositoryAsync, ref);
});

class AuthState {
  const AuthState({
    required this.isLoading,
    required this.isAuthenticated,
    required this.error,
  });

  final bool isLoading;
  final bool isAuthenticated;
  final String? error;

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    String? error,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      error: error ?? this.error,
    );
  }
}

class AuthStateNotifier extends StateNotifier<AuthState> {
  AuthStateNotifier(
    this._authRepositoryAsync,
    this._ref,
  ) : super(const AuthState(
        isLoading: false,
        isAuthenticated: false,
        error: null,
      )) {
    _initializeAuth();
  }

  final AsyncValue<AuthRepository> _authRepositoryAsync;
  final Ref _ref;

  void _initializeAuth() {
    _authRepositoryAsync.when(
      data: (repo) async {
        final isAuth = await repo.isAuthenticated();
        state = state.copyWith(isAuthenticated: isAuth);

        // Load token if authenticated
        if (isAuth) {
          final token = await repo.getAccessToken();
          if (token != null) {
            _ref.read(accessTokenProvider.notifier).state = token;
          }
        }
      },
      loading: () {},
      error: (err, stack) {
        state = state.copyWith(error: err.toString());
      },
    );
  }

  Future<void> login(String login, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final repo = await _authRepositoryAsync.when(
        data: (repo) => Future.value(repo),
        loading: () => Future.error('Repository not ready'),
        error: (err, stack) => Future.error(err),
      );
      final authResponse = await repo.login(login, password);

      // Update the global access token provider
      _ref.read(accessTokenProvider.notifier).state = authResponse.accessToken;

      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> logout() async {
    try {
      final repo = await _authRepositoryAsync.when(
        data: (repo) => Future.value(repo),
        loading: () => Future.error('Repository not ready'),
        error: (err, stack) => Future.error(err),
      );
      await repo.logout();
      _ref.read(accessTokenProvider.notifier).state = null;
      state = state.copyWith(isAuthenticated: false, error: null);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}
