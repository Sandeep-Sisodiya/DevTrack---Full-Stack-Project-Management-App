import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/dashboard_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/stat_card.dart';
import '../widgets/project_card.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/error_display.dart';
import '../widgets/empty_state.dart';

/// Main dashboard screen showing project/task stats and recent items.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    await Provider.of<DashboardProvider>(context, listen: false)
        .fetchDashboard();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        automaticallyImplyLeading: false,
      ),
      body: Consumer<DashboardProvider>(
        builder: (context, dashboard, _) {
          if (dashboard.isLoading) {
            return const LoadingIndicator();
          }

          if (dashboard.error != null) {
            return ErrorDisplay(
              message: dashboard.error!,
              onRetry: _loadDashboard,
            );
          }

          final data = dashboard.data;
          if (data == null) {
            return const EmptyState(
              icon: Icons.dashboard,
              title: 'No data yet',
              subtitle: 'Start by creating a project',
            );
          }

          return RefreshIndicator(
            onRefresh: _loadDashboard,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Greeting
                  Consumer<AuthProvider>(
                    builder: (context, auth, _) {
                      return Text(
                        'Hello, ${auth.user?.name ?? 'Developer'} 👋',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Here\'s your project overview',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 20),

                  // Stats grid
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.4,
                    children: [
                      StatCard(
                        title: 'Total Projects',
                        value: '${data.totalProjects}',
                        icon: Icons.folder_outlined,
                        color: AppTheme.primaryColor,
                      ),
                      StatCard(
                        title: 'Total Tasks',
                        value: '${data.totalTasks}',
                        icon: Icons.task_outlined,
                        color: AppTheme.accentColor,
                      ),
                      StatCard(
                        title: 'Pending',
                        value: '${data.pendingTasks}',
                        icon: Icons.pending_outlined,
                        color: AppTheme.warningColor,
                      ),
                      StatCard(
                        title: 'Completed',
                        value: '${data.completedTasks}',
                        icon: Icons.check_circle_outline,
                        color: AppTheme.statusCompleted,
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Recent projects
                  const Text(
                    'Recent Projects',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (data.recentProjects.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        'No projects yet. Tap + to create one.',
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                    )
                  else
                    ...data.recentProjects.map((project) => Padding(
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
                        )),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
