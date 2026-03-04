import 'dart:convert';

import 'package:http/http.dart' as http;

/// A thin wrapper around `http` to centralize base URL, headers,
/// and error handling. Other repositories can depend on this service to
/// communicate with a backend API.
///
/// When an access token is provided, it is automatically added to all
/// requests in the Authorization header.
///
/// In a real application you may want to switch to `dio` or another
/// client and/or add interceptors, caching, etc.
class ApiService {
  ApiService({required this.baseUrl, this.accessToken});

  final String baseUrl;
  final String? accessToken;

  Map<String, String> get defaultHeaders {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (accessToken != null && accessToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $accessToken';
    }
    return headers;
  }

  Future<http.Response> get(String path) {
    final uri = Uri.parse('$baseUrl$path');
    return http.get(uri, headers: defaultHeaders);
  }

  Future<http.Response> post(String path, Map<String, dynamic> body) {
    final uri = Uri.parse('$baseUrl$path');
    return http.post(uri, headers: defaultHeaders, body: jsonEncode(body));
  }

  // add put, delete, etc. as needed
}

