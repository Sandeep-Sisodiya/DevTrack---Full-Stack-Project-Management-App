import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../config/theme.dart';
import '../providers/activity_provider.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/error_display.dart';
import '../widgets/empty_state.dart';

/// Screen displaying the chronological activity audit trail and project timeline.
class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  Future<void> _loadActivities() async {
    await Provider.of<ActivityProvider>(context, listen: false)
        .fetchActivities();
  }

  IconData _getActionIcon(String action) {
    switch (action) {
      case 'PROJECT_CREATED':
      case 'PROJECT_UPDATED':
      case 'PROJECT_DELETED':
        return Icons.folder_special;
      case 'TASK_STATUS_CHANGED':
        return Icons.sync_alt;
      case 'SUBTASK_TOGGLED':
        return Icons.checklist_rtl;
      case 'TASK_CREATED':
        return Icons.add_task;
      case 'TASK_DELETED':
        return Icons.delete_outline;
      default:
        return Icons.bolt;
    }
  }

  Color _getActionColor(String action) {
    switch (action) {
      case 'PROJECT_CREATED':
      case 'TASK_CREATED':
        return AppTheme.primaryColor;
      case 'TASK_STATUS_CHANGED':
      case 'SUBTASK_TOGGLED':
        return AppTheme.accentColor;
      case 'PROJECT_DELETED':
      case 'TASK_DELETED':
        return AppTheme.errorColor;
      default:
        return AppTheme.warningColor;
    }
  }

  String _formatTimeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('MMM dd, yyyy').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity Audit Trail'),
        automaticallyImplyLeading: false,
      ),
      body: Consumer<ActivityProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const LoadingIndicator();
          }

          if (provider.error != null) {
            return ErrorDisplay(
              message: provider.error!,
              onRetry: _loadActivities,
            );
          }

          if (provider.activities.isEmpty) {
            return const EmptyState(
              icon: Icons.timeline,
              title: 'No activity yet',
              subtitle: 'Actions on projects and tasks will appear here in real-time.',
            );
          }

          return RefreshIndicator(
            onRefresh: _loadActivities,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: provider.activities.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final activity = provider.activities[index];
                final color = _getActionColor(activity.action);

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _getActionIcon(activity.action),
                            size: 18,
                            color: color,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                activity.details,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  if (activity.projectName.isNotEmpty) ...[
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        activity.projectName,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey[700],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                  ],
                                  Text(
                                    _formatTimeAgo(activity.createdAt),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
