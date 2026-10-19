const mongoose = require('mongoose');

const subtaskSchema = new mongoose.Schema(
  {
    title: {
      type: String,
      required: true,
      trim: true,
      maxlength: [120, 'Subtask title cannot exceed 120 characters'],
    },
    isCompleted: {
      type: Boolean,
      default: false,
    },
  },
  { _id: true }
);

const taskSchema = new mongoose.Schema(
  {
    title: {
      type: String,
      required: [true, 'Task title is required'],
      trim: true,
      maxlength: [100, 'Title must be at most 100 characters'],
    },
    description: {
      type: String,
      trim: true,
      maxlength: [500, 'Description must be at most 500 characters'],
      default: '',
    },
    priority: {
      type: String,
      enum: ['Low', 'Medium', 'High'],
      default: 'Medium',
    },
    status: {
      type: String,
      enum: ['Todo', 'In Progress', 'Completed'],
      default: 'Todo',
    },
    dueDate: {
      type: Date,
      default: null,
    },
    estimatedHours: {
      type: Number,
      default: 0,
      min: [0, 'Estimated hours cannot be negative'],
    },
    tags: {
      type: [String],
      default: [],
    },
    subtasks: {
      type: [subtaskSchema],
      default: [],
    },
    progressPercentage: {
      type: Number,
      default: 0,
      min: 0,
      max: 100,
    },
    project: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Project',
      required: true,
    },
    user: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },
  },
  {
    timestamps: true,
  }
);

// Method to automatically compute progress percentage
taskSchema.methods.calculateProgress = function () {
  if (this.subtasks && this.subtasks.length > 0) {
    const completedCount = this.subtasks.filter((s) => s.isCompleted).length;
    this.progressPercentage = Math.round((completedCount / this.subtasks.length) * 100);
    if (this.progressPercentage === 100 && this.status !== 'Completed') {
      this.status = 'Completed';
    } else if (this.progressPercentage > 0 && this.status === 'Todo') {
      this.status = 'In Progress';
    }
  } else {
    if (this.status === 'Completed') {
      this.progressPercentage = 100;
    } else if (this.status === 'In Progress') {
      this.progressPercentage = 50;
    } else {
      this.progressPercentage = 0;
    }
  }
  return this.progressPercentage;
};

// Hook before save to keep progress in sync
taskSchema.pre('save', function (next) {
  this.calculateProgress();
  next();
});

// Indexes for fast lookup, filtering, and sorting
taskSchema.index({ user: 1, project: 1, status: 1 });
taskSchema.index({ user: 1, dueDate: 1 });
taskSchema.index({ user: 1, priority: 1 });
taskSchema.index({ user: 1, title: 'text', description: 'text' });

module.exports = mongoose.model('Task', taskSchema);
