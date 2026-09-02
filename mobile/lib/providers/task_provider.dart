import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/task_service.dart';
import '../services/api_service.dart';

/// Manages task list state and CRUD operations for a specific project.
class TaskProvider with ChangeNotifier {
  final TaskService _taskService;

  List<Task> _tasks = [];
  bool _isLoading = false;
  String? _error;

  TaskProvider(this._taskService);

  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Tasks filtered by status for Kanban-style display.
  List<Task> getTasksByStatus(String status) {
    return _tasks.where((t) => t.status == status).toList();
  }

  /// Fetch all tasks for a specific project.
  Future<void> fetchTasks(String projectId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _tasks = await _taskService.getTasks(projectId);
    } on ApiException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Failed to load tasks.';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Create a new task in a project.
  Future<bool> createTask(
      String projectId, Map<String, dynamic> data) async {
    try {
      final task = await _taskService.createTask(projectId, data);
      _tasks.insert(0, task);
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Failed to create task.';
      notifyListeners();
      return false;
    }
  }

  /// Update an existing task.
  Future<bool> updateTask(String taskId, Map<String, dynamic> data) async {
    try {
      final updated = await _taskService.updateTask(taskId, data);
      final index = _tasks.indexWhere((t) => t.id == taskId);
      if (index != -1) {
        _tasks[index] = updated;
        notifyListeners();
      }
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Failed to update task.';
      notifyListeners();
      return false;
    }
  }

  /// Delete a task.
  Future<bool> deleteTask(String taskId) async {
    try {
      await _taskService.deleteTask(taskId);
      _tasks.removeWhere((t) => t.id == taskId);
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Failed to delete task.';
      notifyListeners();
      return false;
    }
  }

  /// Clear tasks (e.g., when navigating away).
  void clear() {
    _tasks = [];
    _error = null;
    notifyListeners();
  }
}
