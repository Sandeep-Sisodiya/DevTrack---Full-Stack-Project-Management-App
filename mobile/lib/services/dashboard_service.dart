import '../models/project.dart';
import '../models/task.dart';
import 'api_service.dart';

/// Dashboard statistics from the backend API.
class DashboardData {
  final int totalProjects;
  final int totalTasks;
  final int pendingTasks;
  final int completedTasks;
  final List<Project> recentProjects;
  final List<Task> recentTasks;

  DashboardData({
    required this.totalProjects,
    required this.totalTasks,
    required this.pendingTasks,
    required this.completedTasks,
    required this.recentProjects,
    required this.recentTasks,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      totalProjects: json['totalProjects'] as int,
      totalTasks: json['totalTasks'] as int,
      pendingTasks: json['pendingTasks'] as int,
      completedTasks: json['completedTasks'] as int,
      recentProjects: (json['recentProjects'] as List)
          .map((p) => Project.fromJson(p))
          .toList(),
      recentTasks: (json['recentTasks'] as List)
          .map((t) => Task.fromJson(t))
          .toList(),
    );
  }
}

/// Fetches dashboard statistics from the backend.
class DashboardService {
  final ApiService _api;

  DashboardService(this._api);

  Future<DashboardData> getDashboard() async {
    final data = await _api.get('/dashboard');
    return DashboardData.fromJson(data);
  }
}
