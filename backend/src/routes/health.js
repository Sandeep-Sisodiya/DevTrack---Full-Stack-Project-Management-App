const express = require('express');
const mongoose = require('mongoose');

const router = express.Router();

// GET /api/health — Enterprise health & diagnostics endpoint
router.get('/', (req, res) => {
  const dbStateMap = {
    0: 'disconnected',
    1: 'connected',
    2: 'connecting',
    3: 'disconnecting',
  };

  const mem = process.memoryUsage();

  res.json({
    status: 'ok',
    service: 'DevTrack API',
    environment: process.env.NODE_ENV || 'development',
    uptimeSeconds: Math.floor(process.uptime()),
    database: dbStateMap[mongoose.connection.readyState] || 'unknown',
    memory: {
      heapUsedMB: Math.round((mem.heapUsed / 1024 / 1024) * 100) / 100,
      heapTotalMB: Math.round((mem.heapTotal / 1024 / 1024) * 100) / 100,
    },
    timestamp: new Date().toISOString(),
  });
});

module.exports = router;
