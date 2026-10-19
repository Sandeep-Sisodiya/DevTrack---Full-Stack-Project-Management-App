const express = require('express');
const { body } = require('express-validator');
const Task = require('../models/Task');
const Project = require('../models/Project');
const auth = require('../middleware/auth');
const validate = require('../middleware/validate');
const { logActivity } = require('../services/activityLogger');

const router = express.Router();

// All task routes require authentication
router.use(auth);

// GET /api/tasks/:id — Get single task details
router.get('/:id', async (req, res, next) => {
  try {
    const task = await Task.findOne({ _id: req.params.id, user: req.userId }).populate('project', 'name');
    if (!task) {
      return res.status(404).json({ message: 'Task not found' });
    }
    res.json(task);
  } catch (error) {
    next(error);
  }
});

// PUT /api/tasks/:id — Update a task
router.put(
  '/:id',
  [
    body('title').optional().trim().notEmpty().withMessage('Title cannot be empty'),
    body('description').optional().trim(),
    body('priority')
      .optional()
      .isIn(['Low', 'Medium', 'High'])
      .withMessage('Priority must be Low, Medium, or High'),
    body('status')
      .optional()
      .isIn(['Todo', 'In Progress', 'Completed'])
      .withMessage('Status must be Todo, In Progress, or Completed'),
    body('dueDate').optional({ values: 'null' }).isISO8601().withMessage('Due date must be a valid date'),
    body('estimatedHours').optional().isNumeric().withMessage('Estimated hours must be a number'),
    body('tags').optional().isArray(),
    body('subtasks').optional().isArray(),
  ],
  validate,
  async (req, res, next) => {
    try {
      const task = await Task.findOne({ _id: req.params.id, user: req.userId });
      if (!task) {
        return res.status(404).json({ message: 'Task not found' });
      }

      const previousStatus = task.status;
      const { title, description, priority, status, dueDate, estimatedHours, tags, subtasks } = req.body;

      if (title !== undefined) task.title = title;
      if (description !== undefined) task.description = description;
      if (priority !== undefined) task.priority = priority;
      if (status !== undefined) task.status = status;
      if (dueDate !== undefined) task.dueDate = dueDate;
      if (estimatedHours !== undefined) task.estimatedHours = estimatedHours;
      if (tags !== undefined) task.tags = tags;
      if (subtasks !== undefined) task.subtasks = subtasks;

      task.calculateProgress();
      await task.save();

      // Check if project exists to get name for activity log
      const project = await Project.findById(task.project);
      const projectName = project ? project.name : 'Unknown';

      if (status !== undefined && status !== previousStatus) {
        await logActivity({
          userId: req.userId,
          action: 'TASK_STATUS_CHANGED',
          projectId: task.project,
          projectName,
          taskId: task._id,
          taskTitle: task.title,
          details: `Moved "${task.title}" from "${previousStatus}" to "${task.status}"`,
          metadata: { previousStatus, newStatus: task.status },
        });
      } else {
        await logActivity({
          userId: req.userId,
          action: 'TASK_UPDATED',
          projectId: task.project,
          projectName,
          taskId: task._id,
          taskTitle: task.title,
          details: `Updated details for task "${task.title}"`,
        });
      }

      res.json(task);
    } catch (error) {
      next(error);
    }
  }
);

// PATCH /api/tasks/:id/subtasks/:subtaskId/toggle — Toggle a subtask completion status
router.patch('/:id/subtasks/:subtaskId/toggle', async (req, res, next) => {
  try {
    const task = await Task.findOne({ _id: req.params.id, user: req.userId });
    if (!task) {
      return res.status(404).json({ message: 'Task not found' });
    }

    const subtask = task.subtasks.id(req.params.subtaskId);
    if (!subtask) {
      return res.status(404).json({ message: 'Subtask not found' });
    }

    subtask.isCompleted = !subtask.isCompleted;
    task.calculateProgress();
    await task.save();

    await logActivity({
      userId: req.userId,
      action: 'SUBTASK_TOGGLED',
      projectId: task.project,
      taskId: task._id,
      taskTitle: task.title,
      details: `${subtask.isCompleted ? 'Completed' : 'Reopened'} checklist item "${subtask.title}" on task "${task.title}"`,
    });

    res.json(task);
  } catch (error) {
    next(error);
  }
});

// DELETE /api/tasks/:id — Delete a task
router.delete('/:id', async (req, res, next) => {
  try {
    const task = await Task.findOneAndDelete({
      _id: req.params.id,
      user: req.userId,
    });
    if (!task) {
      return res.status(404).json({ message: 'Task not found' });
    }

    await logActivity({
      userId: req.userId,
      action: 'TASK_DELETED',
      projectId: task.project,
      taskId: task._id,
      taskTitle: task.title,
      details: `Deleted task "${task.title}"`,
    });

    res.json({ message: 'Task deleted successfully' });
  } catch (error) {
    next(error);
  }
});

module.exports = router;
