import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

/// Centralized HTTP client for all API communication.
/// Handles token attachment, error parsing, and timeouts.
class ApiService {
  String? _token;

  /// Set the authentication token for subsequent requests.
  void setToken(String? token) {
    _token = token;
  }

  /// Build headers with optional authentication.
  Map<String, String> get _headers {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  /// Perform a GET request.
  Future<dynamic> get(String endpoint) async {
    try {
      final response = await http
          .get(
            Uri.parse('${ApiConfig.baseUrl}$endpoint'),
            headers: _headers,
          )
          .timeout(ApiConfig.timeout);
      return _handleResponse(response);
    } on SocketException {
      throw ApiException('No internet connection. Please check your network.');
    } on http.ClientException {
      throw ApiException('Unable to connect to the server.');
    }
  }

  /// Perform a POST request.
  Future<dynamic> post(String endpoint, Map<String, dynamic> body) async {
    try {
      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}$endpoint'),
            headers: _headers,
            body: jsonEncode(body),
          )
          .timeout(ApiConfig.timeout);
      return _handleResponse(response);
    } on SocketException {
      throw ApiException('No internet connection. Please check your network.');
    } on http.ClientException {
      throw ApiException('Unable to connect to the server.');
    }
  }

  /// Perform a PUT request.
  Future<dynamic> put(String endpoint, Map<String, dynamic> body) async {
    try {
      final response = await http
          .put(
            Uri.parse('${ApiConfig.baseUrl}$endpoint'),
            headers: _headers,
            body: jsonEncode(body),
          )
          .timeout(ApiConfig.timeout);
      return _handleResponse(response);
    } on SocketException {
      throw ApiException('No internet connection. Please check your network.');
    } on http.ClientException {
      throw ApiException('Unable to connect to the server.');
    }
  }

  /// Perform a DELETE request.
  Future<dynamic> delete(String endpoint) async {
    try {
      final response = await http
          .delete(
            Uri.parse('${ApiConfig.baseUrl}$endpoint'),
            headers: _headers,
          )
          .timeout(ApiConfig.timeout);
      return _handleResponse(response);
    } on SocketException {
      throw ApiException('No internet connection. Please check your network.');
    } on http.ClientException {
      throw ApiException('Unable to connect to the server.');
    }
  }

  /// Parse the response and throw [ApiException] on error status codes.
  dynamic _handleResponse(http.Response response) {
    final body = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }

    final message = body['message'] ?? 'Something went wrong';
    throw ApiException(message, statusCode: response.statusCode);
  }
}

/// Custom exception for API errors with optional status code.
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}
