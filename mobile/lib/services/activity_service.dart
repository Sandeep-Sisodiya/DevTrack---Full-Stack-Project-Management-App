import '../models/activity_item.dart';
import 'api_service.dart';

/// Service to fetch activity timeline and audit trail logs.
class ActivityService {
  final ApiService _api;

  ActivityService(this._api);

  /// Fetch chronological activities.
  Future<List<ActivityItem>> getActivities({
    String? projectId,
    int limit = 50,
  }) async {
    final queryParams = <String>[];
    if (projectId != null && projectId.isNotEmpty) {
      queryParams.add('projectId=${Uri.encodeComponent(projectId)}');
    }
    queryParams.add('limit=$limit');

    final query = '?${queryParams.join('&')}';
    final data = await _api.get('/activity$query');
    return (data as List).map((json) => ActivityItem.fromJson(json)).toList();
  }
}
