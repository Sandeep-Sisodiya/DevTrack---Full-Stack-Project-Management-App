import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../config/theme.dart';
import '../models/task.dart';

/// A card widget displaying rich task summary information,
/// including priority, checklist completion, tags, and quick status switcher.
class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback? onTap;
  final ValueChanged<String>? onStatusChanged;

  const TaskCard({
    super.key,
    required this.task,
    this.onTap,
    this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    final priorityColor = AppTheme.getPriorityColor(task.priority);
    final statusColor = AppTheme.getStatusColor(task.status);
    final isOverdue = task.dueDate != null &&
        task.dueDate!.isBefore(DateTime.now()) &&
        task.status != 'Completed';

    final subtasksDone = task.subtasks.where((s) => s.isCompleted).length;
    final totalSubtasks = task.subtasks.length;

    return Card(
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Priority indicator stripe
                  Container(
                    width: 4,
                    height: 44,
                    decoration: BoxDecoration(
                      color: priorityColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Title and metadata
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            decoration: task.status == 'Completed'
                                ? TextDecoration.lineThrough
                                : null,
                            color: task.status == 'Completed'
                                ? Colors.grey[500]
                                : Colors.black87,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),

                        // Badges Row
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            // Priority badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: priorityColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                task.priority,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: priorityColor,
                                ),
                              ),
                            ),

                            // Subtask checklist counter
                            if (totalSubtasks > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.check_box_outlined,
                                      size: 11,
                                      color: Colors.blue[700],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '$subtasksDone/$totalSubtasks',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.blue[700],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            // Estimated hours
                            if (task.estimatedHours > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${task.estimatedHours.toStringAsFixed(task.estimatedHours.truncateToDouble() == task.estimatedHours ? 0 : 1)}h est',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ),

                            // Due date / Overdue
                            if (task.dueDate != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: isOverdue
                                      ? Colors.red.withValues(alpha: 0.12)
                                      : Colors.grey.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      isOverdue
                                          ? Icons.warning_amber_rounded
                                          : Icons.schedule,
                                      size: 11,
                                      color: isOverdue
                                          ? Colors.red[700]
                                          : Colors.grey[600],
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      DateFormat('MMM dd').format(task.dueDate!),
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: isOverdue
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        color: isOverdue
                                            ? Colors.red[700]
                                            : Colors.grey[700],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Quick status change dropdown
                  if (onStatusChanged != null)
                    PopupMenuButton<String>(
                      tooltip: 'Change Status',
                      icon: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          task.status,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: statusColor,
                          ),
                        ),
                      ),
                      onSelected: onStatusChanged,
                      itemBuilder: (context) => Task.statuses
                          .map((s) => PopupMenuItem(
                                value: s,
                                child: Row(
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: AppTheme.getStatusColor(s),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(s),
                                  ],
                                ),
                              ))
                          .toList(),
                    ),
                ],
              ),

              // Tags row (if any)
              if (task.tags.isNotEmpty) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 4,
                  children: task.tags.map((t) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '#$t',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[600],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
