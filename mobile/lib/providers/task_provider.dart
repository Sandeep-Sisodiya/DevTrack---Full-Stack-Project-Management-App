import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/task_service.dart';
import '../services/api_service.dart';

/// Manages task list state, filters, subtask checklist operations, and CRUD.
class TaskProvider with ChangeNotifier {
  final TaskService _taskService;

  List<Task> _tasks = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  String _statusFilter = 'All';
  String _priorityFilter = 'All';
  String _tagFilter = 'All';

  TaskProvider(this._taskService);

  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  String get statusFilter => _statusFilter;
  String get priorityFilter => _priorityFilter;
  String get tagFilter => _tagFilter;

  /// Tasks filtered by status for Kanban-style display.
  List<Task> getTasksByStatus(String status) {
    return _tasks.where((t) => t.status == status).toList();
  }

  /// Fetch all tasks for a specific project with search and filters.
  Future<void> fetchTasks(
    String projectId, {
    String? search,
    String? status,
    String? priority,
    String? tag,
  }) async {
    if (search != null) _searchQuery = search;
    if (status != null) _statusFilter = status;
    if (priority != null) _priorityFilter = priority;
    if (tag != null) _tagFilter = tag;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _tasks = await _taskService.getTasks(
        projectId,
        search: _searchQuery,
        status: _statusFilter,
        priority: _priorityFilter,
        tag: _tagFilter != 'All' ? _tagFilter : null,
      );
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

  /// Toggle an individual subtask's completion status with instant reactivity.
  Future<bool> toggleSubtask(String taskId, String subtaskId) async {
    try {
      final updated = await _taskService.toggleSubtask(taskId, subtaskId);
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
      _error = 'Failed to toggle checklist item.';
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
    _searchQuery = '';
    _statusFilter = 'All';
    _priorityFilter = 'All';
    _tagFilter = 'All';
    notifyListeners();
  }
}
