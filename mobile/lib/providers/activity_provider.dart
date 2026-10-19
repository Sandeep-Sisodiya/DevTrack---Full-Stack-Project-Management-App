import 'package:flutter/foundation.dart';
import '../models/activity_item.dart';
import '../services/activity_service.dart';

/// Provider managing activity timeline and audit log state.
class ActivityProvider extends ChangeNotifier {
  final ActivityService _activityService;

  List<ActivityItem> _activities = [];
  bool _isLoading = false;
  String? _error;

  ActivityProvider(this._activityService);

  List<ActivityItem> get activities => _activities;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchActivities({String? projectId}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _activities = await _activityService.getActivities(projectId: projectId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
