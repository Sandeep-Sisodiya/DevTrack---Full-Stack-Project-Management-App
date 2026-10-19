import '../models/project.dart';
import 'api_service.dart';

/// Handles project CRUD operations via the backend API.
class ProjectService {
  final ApiService _api;

  ProjectService(this._api);

  /// Get all projects for the authenticated user with optional search and filters.
  Future<List<Project>> getProjects({
    String? search,
    String? status,
    String? category,
  }) async {
    final queryParams = <String>[];
    if (search != null && search.trim().isNotEmpty) {
      queryParams.add('search=${Uri.encodeComponent(search.trim())}');
    }
    if (status != null && status != 'All') {
      queryParams.add('status=${Uri.encodeComponent(status)}');
    }
    if (category != null && category != 'All') {
      queryParams.add('category=${Uri.encodeComponent(category)}');
    }

    final query = queryParams.isNotEmpty ? '?${queryParams.join('&')}' : '';
    final data = await _api.get('/projects$query');
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

  /// Export project deliverables as JSON
  Future<Map<String, dynamic>> exportProjectJson(String id) async {
    final data = await _api.get('/projects/$id/export?format=json');
    return data as Map<String, dynamic>;
  }
}
