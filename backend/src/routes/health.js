const express = require('express');
const router = express.Router();

// GET /api/health — Simple health check for deployment monitoring
router.get('/', (req, res) => {
  res.json({
    status: 'ok',
    service: 'DevTrack API',
  });
});

module.exports = router;
