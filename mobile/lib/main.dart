import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'config/theme.dart';
import 'models/project.dart';
import 'models/task.dart';
import 'services/api_service.dart';
import 'services/auth_service.dart';
import 'services/project_service.dart';
import 'services/task_service.dart';
import 'services/dashboard_service.dart';
import 'providers/auth_provider.dart';
import 'providers/project_provider.dart';
import 'providers/task_provider.dart';
import 'providers/dashboard_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/create_project_screen.dart';
import 'screens/edit_project_screen.dart';
import 'screens/project_detail_screen.dart';
import 'screens/create_task_screen.dart';
import 'screens/edit_task_screen.dart';

void main() {
  runApp(const DevTrackApp());
}

class DevTrackApp extends StatelessWidget {
  const DevTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Create a single shared ApiService instance
    final apiService = ApiService();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(AuthService(apiService)),
        ),
        ChangeNotifierProvider(
          create: (_) => ProjectProvider(ProjectService(apiService)),
        ),
        ChangeNotifierProvider(
          create: (_) => TaskProvider(TaskService(apiService)),
        ),
        ChangeNotifierProvider(
          create: (_) => DashboardProvider(DashboardService(apiService)),
        ),
      ],
      child: MaterialApp(
        title: 'DevTrack',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: '/',
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/':
              return MaterialPageRoute(
                builder: (_) => const SplashScreen(),
              );
            case '/login':
              return MaterialPageRoute(
                builder: (_) => const LoginScreen(),
              );
            case '/register':
              return MaterialPageRoute(
                builder: (_) => const RegisterScreen(),
              );
            case '/home':
              return MaterialPageRoute(
                builder: (_) => const HomeScreen(),
              );
            case '/create-project':
              return MaterialPageRoute(
                builder: (_) => const CreateProjectScreen(),
              );
            case '/edit-project':
              final project = settings.arguments as Project;
              return MaterialPageRoute(
                builder: (_) => EditProjectScreen(project: project),
              );
            case '/project-detail':
              final projectId = settings.arguments as String;
              return MaterialPageRoute(
                builder: (_) => ProjectDetailScreen(projectId: projectId),
              );
            case '/create-task':
              final projectId = settings.arguments as String;
              return MaterialPageRoute(
                builder: (_) => CreateTaskScreen(projectId: projectId),
              );
            case '/edit-task':
              final task = settings.arguments as Task;
              return MaterialPageRoute(
                builder: (_) => EditTaskScreen(task: task),
              );
            default:
              return MaterialPageRoute(
                builder: (_) => const SplashScreen(),
              );
          }
        },
      ),
    );
  }
}
