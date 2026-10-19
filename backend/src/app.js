const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const rateLimit = require('express-rate-limit');
const swaggerUi = require('swagger-ui-express');
const swaggerDoc = require('./docs/swaggerDoc');
const { errorHandler } = require('./middleware/errorHandler');

// Import routes
const healthRoutes = require('./routes/health');
const authRoutes = require('./routes/auth');
const projectRoutes = require('./routes/projects');
const taskRoutes = require('./routes/tasks');
const userRoutes = require('./routes/users');
const dashboardRoutes = require('./routes/dashboard');
const activityRoutes = require('./routes/activity');

const app = express();

// Security HTTP headers
app.use(
  helmet({
    contentSecurityPolicy: false, // Allows Swagger UI to render assets cleanly
  })
);

// Rate Limiting (bypassed in test environment)
const isTest = process.env.NODE_ENV === 'test';

const globalLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: isTest ? 10000 : 300, // 300 requests per 15 min in production
  standardHeaders: true,
  legacyHeaders: false,
  message: { message: 'Too many requests from this IP, please try again after 15 minutes' },
});

const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: isTest ? 10000 : 30, // 30 attempts per 15 min for auth to prevent brute force
  standardHeaders: true,
  legacyHeaders: false,
  message: { message: 'Too many authentication attempts, please try again after 15 minutes' },
});

app.use(globalLimiter);

// Standard Middlewares
app.use(cors());
app.use(express.json());
if (!isTest) {
  app.use(morgan('dev'));
}

// Interactive Swagger / OpenAPI Documentation
app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(swaggerDoc));

// Routes
app.use('/api/health', healthRoutes);
app.use('/api/auth', authLimiter, authRoutes);
app.use('/api/projects', projectRoutes);
app.use('/api/tasks', taskRoutes);
app.use('/api/users', userRoutes);
app.use('/api/dashboard', dashboardRoutes);
app.use('/api/activity', activityRoutes);

// Centralized error handling
app.use(errorHandler);

module.exports = app;
