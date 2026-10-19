const mongoose = require('mongoose');

const activityLogSchema = new mongoose.Schema(
  {
    user: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
      index: true,
    },
    action: {
      type: String,
      required: true,
      enum: [
        'PROJECT_CREATED',
        'PROJECT_UPDATED',
        'PROJECT_DELETED',
        'TASK_CREATED',
        'TASK_UPDATED',
        'TASK_STATUS_CHANGED',
        'TASK_DELETED',
        'SUBTASK_TOGGLED',
      ],
    },
    project: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Project',
      index: true,
    },
    projectName: {
      type: String,
      default: '',
    },
    task: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Task',
    },
    taskTitle: {
      type: String,
      default: '',
    },
    details: {
      type: String,
      required: true,
    },
    metadata: {
      type: mongoose.Schema.Types.Mixed,
      default: {},
    },
  },
  {
    timestamps: true,
  }
);

// Compound index for high performance chronological activity feed queries
activityLogSchema.index({ user: 1, createdAt: -1 });

module.exports = mongoose.model('ActivityLog', activityLogSchema);
