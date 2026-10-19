import 'package:flutter/material.dart';
import '../models/project.dart';
import '../services/project_service.dart';
import '../services/api_service.dart';

/// Manages project list state, search, filtering, and CRUD operations.
class ProjectProvider with ChangeNotifier {
  final ProjectService _projectService;

  List<Project> _projects = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  String _statusFilter = 'All';
  String _categoryFilter = 'All';

  ProjectProvider(this._projectService);

  List<Project> get projects => _projects;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  String get statusFilter => _statusFilter;
  String get categoryFilter => _categoryFilter;

  /// Fetch all projects from the API with current search & filters.
  Future<void> fetchProjects({
    String? search,
    String? status,
    String? category,
  }) async {
    if (search != null) _searchQuery = search;
    if (status != null) _statusFilter = status;
    if (category != null) _categoryFilter = category;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _projects = await _projectService.getProjects(
        search: _searchQuery,
        status: _statusFilter,
        category: _categoryFilter,
      );
    } on ApiException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Failed to load projects: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Create a new project.
  Future<bool> createProject(Map<String, dynamic> data) async {
    try {
      final project = await _projectService.createProject(data);
      _projects.insert(0, project);
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Failed to create project.';
      notifyListeners();
      return false;
    }
  }

  /// Update an existing project.
  Future<bool> updateProject(String id, Map<String, dynamic> data) async {
    try {
      final updated = await _projectService.updateProject(id, data);
      final index = _projects.indexWhere((p) => p.id == id);
      if (index != -1) {
        _projects[index] = updated;
        notifyListeners();
      }
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Failed to update project.';
      notifyListeners();
      return false;
    }
  }

  /// Delete a project.
  Future<bool> deleteProject(String id) async {
    try {
      await _projectService.deleteProject(id);
      _projects.removeWhere((p) => p.id == id);
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Failed to delete project.';
      notifyListeners();
      return false;
    }
  }

  /// Export project deliverables as JSON
  Future<Map<String, dynamic>?> exportProject(String id) async {
    try {
      return await _projectService.exportProjectJson(id);
    } catch (e) {
      _error = 'Export failed: $e';
      notifyListeners();
      return null;
    }
  }

  /// Clear projects (e.g., on logout).
  void clear() {
    _projects = [];
    _error = null;
    _searchQuery = '';
    _statusFilter = 'All';
    _categoryFilter = 'All';
    notifyListeners();
  }
}
