/**
 * OpenAPI 3.0.0 Specification for DevTrack REST API
 */
const swaggerSpec = {
  openapi: '3.0.0',
  info: {
    title: 'DevTrack Project Management API',
    version: '1.2.0',
    description:
      'Production-grade RESTful API for DevTrack — full-stack developer project management app with JWT auth, task checklist pipelines, audit trails, and executive productivity analytics.',
    contact: {
      name: 'DevTrack Engineering',
    },
  },
  servers: [
    {
      url: 'http://localhost:5000',
      description: 'Local Development Server',
    },
  ],
  components: {
    securitySchemes: {
      bearerAuth: {
        type: 'http',
        scheme: 'bearer',
        bearerFormat: 'JWT',
        description: 'Enter your JWT token in the format: Bearer <token>',
      },
    },
    schemas: {
      User: {
        type: 'object',
        properties: {
          _id: { type: 'string', example: '66f0a1b2c3d4e5f6a7b8c9d0' },
          name: { type: 'string', example: 'Alex Developer' },
          email: { type: 'string', example: 'alex@devtrack.io' },
          createdAt: { type: 'string', format: 'date-time' },
        },
      },
      Subtask: {
        type: 'object',
        properties: {
          _id: { type: 'string', example: '66f0a1b2c3d4e5f6a7b8c9d1' },
          title: { type: 'string', example: 'Write unit tests' },
          isCompleted: { type: 'boolean', example: false },
        },
      },
      Task: {
        type: 'object',
        properties: {
          _id: { type: 'string', example: '66f0a1b2c3d4e5f6a7b8c9d2' },
          title: { type: 'string', example: 'Implement WebSocket notifications' },
          description: { type: 'string', example: 'Support live updates on task status' },
          priority: { type: 'string', enum: ['Low', 'Medium', 'High'], example: 'High' },
          status: { type: 'string', enum: ['Todo', 'In Progress', 'Completed'], example: 'In Progress' },
          dueDate: { type: 'string', format: 'date-time', nullable: true },
          estimatedHours: { type: 'number', example: 6 },
          progressPercentage: { type: 'number', example: 50 },
          tags: { type: 'array', items: { type: 'string' }, example: ['Backend', 'WebSocket'] },
          subtasks: { type: 'array', items: { $ref: '#/components/schemas/Subtask' } },
          project: { type: 'string', example: '66f0a1b2c3d4e5f6a7b8c9d3' },
          createdAt: { type: 'string', format: 'date-time' },
        },
      },
      Project: {
        type: 'object',
        properties: {
          _id: { type: 'string', example: '66f0a1b2c3d4e5f6a7b8c9d3' },
          name: { type: 'string', example: 'Cloud Infrastructure Migration' },
          description: { type: 'string', example: 'Migrate legacy workloads to AWS ECS' },
          status: { type: 'string', enum: ['Planning', 'In Progress', 'Completed'], example: 'In Progress' },
          category: { type: 'string', example: 'DevOps' },
          color: { type: 'string', example: '#6C63FF' },
          tags: { type: 'array', items: { type: 'string' }, example: ['Infrastructure', 'AWS'] },
          totalTasks: { type: 'number', example: 8 },
          completedTasks: { type: 'number', example: 5 },
          progressPercentage: { type: 'number', example: 63 },
          createdAt: { type: 'string', format: 'date-time' },
        },
      },
      ActivityLog: {
        type: 'object',
        properties: {
          _id: { type: 'string' },
          action: { type: 'string', example: 'TASK_STATUS_CHANGED' },
          projectName: { type: 'string', example: 'Mobile App V2' },
          taskTitle: { type: 'string', example: 'Refactor Auth Provider' },
          details: { type: 'string', example: 'Moved "Refactor Auth Provider" from "Todo" to "Completed"' },
          createdAt: { type: 'string', format: 'date-time' },
        },
      },
    },
  },
  paths: {
    '/api/health': {
      get: {
        summary: 'System Health & Metrics',
        tags: ['System'],
        responses: {
          200: {
            description: 'API is running healthy with diagnostic metrics',
          },
        },
      },
    },
    '/api/auth/register': {
      post: {
        summary: 'Register a new developer account',
        tags: ['Authentication'],
        requestBody: {
          required: true,
          content: {
            'application/json': {
              schema: {
                type: 'object',
                required: ['name', 'email', 'password'],
                properties: {
                  name: { type: 'string', example: 'Alex Developer' },
                  email: { type: 'string', example: 'alex@example.com' },
                  password: { type: 'string', example: 'securePassword123' },
                },
              },
            },
          },
        },
        responses: {
          201: { description: 'User successfully registered' },
          400: { description: 'Validation error or email already in use' },
        },
      },
    },
    '/api/auth/login': {
      post: {
        summary: 'Authenticate and receive JWT token',
        tags: ['Authentication'],
        requestBody: {
          required: true,
          content: {
            'application/json': {
              schema: {
                type: 'object',
                required: ['email', 'password'],
                properties: {
                  email: { type: 'string', example: 'alex@example.com' },
                  password: { type: 'string', example: 'securePassword123' },
                },
              },
            },
          },
        },
        responses: {
          200: { description: 'Authenticated successfully with JWT bearer token' },
          401: { description: 'Invalid email or password' },
        },
      },
    },
    '/api/users/me': {
      get: {
        summary: 'Get current authenticated user profile',
        tags: ['Authentication'],
        security: [{ bearerAuth: [] }],
        responses: {
          200: { description: 'Current user profile data' },
          401: { description: 'Unauthorized' },
        },
      },
    },
    '/api/dashboard': {
      get: {
        summary: 'Get executive dashboard statistics',
        tags: ['Dashboard'],
        security: [{ bearerAuth: [] }],
        responses: {
          200: { description: 'Aggregated overview of projects, tasks, and recent audit activity' },
        },
      },
    },
    '/api/dashboard/analytics': {
      get: {
        summary: 'Get deep productivity velocity and health analytics',
        tags: ['Dashboard'],
        security: [{ bearerAuth: [] }],
        responses: {
          200: { description: 'Status and priority distributions, 7-day velocity, health score' },
        },
      },
    },
    '/api/projects': {
      get: {
        summary: 'List all projects with search, status filters, and live progress',
        tags: ['Projects'],
        security: [{ bearerAuth: [] }],
        parameters: [
          { name: 'search', in: 'query', schema: { type: 'string' }, description: 'Search term for name/description' },
          { name: 'status', in: 'query', schema: { type: 'string', enum: ['All', 'Planning', 'In Progress', 'Completed'] } },
          { name: 'category', in: 'query', schema: { type: 'string' } },
          { name: 'sortBy', in: 'query', schema: { type: 'string', default: 'createdAt' } },
          { name: 'order', in: 'query', schema: { type: 'string', enum: ['asc', 'desc'], default: 'desc' } },
        ],
        responses: {
          200: {
            description: 'List of projects with computed progress percentages',
            content: { 'application/json': { schema: { type: 'array', items: { $ref: '#/components/schemas/Project' } } } },
          },
        },
      },
      post: {
        summary: 'Create a new project',
        tags: ['Projects'],
        security: [{ bearerAuth: [] }],
        requestBody: {
          required: true,
          content: {
            'application/json': {
              schema: {
                type: 'object',
                required: ['name'],
                properties: {
                  name: { type: 'string', example: 'API Microservices' },
                  description: { type: 'string', example: 'Refactor monolith into Go microservices' },
                  status: { type: 'string', enum: ['Planning', 'In Progress', 'Completed'] },
                  category: { type: 'string', example: 'Backend' },
                  color: { type: 'string', example: '#10B981' },
                  tags: { type: 'array', items: { type: 'string' } },
                },
              },
            },
          },
        },
        responses: {
          201: { description: 'Project created' },
        },
      },
    },
    '/api/projects/{id}/export': {
      get: {
        summary: 'Export project deliverables as CSV or JSON',
        tags: ['Projects'],
        security: [{ bearerAuth: [] }],
        parameters: [
          { name: 'id', in: 'path', required: true, schema: { type: 'string' } },
          { name: 'format', in: 'query', schema: { type: 'string', enum: ['json', 'csv'], default: 'json' } },
        ],
        responses: {
          200: { description: 'Exported file or JSON payload' },
        },
      },
    },
    '/api/projects/{projectId}/tasks': {
      get: {
        summary: 'Get all tasks for a project with multi-filtering',
        tags: ['Tasks'],
        security: [{ bearerAuth: [] }],
        parameters: [
          { name: 'projectId', in: 'path', required: true, schema: { type: 'string' } },
          { name: 'search', in: 'query', schema: { type: 'string' } },
          { name: 'status', in: 'query', schema: { type: 'string' } },
          { name: 'priority', in: 'query', schema: { type: 'string' } },
        ],
        responses: {
          200: { description: 'List of tasks in project' },
        },
      },
      post: {
        summary: 'Create a task with checklist subtasks and tags in a project',
        tags: ['Tasks'],
        security: [{ bearerAuth: [] }],
        parameters: [{ name: 'projectId', in: 'path', required: true, schema: { type: 'string' } }],
        requestBody: {
          required: true,
          content: {
            'application/json': {
              schema: {
                type: 'object',
                required: ['title'],
                properties: {
                  title: { type: 'string', example: 'Implement Rate Limiting' },
                  description: { type: 'string', example: 'Protect auth endpoints against brute force' },
                  priority: { type: 'string', enum: ['Low', 'Medium', 'High'] },
                  status: { type: 'string', enum: ['Todo', 'In Progress', 'Completed'] },
                  dueDate: { type: 'string', format: 'date-time' },
                  estimatedHours: { type: 'number', example: 4 },
                  tags: { type: 'array', items: { type: 'string' } },
                  subtasks: {
                    type: 'array',
                    items: {
                      type: 'object',
                      properties: {
                        title: { type: 'string' },
                        isCompleted: { type: 'boolean' },
                      },
                    },
                  },
                },
              },
            },
          },
        },
        responses: {
          201: { description: 'Task created' },
        },
      },
    },
    '/api/tasks/{id}/subtasks/{subtaskId}/toggle': {
      patch: {
        summary: 'One-click toggle of a subtask checklist item',
        tags: ['Tasks'],
        security: [{ bearerAuth: [] }],
        parameters: [
          { name: 'id', in: 'path', required: true, schema: { type: 'string' } },
          { name: 'subtaskId', in: 'path', required: true, schema: { type: 'string' } },
        ],
        responses: {
          200: { description: 'Subtask toggled and parent progress recalculated' },
        },
      },
    },
    '/api/activity': {
      get: {
        summary: 'Get chronological activity audit trail feed',
        tags: ['Activity'],
        security: [{ bearerAuth: [] }],
        parameters: [
          { name: 'projectId', in: 'query', schema: { type: 'string' } },
          { name: 'limit', in: 'query', schema: { type: 'integer', default: 40 } },
        ],
        responses: {
          200: {
            description: 'Audit logs representing user actions and timeline events',
            content: { 'application/json': { schema: { type: 'array', items: { $ref: '#/components/schemas/ActivityLog' } } } },
          },
        },
      },
    },
  },
};

module.exports = swaggerSpec;
