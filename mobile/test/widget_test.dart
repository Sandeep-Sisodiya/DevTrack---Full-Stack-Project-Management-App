import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:devtrack/config/theme.dart';
import 'package:devtrack/models/user.dart';
import 'package:devtrack/models/project.dart';
import 'package:devtrack/models/task.dart';
import 'package:devtrack/widgets/empty_state.dart';
import 'package:devtrack/widgets/loading_indicator.dart';
import 'package:devtrack/widgets/error_display.dart';
import 'package:devtrack/widgets/stat_card.dart';

void main() {
  group('Model Tests', () {
    test('User.fromJson creates a valid User', () {
      final json = {
        '_id': '123',
        'name': 'Test User',
        'email': 'test@example.com',
        'createdAt': '2024-01-01T00:00:00.000Z',
      };

      final user = User.fromJson(json);

      expect(user.id, '123');
      expect(user.name, 'Test User');
      expect(user.email, 'test@example.com');
    });

    test('Project.fromJson creates a valid Project', () {
      final json = {
        '_id': '456',
        'name': 'Test Project',
        'description': 'A test project',
        'status': 'Planning',
        'user': 'user123',
        'createdAt': '2024-01-01T00:00:00.000Z',
        'updatedAt': '2024-01-01T00:00:00.000Z',
      };

      final project = Project.fromJson(json);

      expect(project.id, '456');
      expect(project.name, 'Test Project');
      expect(project.status, 'Planning');
    });

    test('Task.fromJson creates a valid Task', () {
      final json = {
        '_id': '789',
        'title': 'Test Task',
        'description': 'A test task',
        'priority': 'High',
        'status': 'Todo',
        'project': 'proj123',
        'user': 'user123',
        'createdAt': '2024-01-01T00:00:00.000Z',
        'updatedAt': '2024-01-01T00:00:00.000Z',
      };

      final task = Task.fromJson(json);

      expect(task.id, '789');
      expect(task.title, 'Test Task');
      expect(task.priority, 'High');
      expect(task.status, 'Todo');
    });

    test('Task.fromJson handles populated project reference', () {
      final json = {
        '_id': '789',
        'title': 'Test Task',
        'description': '',
        'priority': 'Medium',
        'status': 'In Progress',
        'project': {'_id': 'proj123', 'name': 'My Project'},
        'user': 'user123',
        'createdAt': '2024-01-01T00:00:00.000Z',
        'updatedAt': '2024-01-01T00:00:00.000Z',
      };

      final task = Task.fromJson(json);

      expect(task.project, 'proj123');
    });

    test('Project.statuses contains all valid statuses', () {
      expect(Project.statuses, ['Planning', 'In Progress', 'Completed']);
    });

    test('Task.priorities contains all valid priorities', () {
      expect(Task.priorities, ['Low', 'Medium', 'High']);
    });
  });

  group('Theme Tests', () {
    test('getStatusColor returns correct colors', () {
      expect(AppTheme.getStatusColor('Planning'), AppTheme.statusPlanning);
      expect(
          AppTheme.getStatusColor('In Progress'), AppTheme.statusInProgress);
      expect(AppTheme.getStatusColor('Completed'), AppTheme.statusCompleted);
    });

    test('getPriorityColor returns correct colors', () {
      expect(AppTheme.getPriorityColor('Low'), AppTheme.priorityLow);
      expect(AppTheme.getPriorityColor('Medium'), AppTheme.priorityMedium);
      expect(AppTheme.getPriorityColor('High'), AppTheme.priorityHigh);
    });
  });

  group('Widget Tests', () {
    testWidgets('EmptyState displays correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.folder_open,
              title: 'No projects',
              subtitle: 'Create your first project',
            ),
          ),
        ),
      );

      expect(find.text('No projects'), findsOneWidget);
      expect(find.text('Create your first project'), findsOneWidget);
      expect(find.byIcon(Icons.folder_open), findsOneWidget);
    });

    testWidgets('LoadingIndicator shows a progress indicator', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingIndicator(),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('ErrorDisplay shows error message and retry button',
        (tester) async {
      bool retried = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorDisplay(
              message: 'Something went wrong',
              onRetry: () => retried = true,
            ),
          ),
        ),
      );

      expect(find.text('Something went wrong'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);

      await tester.tap(find.text('Retry'));
      expect(retried, isTrue);
    });

    testWidgets('StatCard displays title and value', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatCard(
              title: 'Total Projects',
              value: '5',
              icon: Icons.folder,
              color: Colors.blue,
            ),
          ),
        ),
      );

      expect(find.text('Total Projects'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
    });
  });
}
