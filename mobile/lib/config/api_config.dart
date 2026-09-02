/// API configuration for the DevTrack Flutter application.
///
/// Change [baseUrl] to point to your running backend server.
/// For Android emulator, use 10.0.2.2 instead of localhost.
/// For physical device, use your computer's local IP address.
class ApiConfig {
  // Default: backend running on localhost:5000
  // Android emulator uses 10.0.2.2 to reach host machine's localhost
  static const String baseUrl = 'http://10.0.2.2:5000/api';

  // Request timeout duration
  static const Duration timeout = Duration(seconds: 15);
}
