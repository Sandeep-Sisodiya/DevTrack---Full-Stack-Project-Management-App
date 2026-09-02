/// Represents a task within a project in DevTrack.
class Task {
  final String id;
  final String title;
  final String description;
  final String priority;
  final String status;
  final DateTime? dueDate;
  final String project;
  final String user;
  final DateTime createdAt;
  final DateTime updatedAt;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.priority,
    required this.status,
    this.dueDate,
    required this.project,
    required this.user,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['_id'] as String,
      title: json['title'] as String,
      description: (json['description'] as String?) ?? '',
      priority: json['priority'] as String,
      status: json['status'] as String,
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate'] as String)
          : null,
      project: json['project'] is Map
          ? json['project']['_id'] as String
          : json['project'] as String,
      user: json['user'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'priority': priority,
      'status': status,
      if (dueDate != null) 'dueDate': dueDate!.toIso8601String(),
    };
  }

  /// Valid task statuses
  static const List<String> statuses = ['Todo', 'In Progress', 'Completed'];

  /// Valid task priorities
  static const List<String> priorities = ['Low', 'Medium', 'High'];
}
