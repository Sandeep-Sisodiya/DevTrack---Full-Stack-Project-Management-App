const express = require('express');
const { body, query } = require('express-validator');
const Project = require('../models/Project');
const Task = require('../models/Task');
const auth = require('../middleware/auth');
const validate = require('../middleware/validate');
const { logActivity } = require('../services/activityLogger');

const router = express.Router();

// All project routes require authentication
router.use(auth);

/**
 * Helper to compute task statistics for a list of projects
 */
async function attachProjectStats(projects, userId) {
  const projectIds = projects.map((p) => p._id);
  const tasks = await Task.find({ project: { $in: projectIds }, user: userId }).select(
    'project status progressPercentage'
  );

  const statsMap = {};
  for (const id of projectIds) {
    statsMap[id.toString()] = { totalTasks: 0, completedTasks: 0, progressPercentage: 0 };
  }

  for (const task of tasks) {
    const pId = task.project.toString();
    if (statsMap[pId]) {
      statsMap[pId].totalTasks += 1;
      if (task.status === 'Completed') {
        statsMap[pId].completedTasks += 1;
      }
    }
  }

  for (const pId of Object.keys(statsMap)) {
    const s = statsMap[pId];
    s.progressPercentage = s.totalTasks > 0 ? Math.round((s.completedTasks / s.totalTasks) * 100) : 0;
  }

  return projects.map((p) => {
    const obj = p.toObject();
    const stats = statsMap[p._id.toString()] || { totalTasks: 0, completedTasks: 0, progressPercentage: 0 };
    return {
      ...obj,
      totalTasks: stats.totalTasks,
      completedTasks: stats.completedTasks,
      progressPercentage: stats.progressPercentage,
    };
  });
}

// GET /api/projects — Get all projects with search, filter, and progress stats
router.get('/', async (req, res, next) => {
  try {
    const { search, status, category, sortBy = 'createdAt', order = 'desc' } = req.query;

    const query = { user: req.userId };

    if (search && search.trim() !== '') {
      query.$or = [
        { name: { $regex: search.trim(), $options: 'i' } },
        { description: { $regex: search.trim(), $options: 'i' } },
      ];
    }

    if (status && status !== 'All') {
      query.status = status;
    }

    if (category && category !== 'All') {
      query.category = category;
    }

    const sortOrder = order === 'asc' ? 1 : -1;
    const sortField = ['name', 'status', 'createdAt', 'updatedAt'].includes(sortBy)
      ? sortBy
      : 'createdAt';

    const projects = await Project.find(query).sort({ [sortField]: sortOrder });
    const enrichedProjects = await attachProjectStats(projects, req.userId);

    res.json(enrichedProjects);
  } catch (error) {
    next(error);
  }
});

// POST /api/projects — Create a new project
router.post(
  '/',
  [
    body('name').trim().notEmpty().withMessage('Project name is required'),
    body('description').optional().trim(),
    body('status')
      .optional()
      .isIn(['Planning', 'In Progress', 'Completed'])
      .withMessage('Status must be Planning, In Progress, or Completed'),
    body('category').optional().trim(),
    body('color').optional().trim(),
    body('tags').optional().isArray(),
  ],
  validate,
  async (req, res, next) => {
    try {
      const { name, description, status, category, color, tags } = req.body;
      const project = await Project.create({
        name,
        description,
        status: status || 'Planning',
        category: category || 'General',
        color: color || '#6C63FF',
        tags: Array.isArray(tags) ? tags : [],
        user: req.userId,
      });

      // Record audit activity
      await logActivity({
        userId: req.userId,
        action: 'PROJECT_CREATED',
        projectId: project._id,
        projectName: project.name,
        details: `Created project "${project.name}" with status "${project.status}"`,
      });

      const responseObj = {
        ...project.toObject(),
        totalTasks: 0,
        completedTasks: 0,
        progressPercentage: 0,
      };

      res.status(201).json(responseObj);
    } catch (error) {
      next(error);
    }
  }
);

// GET /api/projects/:id — Get a single project by ID with stats
router.get('/:id', async (req, res, next) => {
  try {
    const project = await Project.findOne({ _id: req.params.id, user: req.userId });
    if (!project) {
      return res.status(404).json({ message: 'Project not found' });
    }

    const [enriched] = await attachProjectStats([project], req.userId);
    res.json(enriched);
  } catch (error) {
    next(error);
  }
});

// PUT /api/projects/:id — Update a project
router.put(
  '/:id',
  [
    body('name').optional().trim().notEmpty().withMessage('Project name cannot be empty'),
    body('description').optional().trim(),
    body('status')
      .optional()
      .isIn(['Planning', 'In Progress', 'Completed'])
      .withMessage('Status must be Planning, In Progress, or Completed'),
    body('category').optional().trim(),
    body('color').optional().trim(),
    body('tags').optional().isArray(),
  ],
  validate,
  async (req, res, next) => {
    try {
      const { name, description, status, category, color, tags } = req.body;
      const updateData = {};
      if (name !== undefined) updateData.name = name;
      if (description !== undefined) updateData.description = description;
      if (status !== undefined) updateData.status = status;
      if (category !== undefined) updateData.category = category;
      if (color !== undefined) updateData.color = color;
      if (tags !== undefined) updateData.tags = tags;

      const project = await Project.findOneAndUpdate(
        { _id: req.params.id, user: req.userId },
        updateData,
        { new: true, runValidators: true }
      );

      if (!project) {
        return res.status(404).json({ message: 'Project not found' });
      }

      await logActivity({
        userId: req.userId,
        action: 'PROJECT_UPDATED',
        projectId: project._id,
        projectName: project.name,
        details: `Updated project "${project.name}" (Status: ${project.status})`,
      });

      const [enriched] = await attachProjectStats([project], req.userId);
      res.json(enriched);
    } catch (error) {
      next(error);
    }
  }
);

