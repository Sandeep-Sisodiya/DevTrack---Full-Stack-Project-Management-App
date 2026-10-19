/// Represents an audit log or timeline activity entry.
class ActivityItem {
  final String id;
  final String action;
  final String projectName;
  final String taskTitle;
  final String details;
  final DateTime createdAt;

  ActivityItem({
    required this.id,
    required this.action,
    required this.projectName,
    required this.taskTitle,
    required this.details,
    required this.createdAt,
  });

  factory ActivityItem.fromJson(Map<String, dynamic> json) {
    return ActivityItem(
      id: (json['_id'] ?? '') as String,
      action: (json['action'] ?? '') as String,
      projectName: (json['projectName'] ?? '') as String,
      taskTitle: (json['taskTitle'] ?? '') as String,
      details: (json['details'] ?? '') as String,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }
}
