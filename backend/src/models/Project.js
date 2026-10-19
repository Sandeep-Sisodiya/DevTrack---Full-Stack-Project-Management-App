const mongoose = require('mongoose');

const projectSchema = new mongoose.Schema(
  {
    name: {
      type: String,
      required: [true, 'Project name is required'],
      trim: true,
      maxlength: [100, 'Project name must be at most 100 characters'],
    },
    description: {
      type: String,
      trim: true,
      maxlength: [500, 'Description must be at most 500 characters'],
      default: '',
    },
    status: {
      type: String,
      enum: ['Planning', 'In Progress', 'Completed'],
      default: 'Planning',
    },
    category: {
      type: String,
      trim: true,
      default: 'General',
      maxlength: [50, 'Category must be at most 50 characters'],
    },
    color: {
      type: String,
      default: '#6C63FF',
    },
    tags: {
      type: [String],
      default: [],
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

// Indexes for high performance querying
projectSchema.index({ user: 1, status: 1, createdAt: -1 });
projectSchema.index({ user: 1, name: 'text', description: 'text' });

module.exports = mongoose.model('Project', projectSchema);
