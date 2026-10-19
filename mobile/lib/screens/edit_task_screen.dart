import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../models/task.dart' as task_model;
import '../providers/task_provider.dart';

/// Screen for editing an existing task, managing checklist subtasks, and adjusting estimates.
class EditTaskScreen extends StatefulWidget {
  final task_model.Task task;

  const EditTaskScreen({super.key, required this.task});

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _hoursController;
  late final TextEditingController _tagsController;
  final TextEditingController _subtaskController = TextEditingController();

  late String _priority;
  late String _status;
  late DateTime? _dueDate;
  late List<task_model.Subtask> _subtasks;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _descriptionController =
        TextEditingController(text: widget.task.description);
    _hoursController = TextEditingController(
      text: widget.task.estimatedHours > 0
          ? widget.task.estimatedHours.toString()
          : '',
    );
    _tagsController = TextEditingController(text: widget.task.tags.join(', '));
    _priority = widget.task.priority;
    _status = widget.task.status;
    _dueDate = widget.task.dueDate;
    _subtasks = List.from(widget.task.subtasks);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _hoursController.dispose();
    _tagsController.dispose();
    _subtaskController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _dueDate = picked);
    }
  }

  void _addSubtask() {
    final text = _subtaskController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _subtasks.add(task_model.Subtask(
          id: '',
          title: text,
          isCompleted: false,
        ));
        _subtaskController.clear();
      });
    }
  }

  void _removeSubtask(int index) {
    setState(() {
      _subtasks.removeAt(index);
    });
  }

  Future<void> _toggleSubtaskItem(int index) async {
    final item = _subtasks[index];
    if (item.id.isNotEmpty) {
      // Toggle on server immediately
      await Provider.of<TaskProvider>(context, listen: false)
          .toggleSubtask(widget.task.id, item.id);
    }
    setState(() {
      _subtasks[index] = item.copyWith(isCompleted: !item.isCompleted);
    });
  }

  Future<void> _deleteTask() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: const Text(
            'Are you sure you want to delete this task? This action cannot be undone.'),
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

    final success = await Provider.of<TaskProvider>(context, listen: false)
        .deleteTask(widget.task.id);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task deleted')),
      );
      Navigator.of(context).pop();
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final tags = _tagsController.text
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    final data = <String, dynamic>{
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim(),
      'priority': _priority,
      'status': _status,
      'estimatedHours': double.tryParse(_hoursController.text.trim()) ?? 0.0,
      'tags': tags,
      'subtasks': _subtasks.map((s) => s.toJson()).toList(),
    };
    if (_dueDate != null) {
      data['dueDate'] = _dueDate!.toIso8601String();
    }

    final success = await Provider.of<TaskProvider>(context, listen: false)
        .updateTask(widget.task.id, data);

    if (!mounted) return;

    setState(() => _isSubmitting = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task updated successfully')),
      );
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update task'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final subtasksDone = _subtasks.where((s) => s.isCompleted).length;
    final progress = _subtasks.isNotEmpty
        ? (subtasksDone / _subtasks.length)
        : (_status == 'Completed' ? 1.0 : (_status == 'In Progress' ? 0.5 : 0.0));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Task'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: _deleteTask,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Progress meter
              Card(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Task Completion',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            '${(progress * 100).round()}%',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 6,
                          backgroundColor: Colors.grey.withValues(alpha: 0.15),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              AppTheme.primaryColor),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Task Title',
                  prefixIcon: Icon(Icons.task_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Task title is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  prefixIcon: Icon(Icons.description_outlined),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _priority,
                      decoration: const InputDecoration(
                        labelText: 'Priority',
                        prefixIcon: Icon(Icons.priority_high),
                      ),
                      items: task_model.Task.priorities
                          .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) setState(() => _priority = value);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _status,
                      decoration: const InputDecoration(
                        labelText: 'Status',
                        prefixIcon: Icon(Icons.flag_outlined),
                      ),
                      items: task_model.Task.statuses
                          .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) setState(() => _status = value);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _hoursController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Estimated Hours',
                        prefixIcon: Icon(Icons.timer_outlined),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: _selectDate,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Due Date',
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(
                          _dueDate != null
                              ? '${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}'
                              : 'Select date',
                          style: TextStyle(
                            color: _dueDate != null ? null : Colors.grey[500],
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _tagsController,
                decoration: const InputDecoration(
                  labelText: 'Tags (comma separated)',
                  prefixIcon: Icon(Icons.tag),
                ),
              ),
              const SizedBox(height: 24),

              // Checklist Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Checklist / Subtasks',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${_subtasks.where((s) => s.isCompleted).length}/${_subtasks.length} done',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _subtaskController,
                      decoration: const InputDecoration(
                        hintText: 'Add a subtask step...',
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      ),
                      onSubmitted: (_) => _addSubtask(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _addSubtask,
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
              if (_subtasks.isNotEmpty) ...[
                const SizedBox(height: 8),
                ...List.generate(_subtasks.length, (index) {
                  final s = _subtasks[index];
                  return CheckboxListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    value: s.isCompleted,
                    onChanged: (_) => _toggleSubtaskItem(index),
                    title: Text(
                      s.title,
                      style: TextStyle(
                        decoration:
                            s.isCompleted ? TextDecoration.lineThrough : null,
                        color: s.isCompleted ? Colors.grey[500] : Colors.black87,
                      ),
                    ),
                    secondary: IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () => _removeSubtask(index),
                    ),
                  );
                }),
              ],

              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Update Task'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