// DELETE /api/projects/:id — Delete a project, its tasks, and log activity
router.delete('/:id', async (req, res, next) => {
  try {
    const project = await Project.findOneAndDelete({
      _id: req.params.id,
      user: req.userId,
    });
    if (!project) {
      return res.status(404).json({ message: 'Project not found' });
    }

    // Cascade delete tasks
    const deleteResult = await Task.deleteMany({ project: req.params.id });

    await logActivity({
      userId: req.userId,
      action: 'PROJECT_DELETED',
      projectName: project.name,
      details: `Deleted project "${project.name}" and removed ${deleteResult.deletedCount} associated task(s)`,
    });

    res.json({ message: 'Project and all associated tasks deleted successfully' });
  } catch (error) {
    next(error);
  }
});

// GET /api/projects/:id/export — Export project deliverables as JSON or CSV
router.get('/:id/export', async (req, res, next) => {
  try {
    const project = await Project.findOne({ _id: req.params.id, user: req.userId });
    if (!project) {
      return res.status(404).json({ message: 'Project not found' });
    }

    const tasks = await Task.find({ project: req.params.id, user: req.userId }).sort({ createdAt: 1 });
    const format = (req.query.format || 'json').toLowerCase();

    if (format === 'csv') {
      let csv = 'Task Title,Status,Priority,Due Date,Estimated Hours,Progress %,Tags,Subtasks Completed,Total Subtasks\n';
      for (const t of tasks) {
        const dueDate = t.dueDate ? t.dueDate.toISOString().split('T')[0] : 'None';
        const tags = (t.tags || []).join(';');
        const subtasksDone = (t.subtasks || []).filter((s) => s.isCompleted).length;
        const subtasksTotal = (t.subtasks || []).length;
        const sanitizedTitle = `"${(t.title || '').replace(/"/g, '""')}"`;

        csv += `${sanitizedTitle},${t.status},${t.priority},${dueDate},${t.estimatedHours || 0},${t.progressPercentage || 0}%,${tags},${subtasksDone},${subtasksTotal}\n`;
      }

      res.setHeader('Content-Type', 'text/csv');
      res.setHeader('Content-Disposition', `attachment; filename="${project.name.replace(/\s+/g, '_')}_export.csv"`);
      return res.send(csv);
    }

    // Default: JSON export
    res.json({
      project,
      exportedAt: new Date().toISOString(),
      taskCount: tasks.length,
      tasks,
    });
  } catch (error) {
    next(error);
  }
});

// ─── Task routes nested under projects ───────────────────────────

// GET /api/projects/:projectId/tasks — Get tasks for a project with search & filter
router.get('/:projectId/tasks', async (req, res, next) => {
  try {
    const project = await Project.findOne({
      _id: req.params.projectId,
      user: req.userId,
    });
    if (!project) {
      return res.status(404).json({ message: 'Project not found' });
    }

    const { search, status, priority, tag, sortBy = 'createdAt', order = 'desc' } = req.query;
    const query = {
      project: req.params.projectId,
      user: req.userId,
    };

    if (search && search.trim() !== '') {
      query.$or = [
        { title: { $regex: search.trim(), $options: 'i' } },
        { description: { $regex: search.trim(), $options: 'i' } },
      ];
    }

    if (status && status !== 'All') {
      query.status = status;
    }

    if (priority && priority !== 'All') {
      query.priority = priority;
    }

    if (tag && tag.trim() !== '') {
      query.tags = tag.trim();
    }

    const sortOrder = order === 'asc' ? 1 : -1;
    const sortField = ['title', 'priority', 'status', 'dueDate', 'createdAt'].includes(sortBy)
      ? sortBy
      : 'createdAt';

    const tasks = await Task.find(query).sort({ [sortField]: sortOrder });
    res.json(tasks);
  } catch (error) {
    next(error);
  }
});

// POST /api/projects/:projectId/tasks — Create a task in a project
router.post(
  '/:projectId/tasks',
  [
    body('title').trim().notEmpty().withMessage('Task title is required'),
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
      const project = await Project.findOne({
        _id: req.params.projectId,
        user: req.userId,
      });
      if (!project) {
        return res.status(404).json({ message: 'Project not found' });
      }

      const { title, description, priority, status, dueDate, estimatedHours, tags, subtasks } = req.body;
      const task = new Task({
        title,
        description,
        priority: priority || 'Medium',
        status: status || 'Todo',
        dueDate,
        estimatedHours: estimatedHours || 0,
        tags: Array.isArray(tags) ? tags : [],
        subtasks: Array.isArray(subtasks) ? subtasks : [],
        project: req.params.projectId,
        user: req.userId,
      });

      task.calculateProgress();
      await task.save();

      // Log activity
      await logActivity({
        userId: req.userId,
        action: 'TASK_CREATED',
        projectId: project._id,
        projectName: project.name,
        taskId: task._id,
        taskTitle: task.title,
        details: `Added task "${task.title}" to project "${project.name}" (Priority: ${task.priority})`,
      });

      res.status(201).json(task);
    } catch (error) {
      next(error);
    }
  }
);

module.exports = router;
