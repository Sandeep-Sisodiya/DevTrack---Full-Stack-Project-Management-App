import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/project_provider.dart';
import '../widgets/project_card.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/error_display.dart';
import '../widgets/empty_state.dart';

/// Screen displaying all projects with pull-to-refresh and FAB for creation.
class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    await Provider.of<ProjectProvider>(context, listen: false).fetchProjects();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Projects'),
        automaticallyImplyLeading: false,
      ),
      body: Consumer<ProjectProvider>(
        builder: (context, projectProvider, _) {
          if (projectProvider.isLoading) {
            return const LoadingIndicator();
          }

          if (projectProvider.error != null) {
            return ErrorDisplay(
              message: projectProvider.error!,
              onRetry: _loadProjects,
            );
          }

          if (projectProvider.projects.isEmpty) {
            return EmptyState(
              icon: Icons.folder_open,
              title: 'No projects yet',
              subtitle: 'Create your first project to get started',
              action: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pushNamed('/create-project');
                },
                icon: const Icon(Icons.add),
                label: const Text('New Project'),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadProjects,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: projectProvider.projects.length,
              itemBuilder: (context, index) {
                final project = projectProvider.projects[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: ProjectCard(
                    project: project,
                    onTap: () {
                      Navigator.of(context).pushNamed(
                        '/project-detail',
                        arguments: project.id,
                      );
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed('/create-project');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
