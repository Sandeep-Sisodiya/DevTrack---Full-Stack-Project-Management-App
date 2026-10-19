const ActivityLog = require('../models/ActivityLog');

/**
 * Records an activity event in the audit log.
 * Fails silently so it never interrupts the main request flow.
 */
async function logActivity({
  userId,
  action,
  projectId = null,
  projectName = '',
  taskId = null,
  taskTitle = '',
  details,
  metadata = {},
}) {
  try {
    await ActivityLog.create({
      user: userId,
      action,
      project: projectId,
      projectName,
      task: taskId,
      taskTitle,
      details,
      metadata,
    });
  } catch (error) {
    // Non-blocking log failure
    console.error('Failed to record activity log:', error.message);
  }
}

module.exports = { logActivity };
