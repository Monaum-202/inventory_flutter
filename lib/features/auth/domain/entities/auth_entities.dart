/// Represents the result of a successful authentication.
class AuthResponse {
  AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.message,
    required this.status,
    required this.timestamp,
  });

  final String accessToken;
  final String refreshToken;
  final String message;
  final int status;
  final String timestamp;
}

/// Represents the current authenticated user.
class User {
  User({
    required this.userId,
    required this.login,
    required this.roleId,
  });

  final int userId;
  final String login;
  final int roleId;
}
