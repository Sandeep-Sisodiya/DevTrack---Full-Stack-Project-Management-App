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

/// Project detail screen showing project info and Kanban-style task columns.
class ProjectDetailScreen extends StatefulWidget {
  final String projectId;

  const ProjectDetailScreen({super.key, required this.projectId});

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  Project? _project;
  bool _isLoadingProject = true;

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
      // Find project from cached list or we could fetch it
      final projects = projectProvider.projects;
      final found = projects.where((p) => p.id == widget.projectId);
      if (found.isNotEmpty) {
        _project = found.first;
      }
    } catch (_) {}

    setState(() => _isLoadingProject = false);

    // Load tasks for this project
    if (mounted) {
      await Provider.of<TaskProvider>(context, listen: false)
          .fetchTasks(widget.projectId);
    }
  }

  Future<void> _deleteProject() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Project'),
        content: const Text(
            'Are you sure you want to delete this project? All tasks will also be deleted. This action cannot be undone.'),
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_project?.name ?? 'Project'),
        actions: [
          if (_project != null)
            IconButton(
              icon: const Icon(Icons.edit),
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
                        // Project info card
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        _project!.name,
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: AppTheme.getStatusColor(
                                                _project!.status)
                                            .withValues(alpha: 0.1),
                                        borderRadius:
                                            BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        _project!.status,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.getStatusColor(
                                              _project!.status),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                if (_project!.description.isNotEmpty) ...[
                                  const SizedBox(height: 12),
                                  Text(
                                    _project!.description,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 12),
                                Text(
                                  'Created ${DateFormat('MMMM dd, yyyy').format(_project!.createdAt)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[400],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Tasks section header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Tasks',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () async {
                                await Navigator.of(context).pushNamed(
                                  '/create-task',
                                  arguments: widget.projectId,
                                );
                              },
                              icon: const Icon(Icons.add, size: 18),
                              label: const Text('Add Task'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Kanban-style columns
                        Consumer<TaskProvider>(
                          builder: (context, taskProvider, _) {
                            if (taskProvider.isLoading) {
                              return const Padding(
                                padding: EdgeInsets.all(32),
                                child: LoadingIndicator(),
                              );
                            }

                            if (taskProvider.tasks.isEmpty) {
                              return const EmptyState(
                                icon: Icons.task_alt,
                                title: 'No tasks yet',
                                subtitle: 'Add tasks to this project',
                              );
                            }

                            return Column(
                              children: Task.statuses.map((status) {
                                final tasks =
                                    taskProvider.getTasksByStatus(status);
                                if (tasks.isEmpty) return const SizedBox();

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 12,
                                            height: 12,
                                            decoration: BoxDecoration(
                                              color: AppTheme.getStatusColor(
                                                  status),
                                              borderRadius:
                                                  BorderRadius.circular(3),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            '$status (${tasks.length})',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    ...tasks.map((task) => Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 6),
                                          child: TaskCard(
                                            task: task,
                                            onTap: () async {
                                              await Navigator.of(context)
                                                  .pushNamed(
                                                '/edit-task',
                                                arguments: task,
                                              );
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
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
