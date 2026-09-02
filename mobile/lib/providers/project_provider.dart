import 'package:flutter/material.dart';
import '../models/project.dart';
import '../services/project_service.dart';
import '../services/api_service.dart';

/// Manages project list state and CRUD operations.
class ProjectProvider with ChangeNotifier {
  final ProjectService _projectService;

  List<Project> _projects = [];
  bool _isLoading = false;
  String? _error;

  ProjectProvider(this._projectService);

  List<Project> get projects => _projects;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Fetch all projects from the API.
  Future<void> fetchProjects() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _projects = await _projectService.getProjects();
    } on ApiException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Failed to load projects.';
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

  /// Clear projects (e.g., on logout).
  void clear() {
    _projects = [];
    _error = null;
    notifyListeners();
  }
}
