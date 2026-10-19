/// Represents an individual checklist subtask inside a Task.
class Subtask {
  final String id;
  final String title;
  final bool isCompleted;

  Subtask({
    required this.id,
    required this.title,
    this.isCompleted = false,
  });

  factory Subtask.fromJson(Map<String, dynamic> json) {
    return Subtask(
      id: (json['_id'] ?? json['id'] ?? '') as String,
      title: (json['title'] as String?) ?? '',
      isCompleted: (json['isCompleted'] as bool?) ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) '_id': id,
      'title': title,
      'isCompleted': isCompleted,
    };
  }

  Subtask copyWith({String? id, String? title, bool? isCompleted}) {
    return Subtask(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

/// Represents a task within a project in DevTrack.
class Task {
  final String id;
  final String title;
  final String description;
  final String priority;
  final String status;
  final DateTime? dueDate;
  final double estimatedHours;
  final int progressPercentage;
  final List<String> tags;
  final List<Subtask> subtasks;
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
    this.estimatedHours = 0.0,
    this.progressPercentage = 0,
    this.tags = const [],
    this.subtasks = const [],
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
      estimatedHours: (json['estimatedHours'] as num?)?.toDouble() ?? 0.0,
      progressPercentage: (json['progressPercentage'] as num?)?.toInt() ?? 0,
      tags: json['tags'] != null
          ? List<String>.from(json['tags'] as List)
          : const [],
      subtasks: json['subtasks'] != null
          ? (json['subtasks'] as List)
              .map((s) => Subtask.fromJson(s as Map<String, dynamic>))
              .toList()
          : const [],
      project: json['project'] is Map
          ? (json['project']['_id'] as String? ?? '')
          : (json['project'] as String? ?? ''),
      user: json['user'] is Map
          ? (json['user']['_id'] as String? ?? '')
          : (json['user'] as String? ?? ''),
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
      'estimatedHours': estimatedHours,
      'tags': tags,
      'subtasks': subtasks.map((s) => s.toJson()).toList(),
    };
  }

  /// Valid task statuses
  static const List<String> statuses = ['Todo', 'In Progress', 'Completed'];

  /// Valid task priorities
  static const List<String> priorities = ['Low', 'Medium', 'High'];

  /// Suggested task tags
  static const List<String> suggestedTags = [
    'Frontend',
    'Backend',
    'Bug',
    'Feature',
    'UI/UX',
    'Database',
    'DevOps',
    'Testing',
  ];
}
