import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/project.dart';
import '../providers/project_provider.dart';
import '../widgets/project_card.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/error_display.dart';
import '../widgets/empty_state.dart';

/// Screen displaying all projects with instant search, filter chips, and pull-to-refresh.
class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProjects() async {
    await Provider.of<ProjectProvider>(context, listen: false).fetchProjects();
  }

  void _onSearchChanged(String query) {
    Provider.of<ProjectProvider>(context, listen: false)
        .fetchProjects(search: query);
  }

  void _onStatusFilterSelected(String status) {
    Provider.of<ProjectProvider>(context, listen: false)
        .fetchProjects(status: status);
  }

  @override
  Widget build(BuildContext context) {
    final projectProvider = Provider.of<ProjectProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Projects'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // Search & Filter Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search projects by name or description...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),

          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: ['All', ...Project.statuses].map((status) {
                final isSelected = projectProvider.statusFilter == status;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: FilterChip(
                    label: Text(status),
                    selected: isSelected,
                    onSelected: (_) => _onStatusFilterSelected(status),
                    showCheckmark: false,
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                    backgroundColor: Colors.grey.withValues(alpha: 0.1),
                    selectedColor: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected
                            ? Theme.of(context).primaryColor
                            : Colors.grey.withValues(alpha: 0.2),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Project List
          Expanded(
            child: Consumer<ProjectProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading && provider.projects.isEmpty) {
                  return const LoadingIndicator();
                }

                if (provider.error != null) {
                  return ErrorDisplay(
                    message: provider.error!,
                    onRetry: _loadProjects,
                  );
                }

                if (provider.projects.isEmpty) {
                  return EmptyState(
                    icon: Icons.folder_open,
                    title: provider.searchQuery.isNotEmpty
                        ? 'No matching projects'
                        : 'No projects yet',
                    subtitle: provider.searchQuery.isNotEmpty
                        ? 'Try modifying your search or filters'
                        : 'Create your first project to get started',
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    itemCount: provider.projects.length,
                    itemBuilder: (context, index) {
                      final project = provider.projects[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
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
          ),
        ],
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
