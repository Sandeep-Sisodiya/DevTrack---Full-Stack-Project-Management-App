const express = require('express');
const ActivityLog = require('../models/ActivityLog');
const auth = require('../middleware/auth');

const router = express.Router();

// All activity routes require authentication
router.use(auth);

// GET /api/activity — Get chronological activity audit trail feed
router.get('/', async (req, res, next) => {
  try {
    const { projectId, action, limit = 40 } = req.query;

    const query = { user: req.userId };
    if (projectId) {
      query.project = projectId;
    }
    if (action) {
      query.action = action;
    }

    const safeLimit = Math.min(Math.max(parseInt(limit, 10) || 40, 1), 100);

    const activities = await ActivityLog.find(query)
      .sort({ createdAt: -1 })
      .limit(safeLimit)
      .populate('project', 'name color')
      .lean();

    res.json(activities);
  } catch (error) {
    next(error);
  }
});

module.exports = router;
