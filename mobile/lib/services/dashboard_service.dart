import '../models/project.dart';
import '../models/task.dart';
import '../models/activity_item.dart';
import 'api_service.dart';

/// Dashboard statistics from the backend API.
class DashboardData {
  final int totalProjects;
  final int totalTasks;
  final int pendingTasks;
  final int completedTasks;
  final int overdueTasks;
  final int completionRate;
  final List<Project> recentProjects;
  final List<Task> recentTasks;
  final List<ActivityItem> recentActivities;

  DashboardData({
    required this.totalProjects,
    required this.totalTasks,
    required this.pendingTasks,
    required this.completedTasks,
    this.overdueTasks = 0,
    this.completionRate = 0,
    required this.recentProjects,
    required this.recentTasks,
    this.recentActivities = const [],
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      totalProjects: (json['totalProjects'] as num?)?.toInt() ?? 0,
      totalTasks: (json['totalTasks'] as num?)?.toInt() ?? 0,
      pendingTasks: (json['pendingTasks'] as num?)?.toInt() ?? 0,
      completedTasks: (json['completedTasks'] as num?)?.toInt() ?? 0,
      overdueTasks: (json['overdueTasks'] as num?)?.toInt() ?? 0,
      completionRate: (json['completionRate'] as num?)?.toInt() ?? 0,
      recentProjects: (json['recentProjects'] as List? ?? [])
          .map((p) => Project.fromJson(p as Map<String, dynamic>))
          .toList(),
      recentTasks: (json['recentTasks'] as List? ?? [])
          .map((t) => Task.fromJson(t as Map<String, dynamic>))
          .toList(),
      recentActivities: (json['recentActivities'] as List? ?? [])
          .map((a) => ActivityItem.fromJson(a as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Fetches dashboard statistics and analytics from the backend.
class DashboardService {
  final ApiService _api;

  DashboardService(this._api);

  Future<DashboardData> getDashboard() async {
    final data = await _api.get('/dashboard');
    return DashboardData.fromJson(data);
  }

  Future<Map<String, dynamic>> getAnalytics() async {
    final data = await _api.get('/dashboard/analytics');
    return data as Map<String, dynamic>;
  }
}
