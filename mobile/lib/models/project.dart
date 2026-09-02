/// Represents a project in DevTrack.
class Project {
  final String id;
  final String name;
  final String description;
  final String status;
  final String user;
  final DateTime createdAt;
  final DateTime updatedAt;

  Project({
    required this.id,
    required this.name,
    required this.description,
    required this.status,
    required this.user,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['_id'] as String,
      name: json['name'] as String,
      description: (json['description'] as String?) ?? '',
      status: json['status'] as String,
      user: json['user'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'status': status,
    };
  }

  /// Valid project statuses
  static const List<String> statuses = ['Planning', 'In Progress', 'Completed'];
}
