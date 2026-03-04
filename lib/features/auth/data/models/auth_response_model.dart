import '../../domain/entities/auth_entities.dart';

class AuthResponseModel extends AuthResponse {
  AuthResponseModel({
    required String accessToken,
    required String refreshToken,
    required String message,
    required int status,
    required String timestamp,
  }) : super(
          accessToken: accessToken,
          refreshToken: refreshToken,
          message: message,
          status: status,
          timestamp: timestamp,
        );

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      accessToken: json['data']['access_token'] as String,
      refreshToken: json['data']['refresh_token'] as String,
      message: json['message'] as String,
      status: json['status'] as int,
      timestamp: json['timestamp'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'access_token': accessToken,
        'refresh_token': refreshToken,
        'message': message,
        'status': status,
        'timestamp': timestamp,
      };
}
