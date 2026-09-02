import '../models/project.dart';
import 'api_service.dart';

/// Handles project CRUD operations via the backend API.
class ProjectService {
  final ApiService _api;

  ProjectService(this._api);

  /// Get all projects for the authenticated user.
  Future<List<Project>> getProjects() async {
    final data = await _api.get('/projects');
    return (data as List).map((json) => Project.fromJson(json)).toList();
  }

  /// Get a single project by ID.
  Future<Project> getProject(String id) async {
    final data = await _api.get('/projects/$id');
    return Project.fromJson(data);
  }

  /// Create a new project.
  Future<Project> createProject(Map<String, dynamic> projectData) async {
    final data = await _api.post('/projects', projectData);
    return Project.fromJson(data);
  }

  /// Update an existing project.
  Future<Project> updateProject(
      String id, Map<String, dynamic> projectData) async {
    final data = await _api.put('/projects/$id', projectData);
    return Project.fromJson(data);
  }

  /// Delete a project (and all its tasks).
  Future<void> deleteProject(String id) async {
    await _api.delete('/projects/$id');
  }
}
