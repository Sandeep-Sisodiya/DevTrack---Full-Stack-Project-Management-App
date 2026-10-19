import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../config/theme.dart';
import '../models/project.dart';

/// A card widget displaying rich project summary information,
/// including category, status, and task completion progress.
class ProjectCard extends StatelessWidget {
  final Project project;
  final VoidCallback? onTap;

  const ProjectCard({
    super.key,
    required this.project,
    this.onTap,
  });

  Color _parseHexColor(String hex) {
    try {
      final buffer = StringBuffer();
      if (hex.length == 6 || hex.length == 7) buffer.write('ff');
      buffer.write(hex.replaceFirst('#', ''));
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (_) {
      return AppTheme.primaryColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = AppTheme.getStatusColor(project.status);
    final brandColor = _parseHexColor(project.color);
    final progress = (project.progressPercentage.clamp(0, 100)) / 100.0;

    return Card(
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: Category tag & Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: brandColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: brandColor.withValues(alpha: 0.25),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      project.category,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: brandColor,
                      ),
                    ),
                  ),
                  _StatusChip(status: project.status, color: statusColor),
                ],
              ),
              const SizedBox(height: 10),

              // Project Name
              Text(
                project.name,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              if (project.description.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  project.description,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              const SizedBox(height: 14),

              // Progress bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    project.totalTasks > 0
                        ? '${project.completedTasks}/${project.totalTasks} tasks done'
                        : 'No tasks yet',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    '${project.progressPercentage}%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: project.progressPercentage == 100
                          ? AppTheme.accentColor
                          : AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: Colors.grey.withValues(alpha: 0.15),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    project.progressPercentage == 100
                        ? AppTheme.accentColor
                        : brandColor,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Footer: Tags + Created Date
              Row(
                children: [
                  if (project.tags.isNotEmpty)
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: project.tags.take(3).map((tag) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.grey.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '#$tag',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    )
                  else
                    const Spacer(),
                  const SizedBox(width: 8),
                  Icon(Icons.calendar_today_outlined,
                      size: 13, color: Colors.grey[400]),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('MMM dd').format(project.createdAt),
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  final Color color;

  const _StatusChip({required this.status, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
