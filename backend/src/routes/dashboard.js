const express = require('express');
const Project = require('../models/Project');
const Task = require('../models/Task');
const ActivityLog = require('../models/ActivityLog');
const auth = require('../middleware/auth');

const router = express.Router();

// All dashboard routes require authentication
router.use(auth);

// GET /api/dashboard — Get aggregated overview stats
router.get('/', async (req, res, next) => {
  try {
    const userId = req.userId;
    const now = new Date();

    // Counts
    const totalProjects = await Project.countDocuments({ user: userId });
    const totalTasks = await Task.countDocuments({ user: userId });
    const pendingTasks = await Task.countDocuments({
      user: userId,
      status: { $in: ['Todo', 'In Progress'] },
    });
    const completedTasks = await Task.countDocuments({
      user: userId,
      status: 'Completed',
    });

    // Overdue tasks
    const overdueTasks = await Task.countDocuments({
      user: userId,
      status: { $ne: 'Completed' },
      dueDate: { $ne: null, $lt: now },
    });

    const completionRate = totalTasks > 0 ? Math.round((completedTasks / totalTasks) * 100) : 0;

    // Recent projects
    const rawProjects = await Project.find({ user: userId })
      .sort({ updatedAt: -1 })
      .limit(5);

    // Compute stats for recent projects
    const projectIds = rawProjects.map((p) => p._id);
    const tasksForProjects = await Task.find({ project: { $in: projectIds }, user: userId }).select(
      'project status'
    );

    const statsMap = {};
    for (const id of projectIds) {
      statsMap[id.toString()] = { totalTasks: 0, completedTasks: 0 };
    }
    for (const t of tasksForProjects) {
      const pId = t.project.toString();
      if (statsMap[pId]) {
        statsMap[pId].totalTasks += 1;
        if (t.status === 'Completed') statsMap[pId].completedTasks += 1;
      }
    }

    const recentProjects = rawProjects.map((p) => {
      const pObj = p.toObject();
      const s = statsMap[p._id.toString()] || { totalTasks: 0, completedTasks: 0 };
      const progress = s.totalTasks > 0 ? Math.round((s.completedTasks / s.totalTasks) * 100) : 0;
      return {
        ...pObj,
        totalTasks: s.totalTasks,
        completedTasks: s.completedTasks,
        progressPercentage: progress,
      };
    });

    // Recent tasks
    const recentTasks = await Task.find({ user: userId })
      .sort({ updatedAt: -1 })
      .limit(5)
      .populate('project', 'name color');

    // Recent activities (last 5)
    const recentActivities = await ActivityLog.find({ user: userId })
      .sort({ createdAt: -1 })
      .limit(5)
      .populate('project', 'name color')
      .lean();

    res.json({
      totalProjects,
      totalTasks,
      pendingTasks,
      completedTasks,
      overdueTasks,
      completionRate,
      recentProjects,
      recentTasks,
      recentActivities,
    });
  } catch (error) {
    next(error);
  }
});

// GET /api/dashboard/analytics — Get deep productivity and distribution metrics
router.get('/analytics', async (req, res, next) => {
  try {
    const userId = req.userId;
    const now = new Date();
    const sevenDaysAgo = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);
    const fourteenDaysAgo = new Date(now.getTime() - 14 * 24 * 60 * 60 * 1000);

    // Distribution by status
    const statusCounts = {
      Todo: await Task.countDocuments({ user: userId, status: 'Todo' }),
      InProgress: await Task.countDocuments({ user: userId, status: 'In Progress' }),
      Completed: await Task.countDocuments({ user: userId, status: 'Completed' }),
    };

    // Distribution by priority
    const priorityCounts = {
      High: await Task.countDocuments({ user: userId, priority: 'High' }),
      Medium: await Task.countDocuments({ user: userId, priority: 'Medium' }),
      Low: await Task.countDocuments({ user: userId, priority: 'Low' }),
    };

    // Tasks completed in last 7 days vs previous 7 days
    const completedLast7Days = await Task.countDocuments({
      user: userId,
      status: 'Completed',
      updatedAt: { $gte: sevenDaysAgo },
    });

    const completedPrior7Days = await Task.countDocuments({
      user: userId,
      status: 'Completed',
      updatedAt: { $gte: fourteenDaysAgo, $lt: sevenDaysAgo },
    });

    const totalTasks = statusCounts.Todo + statusCounts.InProgress + statusCounts.Completed;
    const overdueTasks = await Task.countDocuments({
      user: userId,
      status: { $ne: 'Completed' },
      dueDate: { $ne: null, $lt: now },
    });

    // Compute health score (0 - 100)
    let healthScore = 100;
    if (totalTasks > 0) {
      const overdueRatio = overdueTasks / totalTasks;
      healthScore = Math.max(0, Math.round(100 - overdueRatio * 50 - (statusCounts.Todo / totalTasks) * 20));
    }

    res.json({
      statusDistribution: statusCounts,
      priorityDistribution: priorityCounts,
      velocity: {
        last7Days: completedLast7Days,
        prior7Days: completedPrior7Days,
        trend: completedLast7Days >= completedPrior7Days ? 'up' : 'down',
      },
      healthScore,
      overdueTasks,
      totalTasks,
    });
  } catch (error) {
    next(error);
  }
});

module.exports = router;
