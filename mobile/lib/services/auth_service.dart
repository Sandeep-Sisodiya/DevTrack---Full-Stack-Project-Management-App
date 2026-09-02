import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import 'api_service.dart';

/// Handles authentication operations: login, register, token storage.
class AuthService {
  final ApiService _api;
  static const String _tokenKey = 'auth_token';

  AuthService(this._api);

  /// Register a new user. Returns the user and stores the token.
  Future<User> register(String name, String email, String password) async {
    final data = await _api.post('/auth/register', {
      'name': name,
      'email': email,
      'password': password,
    });

    final token = data['token'] as String;
    await _saveToken(token);
    _api.setToken(token);

    return User.fromJson(data['user']);
  }

  /// Login with email and password. Returns the user and stores the token.
  Future<User> login(String email, String password) async {
    final data = await _api.post('/auth/login', {
      'email': email,
      'password': password,
    });

    final token = data['token'] as String;
    await _saveToken(token);
    _api.setToken(token);

    return User.fromJson(data['user']);
  }

  /// Try to restore a previous session from stored token.
  /// Returns the user if a valid token exists, null otherwise.
  Future<User?> tryAutoLogin() async {
    final token = await _getToken();
    if (token == null) return null;

    _api.setToken(token);

    try {
      final data = await _api.get('/users/me');
      return User.fromJson(data);
    } catch (_) {
      // Token is invalid or expired — clear it
      await _clearToken();
      _api.setToken(null);
      return null;
    }
  }

  /// Logout: clear stored token and remove from API service.
  Future<void> logout() async {
    await _clearToken();
    _api.setToken(null);
  }

  /// Get current user profile.
  Future<User> getProfile() async {
    final data = await _api.get('/users/me');
    return User.fromJson(data);
  }

  // ─── Token storage helpers ──────────────────────────────────────

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<void> _clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }
}
