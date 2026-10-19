/// Represents a project in DevTrack.
class Project {
  final String id;
  final String name;
  final String description;
  final String status;
  final String category;
  final String color;
  final List<String> tags;
  final int totalTasks;
  final int completedTasks;
  final int progressPercentage;
  final String user;
  final DateTime createdAt;
  final DateTime updatedAt;

  Project({
    required this.id,
    required this.name,
    required this.description,
    required this.status,
    this.category = 'General',
    this.color = '#6C63FF',
    this.tags = const [],
    this.totalTasks = 0,
    this.completedTasks = 0,
    this.progressPercentage = 0,
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
      category: (json['category'] as String?) ?? 'General',
      color: (json['color'] as String?) ?? '#6C63FF',
      tags: json['tags'] != null
          ? List<String>.from(json['tags'] as List)
          : const [],
      totalTasks: (json['totalTasks'] as num?)?.toInt() ?? 0,
      completedTasks: (json['completedTasks'] as num?)?.toInt() ?? 0,
      progressPercentage: (json['progressPercentage'] as num?)?.toInt() ?? 0,
      user: json['user'] is Map ? (json['user']['_id'] as String? ?? '') : (json['user'] as String? ?? ''),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'status': status,
      'category': category,
      'color': color,
      'tags': tags,
    };
  }

  /// Valid project statuses
  static const List<String> statuses = ['Planning', 'In Progress', 'Completed'];

  /// Suggested project categories
  static const List<String> categories = [
    'General',
    'Frontend',
    'Backend',
    'Mobile',
    'DevOps',
    'Full-Stack',
    'AI / ML',
  ];
}
