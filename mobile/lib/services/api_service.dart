import 'dart:async';
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
    final url = '${ApiConfig.baseUrl}$endpoint';
    try {
      final response = await http
          .get(
            Uri.parse(url),
            headers: _headers,
          )
          .timeout(ApiConfig.timeout);
      return _handleResponse(response);
    } on SocketException catch (e) {
      throw ApiException(
        'Cannot connect to backend server ($url).\nError: ${e.message}. If using a real phone, please configure your PC\'s Wi-Fi IP in Server Settings.',
      );
    } on TimeoutException {
      throw ApiException(
        'Server request timed out ($url). Please verify the backend is running.',
      );
    } on http.ClientException catch (e) {
      throw ApiException(
        'Network error: ${e.message}. Server at $url unreachable.',
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Unexpected network error: $e');
    }
  }

  /// Perform a POST request.
  Future<dynamic> post(String endpoint, Map<String, dynamic> body) async {
    final url = '${ApiConfig.baseUrl}$endpoint';
    try {
      final response = await http
          .post(
            Uri.parse(url),
            headers: _headers,
            body: jsonEncode(body),
          )
          .timeout(ApiConfig.timeout);
      return _handleResponse(response);
    } on SocketException catch (e) {
      throw ApiException(
        'Cannot connect to backend server ($url).\nError: ${e.message}. If using a real phone, please configure your PC\'s Wi-Fi IP in Server Settings.',
      );
    } on TimeoutException {
      throw ApiException(
        'Server request timed out ($url). Please verify the backend is running.',
      );
    } on http.ClientException catch (e) {
      throw ApiException(
        'Network error: ${e.message}. Server at $url unreachable.',
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Unexpected network error: $e');
    }
  }

  /// Perform a PUT request.
  Future<dynamic> put(String endpoint, Map<String, dynamic> body) async {
    final url = '${ApiConfig.baseUrl}$endpoint';
    try {
      final response = await http
          .put(
            Uri.parse(url),
            headers: _headers,
            body: jsonEncode(body),
          )
          .timeout(ApiConfig.timeout);
      return _handleResponse(response);
    } on SocketException catch (e) {
      throw ApiException(
        'Cannot connect to backend server ($url).\nError: ${e.message}. If using a real phone, please configure your PC\'s Wi-Fi IP in Server Settings.',
      );
    } on TimeoutException {
      throw ApiException(
        'Server request timed out ($url). Please verify the backend is running.',
      );
    } on http.ClientException catch (e) {
      throw ApiException(
        'Network error: ${e.message}. Server at $url unreachable.',
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Unexpected network error: $e');
    }
  }

  /// Perform a DELETE request.
  Future<dynamic> delete(String endpoint) async {
    final url = '${ApiConfig.baseUrl}$endpoint';
    try {
      final response = await http
          .delete(
            Uri.parse(url),
            headers: _headers,
          )
          .timeout(ApiConfig.timeout);
      return _handleResponse(response);
    } on SocketException catch (e) {
      throw ApiException(
        'Cannot connect to backend server ($url).\nError: ${e.message}. If using a real phone, please configure your PC\'s Wi-Fi IP in Server Settings.',
      );
    } on TimeoutException {
      throw ApiException(
        'Server request timed out ($url). Please verify the backend is running.',
      );
    } on http.ClientException catch (e) {
      throw ApiException(
        'Network error: ${e.message}. Server at $url unreachable.',
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Unexpected network error: $e');
    }
  }

  /// Parse the response and throw [ApiException] on error status codes.
  dynamic _handleResponse(http.Response response) {
    try {
      final body = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return body;
      }

      final message = body['message'] ?? 'Request failed with status ${response.statusCode}';
      throw ApiException(message, statusCode: response.statusCode);
    } on FormatException {
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return response.body;
      }
      throw ApiException(
        'Server returned HTTP ${response.statusCode}: ${response.reasonPhrase ?? 'Unknown error'}',
        statusCode: response.statusCode,
      );
    }
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
