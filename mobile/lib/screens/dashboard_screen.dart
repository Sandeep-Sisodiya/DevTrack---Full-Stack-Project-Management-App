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

/// Main dashboard screen showing project/task stats, productivity score,
/// recent audit activity, and recent projects.
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
        title: const Text('DevTrack Executive Dashboard'),
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
              subtitle: 'Start by creating your first project',
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
                  // Greeting & Productivity Health Card
                  Consumer<AuthProvider>(
                    builder: (context, auth, _) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome, ${auth.user?.name ?? 'Developer'} 👋',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Engineering velocity and project health overview',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // Productivity Completion Banner
                  Card(
                    color: AppTheme.primaryColor,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Sprint Completion Rate',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white70,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${data.completionRate}% Done',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: (data.completionRate.clamp(0, 100)) /
                                        100.0,
                                    minHeight: 6,
                                    backgroundColor: Colors.white24,
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
                                            AppTheme.accentColor),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.speed_outlined,
                              size: 32,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

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
                        title: 'Active Deliverables',
                        value: '${data.totalTasks}',
                        icon: Icons.task_outlined,
                        color: AppTheme.accentColor,
                      ),
                      StatCard(
                        title: 'In Progress',
                        value: '${data.pendingTasks}',
                        icon: Icons.pending_outlined,
                        color: AppTheme.warningColor,
                      ),
                      StatCard(
                        title: data.overdueTasks > 0
                            ? 'Overdue Tasks'
                            : 'Completed',
                        value: data.overdueTasks > 0
                            ? '${data.overdueTasks}'
                            : '${data.completedTasks}',
                        icon: data.overdueTasks > 0
                            ? Icons.warning_amber_rounded
                            : Icons.check_circle_outline,
                        color: data.overdueTasks > 0
                            ? AppTheme.errorColor
                            : AppTheme.statusCompleted,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Recent Activity Feed Teaser
                  if (data.recentActivities.isNotEmpty) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Recent Audit Activity',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pushNamed('/activity');
                          },
                          child: const Text('View All'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...data.recentActivities.take(3).map((act) => Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            dense: true,
                            leading: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor
                                    .withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.history,
                                size: 16,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                            title: Text(
                              act.details,
                              style: const TextStyle(fontSize: 13),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )),
                    const SizedBox(height: 20),
                  ],

                  // Recent Projects
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Recent Projects',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          Navigator.of(context).pushNamed('/create-project');
                        },
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('New'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
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
