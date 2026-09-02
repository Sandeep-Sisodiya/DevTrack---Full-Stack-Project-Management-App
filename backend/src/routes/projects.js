const express = require('express');
const { body } = require('express-validator');
const Project = require('../models/Project');
const Task = require('../models/Task');
const auth = require('../middleware/auth');
const validate = require('../middleware/validate');

const router = express.Router();

// All project routes require authentication
router.use(auth);

// GET /api/projects — Get all projects for the authenticated user
router.get('/', async (req, res, next) => {
  try {
    const projects = await Project.find({ user: req.userId }).sort({ createdAt: -1 });
    res.json(projects);
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
  ],
  validate,
  async (req, res, next) => {
    try {
      const { name, description, status } = req.body;
      const project = await Project.create({
        name,
        description,
        status,
        user: req.userId,
      });
      res.status(201).json(project);
    } catch (error) {
      next(error);
    }
  }
);

// GET /api/projects/:id — Get a single project by ID
router.get('/:id', async (req, res, next) => {
  try {
    const project = await Project.findOne({ _id: req.params.id, user: req.userId });
    if (!project) {
      return res.status(404).json({ message: 'Project not found' });
    }
    res.json(project);
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
  ],
  validate,
  async (req, res, next) => {
    try {
      const { name, description, status } = req.body;
      const project = await Project.findOneAndUpdate(
        { _id: req.params.id, user: req.userId },
        { name, description, status },
        { new: true, runValidators: true }
      );
      if (!project) {
        return res.status(404).json({ message: 'Project not found' });
      }
      res.json(project);
    } catch (error) {
      next(error);
    }
  }
);

// DELETE /api/projects/:id — Delete a project and all its tasks
router.delete('/:id', async (req, res, next) => {
  try {
    const project = await Project.findOneAndDelete({
      _id: req.params.id,
      user: req.userId,
    });
    if (!project) {
      return res.status(404).json({ message: 'Project not found' });
    }
    // Also delete all tasks belonging to this project
    await Task.deleteMany({ project: req.params.id });
    res.json({ message: 'Project and its tasks deleted successfully' });
  } catch (error) {
    next(error);
  }
});

// ─── Task routes nested under projects ───────────────────────────

// GET /api/projects/:projectId/tasks — Get all tasks for a project
router.get('/:projectId/tasks', async (req, res, next) => {
  try {
    // Verify the project belongs to this user
    const project = await Project.findOne({
      _id: req.params.projectId,
      user: req.userId,
    });
    if (!project) {
      return res.status(404).json({ message: 'Project not found' });
    }

    const tasks = await Task.find({
      project: req.params.projectId,
      user: req.userId,
    }).sort({ createdAt: -1 });

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
  ],
  validate,
  async (req, res, next) => {
    try {
      // Verify the project belongs to this user
      const project = await Project.findOne({
        _id: req.params.projectId,
        user: req.userId,
      });
      if (!project) {
        return res.status(404).json({ message: 'Project not found' });
      }

      const { title, description, priority, status, dueDate } = req.body;
      const task = await Task.create({
        title,
        description,
        priority,
        status,
        dueDate,
        project: req.params.projectId,
        user: req.userId,
      });

      res.status(201).json(task);
    } catch (error) {
      next(error);
    }
  }
);

module.exports = router;
