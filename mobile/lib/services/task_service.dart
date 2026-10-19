import '../models/task.dart';
import 'api_service.dart';

/// Handles task CRUD operations via the backend API.
class TaskService {
  final ApiService _api;

  TaskService(this._api);

  /// Get all tasks for a specific project with optional search and filters.
  Future<List<Task>> getTasks(
    String projectId, {
    String? search,
    String? status,
    String? priority,
    String? tag,
  }) async {
    final queryParams = <String>[];
    if (search != null && search.trim().isNotEmpty) {
      queryParams.add('search=${Uri.encodeComponent(search.trim())}');
    }
    if (status != null && status != 'All') {
      queryParams.add('status=${Uri.encodeComponent(status)}');
    }
    if (priority != null && priority != 'All') {
      queryParams.add('priority=${Uri.encodeComponent(priority)}');
    }
    if (tag != null && tag.trim().isNotEmpty) {
      queryParams.add('tag=${Uri.encodeComponent(tag.trim())}');
    }

    final query = queryParams.isNotEmpty ? '?${queryParams.join('&')}' : '';
    final data = await _api.get('/projects/$projectId/tasks$query');
    return (data as List).map((json) => Task.fromJson(json)).toList();
  }

  /// Get a single task by ID.
  Future<Task> getTask(String taskId) async {
    final data = await _api.get('/tasks/$taskId');
    return Task.fromJson(data);
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

  /// Toggle an individual subtask completion state.
  Future<Task> toggleSubtask(String taskId, String subtaskId) async {
    final data = await _api.patch('/tasks/$taskId/subtasks/$subtaskId/toggle');
    return Task.fromJson(data);
  }

  /// Delete a task.
  Future<void> deleteTask(String taskId) async {
    await _api.delete('/tasks/$taskId');
  }
}
