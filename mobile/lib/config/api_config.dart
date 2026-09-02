import 'package:shared_preferences/shared_preferences.dart';

/// API configuration for the DevTrack Flutter application.
class ApiConfig {
  static const String _serverUrlKey = 'custom_server_url';
  
  // Default URL: Android emulator loopback to host machine localhost:5000
  static const String defaultUrl = 'http://10.0.2.2:5000/api';
  
  static String _currentBaseUrl = defaultUrl;

  /// Get the active base URL
  static String get baseUrl => _currentBaseUrl;

  /// Timeout duration for requests
  static const Duration timeout = Duration(seconds: 15);

  /// Load persisted server URL from SharedPreferences
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUrl = prefs.getString(_serverUrlKey);
    if (savedUrl != null && savedUrl.isNotEmpty) {
      _currentBaseUrl = savedUrl;
    }
  }

  /// Update and persist the base URL
  static Future<void> setBaseUrl(String url) async {
    var formattedUrl = url.trim();
    if (formattedUrl.endsWith('/')) {
      formattedUrl = formattedUrl.substring(0, formattedUrl.length - 1);
    }
    if (!formattedUrl.endsWith('/api')) {
      formattedUrl = '$formattedUrl/api';
    }
    _currentBaseUrl = formattedUrl;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_serverUrlKey, formattedUrl);
  }

  /// Reset to default
  static Future<void> resetToDefault() async {
    _currentBaseUrl = defaultUrl;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_serverUrlKey);
  }
}
