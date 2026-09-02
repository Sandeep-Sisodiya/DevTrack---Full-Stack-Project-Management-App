import '../models/task.dart';
import 'api_service.dart';

/// Handles task CRUD operations via the backend API.
class TaskService {
  final ApiService _api;

  TaskService(this._api);

  /// Get all tasks for a specific project.
  Future<List<Task>> getTasks(String projectId) async {
    final data = await _api.get('/projects/$projectId/tasks');
    return (data as List).map((json) => Task.fromJson(json)).toList();
  }

  /// Create a new task within a project.
  Future<Task> createTask(
      String projectId, Map<String, dynamic> taskData) async {
    final data = await _api.post('/projects/$projectId/tasks', taskData);
    return Task.fromJson(data);
  }

  /// Update an existing task.
  Future<Task> updateTask(String taskId, Map<String, dynamic> taskData) async {
    final data = await _api.put('/tasks/$taskId', taskData);
    return Task.fromJson(data);
  }

  /// Delete a task.
  Future<void> deleteTask(String taskId) async {
    await _api.delete('/tasks/$taskId');
  }
}
