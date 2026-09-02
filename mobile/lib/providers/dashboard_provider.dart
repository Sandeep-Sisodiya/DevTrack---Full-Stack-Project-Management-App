import 'package:flutter/material.dart';
import '../services/dashboard_service.dart';
import '../services/api_service.dart';

/// Manages dashboard statistics state.
class DashboardProvider with ChangeNotifier {
  final DashboardService _dashboardService;

  DashboardData? _data;
  bool _isLoading = false;
  String? _error;

  DashboardProvider(this._dashboardService);

  DashboardData? get data => _data;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Fetch dashboard stats from the API.
  Future<void> fetchDashboard() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _data = await _dashboardService.getDashboard();
    } on ApiException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Failed to load dashboard.';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Clear dashboard data (e.g., on logout).
  void clear() {
    _data = null;
    _error = null;
    notifyListeners();
  }
}
