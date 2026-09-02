const express = require('express');
const Project = require('../models/Project');
const Task = require('../models/Task');
const auth = require('../middleware/auth');

const router = express.Router();

// GET /api/dashboard — Get aggregated stats for the authenticated user
router.get('/', auth, async (req, res, next) => {
  try {
    const userId = req.userId;

    // Count projects
    const totalProjects = await Project.countDocuments({ user: userId });

    // Count tasks by status
    const totalTasks = await Task.countDocuments({ user: userId });
    const pendingTasks = await Task.countDocuments({
      user: userId,
      status: { $in: ['Todo', 'In Progress'] },
    });
    const completedTasks = await Task.countDocuments({
      user: userId,
      status: 'Completed',
    });

    // Recent projects (last 5)
    const recentProjects = await Project.find({ user: userId })
      .sort({ createdAt: -1 })
      .limit(5);

    // Recent tasks (last 5)
    const recentTasks = await Task.find({ user: userId })
      .sort({ createdAt: -1 })
      .limit(5)
      .populate('project', 'name');

    res.json({
      totalProjects,
      totalTasks,
      pendingTasks,
      completedTasks,
      recentProjects,
      recentTasks,
    });
  } catch (error) {
    next(error);
  }
});

module.exports = router;
