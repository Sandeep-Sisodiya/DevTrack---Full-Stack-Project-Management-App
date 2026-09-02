const express = require('express');
const { body } = require('express-validator');
const Task = require('../models/Task');
const Project = require('../models/Project');
const auth = require('../middleware/auth');
const validate = require('../middleware/validate');

const router = express.Router();

// All task routes require authentication
router.use(auth);

// GET /api/projects/:projectId/tasks — Get all tasks for a project
// Note: This route is mounted under /api/tasks but handles the /projects/:projectId/tasks pattern
// via app.js mounting. We handle it here for clarity.

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
  ],
  validate,
  async (req, res, next) => {
    try {
      const { title, description, priority, status, dueDate } = req.body;
      const task = await Task.findOneAndUpdate(
        { _id: req.params.id, user: req.userId },
        { title, description, priority, status, dueDate },
        { new: true, runValidators: true }
      );
      if (!task) {
        return res.status(404).json({ message: 'Task not found' });
      }
      res.json(task);
    } catch (error) {
      next(error);
    }
  }
);

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
    res.json({ message: 'Task deleted successfully' });
  } catch (error) {
    next(error);
  }
});

module.exports = router;
