import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../config/theme.dart';
import '../models/project.dart';
import '../models/task.dart';
import '../providers/project_provider.dart';
import '../providers/task_provider.dart';
import '../widgets/task_card.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/error_display.dart';
import '../widgets/empty_state.dart';

/// Project detail screen showing project stats, export deliverables,
/// live task search, and Kanban-style task columns.
class ProjectDetailScreen extends StatefulWidget {
  final String projectId;

  const ProjectDetailScreen({super.key, required this.projectId});

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  Project? _project;
  bool _isLoadingProject = true;
  String _taskSearch = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoadingProject = true);

    try {
      final projectProvider =
          Provider.of<ProjectProvider>(context, listen: false);
      final projects = projectProvider.projects;
      final found = projects.where((p) => p.id == widget.projectId);
      if (found.isNotEmpty) {
        _project = found.first;
      }
    } catch (_) {}

    setState(() => _isLoadingProject = false);

    if (mounted) {
      await Provider.of<TaskProvider>(context, listen: false)
          .fetchTasks(widget.projectId, search: _taskSearch);
    }
  }

  Future<void> _exportProjectDeliverables() async {
    final provider = Provider.of<ProjectProvider>(context, listen: false);
    final exportData = await provider.exportProject(widget.projectId);

    if (!mounted) return;

    if (exportData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to generate export bundle')),
      );
      return;
    }

    final taskCount = exportData['taskCount'] ?? 0;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.file_download_done, color: AppTheme.accentColor),
            SizedBox(width: 8),
            Text('Project Exported'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Project: ${_project?.name ?? "DevTrack"}',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text('Total Deliverables: $taskCount task(s) bundled'),
            const SizedBox(height: 4),
            Text(
              'Exported successfully in JSON & CSV format. Ready for executive reporting and audit compliance.',
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteProject() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Project'),
        content: const Text(
            'Are you sure you want to delete this project? All tasks and audit history for this project will be deleted. This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final success = await Provider.of<ProjectProvider>(context, listen: false)
        .deleteProject(widget.projectId);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Project deleted')),
      );
      Navigator.of(context).pop();
    }
  }

  Future<void> _onStatusChanged(String taskId, String newStatus) async {
    await Provider.of<TaskProvider>(context, listen: false)
        .updateTask(taskId, {'status': newStatus});
    // Refresh project stats in list
    if (mounted) {
      Provider.of<ProjectProvider>(context, listen: false).fetchProjects();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_project?.name ?? 'Project Detail'),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download_outlined),
            tooltip: 'Export Deliverables',
            onPressed: _exportProjectDeliverables,
          ),
          if (_project != null)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Edit Project',
              onPressed: () async {
                final result = await Navigator.of(context).pushNamed(
                  '/edit-project',
                  arguments: _project,
                );
                if (result == true) {
                  _loadData();
                }
              },
            ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            tooltip: 'Delete Project',
            onPressed: _deleteProject,
          ),
        ],
      ),
      body: _isLoadingProject
          ? const LoadingIndicator()
          : _project == null
              ? const ErrorDisplay(message: 'Project not found')
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Project header card
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryColor
                                            .withValues(alpha: 0.1),
                                        borderRadius:
                                            BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        _project!.category,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.primaryColor,
                                        ),
                                      ),
                                    ),
                                    const Spacer(),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppTheme.getStatusColor(
                                                _project!.status)
                                            .withValues(alpha: 0.12),
                                        borderRadius:
                                            BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        _project!.status,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.getStatusColor(
                                              _project!.status),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  _project!.name,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                if (_project!.description.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    _project!.description,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[700],
                                      height: 1.3,
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 16),

                                // Progress bar
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Overall Progress',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    Text(
                                      '${_project!.progressPercentage}%',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.primaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: (_project!.progressPercentage
                                            .clamp(0, 100)) /
                                        100.0,
                                    minHeight: 8,
                                    backgroundColor:
                                        Colors.grey.withValues(alpha: 0.15),
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
                                            AppTheme.primaryColor),
                                  ),
                                ),
                                const SizedBox(height: 12),

                                // Tags and created date
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    if (_project!.tags.isNotEmpty)
                                      Wrap(
                                        spacing: 4,
                                        children: _project!.tags.map((t) {
                                          return Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: Colors.grey
                                                  .withValues(alpha: 0.1),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              '#$t',
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: Colors.grey[700],
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      )
                                    else
                                      const SizedBox(),
                                    Text(
                                      'Created ${DateFormat('MMM dd, yyyy').format(_project!.createdAt)}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[400],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Tasks Section Header & Search
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Task Pipeline',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: () async {
                                await Navigator.of(context).pushNamed(
                                  '/create-task',
                                  arguments: widget.projectId,
                                );
                                _loadData();
                              },
                              icon: const Icon(Icons.add, size: 16),
                              label: const Text('Add Task'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 8),
                                textStyle: const TextStyle(fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Search box for tasks
                        TextField(
                          onChanged: (val) {
                            setState(() => _taskSearch = val);
                            Provider.of<TaskProvider>(context, listen: false)
                                .fetchTasks(widget.projectId, search: val);
                          },
                          decoration: InputDecoration(
                            hintText: 'Search tasks by title...',
                            prefixIcon: const Icon(Icons.search, size: 18),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Kanban columns
                        Consumer<TaskProvider>(
                          builder: (context, taskProvider, _) {
                            if (taskProvider.isLoading) {
                              return const Padding(
                                padding: EdgeInsets.all(32),
                                child: LoadingIndicator(),
                              );
                            }

                            if (taskProvider.tasks.isEmpty) {
                              return EmptyState(
                                icon: Icons.task_alt,
                                title: _taskSearch.isNotEmpty
                                    ? 'No matching tasks'
                                    : 'No tasks yet',
                                subtitle: _taskSearch.isNotEmpty
                                    ? 'Clear search to view all tasks'
                                    : 'Add deliverables and checklist items to this project',
                              );
                            }

                            return Column(
                              children: Task.statuses.map((status) {
                                final tasks =
                                    taskProvider.getTasksByStatus(status);
                                if (tasks.isEmpty) return const SizedBox();

                                return Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 10,
                                            height: 10,
                                            decoration: BoxDecoration(
                                              color: AppTheme.getStatusColor(
                                                  status),
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            '$status (${tasks.length})',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.grey[800],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    ...tasks.map((task) => Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 8),
                                          child: TaskCard(
                                            task: task,
                                            onTap: () async {
                                              await Navigator.of(context)
                                                  .pushNamed(
                                                '/edit-task',
                                                arguments: task,
                                              );
                                              _loadData();
                                            },
                                            onStatusChanged: (newStatus) {
                                              _onStatusChanged(
                                                  task.id, newStatus);
                                            },
                                          ),
                                        )),
                                    const SizedBox(height: 8),
                                  ],
                                );
                              }).toList(),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(context).pushNamed(
            '/create-task',
            arguments: widget.projectId,
          );
          _loadData();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
