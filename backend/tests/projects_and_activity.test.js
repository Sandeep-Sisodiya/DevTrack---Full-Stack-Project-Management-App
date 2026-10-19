require('./setup');
const request = require('supertest');
const app = require('../src/app');

describe('Projects, Tasks, and Activity Feed Endpoints', () => {
  let token;

  const getAuthToken = async () => {
    const res = await request(app).post('/api/auth/register').send({
      name: 'Test Engineer',
      email: `engineer-${Date.now()}-${Math.random()}@devtrack.io`,
      password: 'Password123!',
    });
    return res.body.token;
  };

  beforeEach(async () => {
    token = await getAuthToken();
  });

  describe('Project Management & Search', () => {
    it('POST /api/projects should create a project with tags & category', async () => {
      const res = await request(app)
        .post('/api/projects')
        .set('Authorization', `Bearer ${token}`)
        .send({
          name: 'Core Platform v2',
          description: 'Next gen cloud microservices architecture',
          status: 'In Progress',
          category: 'Architecture',
          color: '#6366F1',
          tags: ['Cloud', 'NodeJS'],
        });

      expect(res.statusCode).toBe(201);
      expect(res.body.name).toBe('Core Platform v2');
      expect(res.body.category).toBe('Architecture');
      expect(res.body.tags).toContain('Cloud');
      expect(res.body.progressPercentage).toBe(0);
    });

    it('GET /api/projects should list projects and support search query', async () => {
      await request(app)
        .post('/api/projects')
        .set('Authorization', `Bearer ${token}`)
        .send({
          name: 'Core Platform v2',
          description: 'Next gen cloud microservices architecture',
        });

      const res = await request(app)
        .get('/api/projects?search=Core')
        .set('Authorization', `Bearer ${token}`);

      expect(res.statusCode).toBe(200);
      expect(Array.isArray(res.body)).toBe(true);
      expect(res.body.length).toBe(1);
      expect(res.body[0].name).toBe('Core Platform v2');
    });

    it('GET /api/projects/:id should return single project with metrics', async () => {
      const createRes = await request(app)
        .post('/api/projects')
        .set('Authorization', `Bearer ${token}`)
        .send({
          name: 'Analytics Service',
          description: 'Realtime telemetry pipeline',
        });

      const pId = createRes.body._id;

      const res = await request(app)
        .get(`/api/projects/${pId}`)
        .set('Authorization', `Bearer ${token}`);

      expect(res.statusCode).toBe(200);
      expect(res.body._id).toBe(pId);
      expect(res.body.totalTasks).toBe(0);
    });
  });

  describe('Tasks with Subtask Checklists', () => {
    it('POST /api/projects/:projectId/tasks should create a task with subtasks', async () => {
      const createProj = await request(app)
        .post('/api/projects')
        .set('Authorization', `Bearer ${token}`)
        .send({ name: 'Backend Cache' });

      const pId = createProj.body._id;

      const res = await request(app)
        .post(`/api/projects/${pId}/tasks`)
        .set('Authorization', `Bearer ${token}`)
        .send({
          title: 'Implement Redis Caching Layer',
          description: 'Cache frequent database queries',
          priority: 'High',
          status: 'In Progress',
          estimatedHours: 8,
          tags: ['Redis', 'Performance'],
          subtasks: [
            { title: 'Setup Redis container', isCompleted: true },
            { title: 'Add cache middleware', isCompleted: false },
          ],
        });

      expect(res.statusCode).toBe(201);
      expect(res.body.title).toBe('Implement Redis Caching Layer');
      expect(res.body.subtasks.length).toBe(2);
      expect(res.body.progressPercentage).toBe(50); // 1 out of 2 completed = 50%
    });

    it('PATCH /api/tasks/:id/subtasks/:subtaskId/toggle should toggle subtask completion', async () => {
      const createProj = await request(app)
        .post('/api/projects')
        .set('Authorization', `Bearer ${token}`)
        .send({ name: 'Backend Cache' });

      const pId = createProj.body._id;

      const taskRes = await request(app)
        .post(`/api/projects/${pId}/tasks`)
        .set('Authorization', `Bearer ${token}`)
        .send({
          title: 'Implement Redis Caching Layer',
          priority: 'High',
          status: 'In Progress',
          subtasks: [
            { title: 'Setup Redis container', isCompleted: true },
            { title: 'Add cache middleware', isCompleted: false },
          ],
        });

      const taskId = taskRes.body._id;
      const subtaskId = taskRes.body.subtasks[1]._id;

      const toggleRes = await request(app)
        .patch(`/api/tasks/${taskId}/subtasks/${subtaskId}/toggle`)
        .set('Authorization', `Bearer ${token}`);

      expect(toggleRes.statusCode).toBe(200);
      expect(toggleRes.body.subtasks[1].isCompleted).toBe(true);
      expect(toggleRes.body.progressPercentage).toBe(100);
      expect(toggleRes.body.status).toBe('Completed');
    });

    it('GET /api/projects/:id/export should export deliverables as JSON and CSV', async () => {
      const createProj = await request(app)
        .post('/api/projects')
        .set('Authorization', `Bearer ${token}`)
        .send({ name: 'Export Test Project' });

      const pId = createProj.body._id;

      await request(app)
        .post(`/api/projects/${pId}/tasks`)
        .set('Authorization', `Bearer ${token}`)
        .send({
          title: 'Exportable Task',
          priority: 'Medium',
          status: 'Todo',
        });

      // JSON export
      const jsonRes = await request(app)
        .get(`/api/projects/${pId}/export?format=json`)
        .set('Authorization', `Bearer ${token}`);

      expect(jsonRes.statusCode).toBe(200);
      expect(jsonRes.body.project._id).toBe(pId);
      expect(jsonRes.body.taskCount).toBe(1);

      // CSV export
      const csvRes = await request(app)
        .get(`/api/projects/${pId}/export?format=csv`)
        .set('Authorization', `Bearer ${token}`);

      expect(csvRes.statusCode).toBe(200);
      expect(csvRes.text).toContain('Task Title,Status,Priority');
      expect(csvRes.text).toContain('Exportable Task');
    });
  });

  describe('Activity Audit Trail & Analytics Feed', () => {
    it('GET /api/activity should return recorded events', async () => {
      await request(app)
        .post('/api/projects')
        .set('Authorization', `Bearer ${token}`)
        .send({ name: 'Audit Project' });

      const res = await request(app)
        .get('/api/activity')
        .set('Authorization', `Bearer ${token}`);

      expect(res.statusCode).toBe(200);
      expect(Array.isArray(res.body)).toBe(true);
      expect(res.body.length).toBeGreaterThan(0);
      expect(res.body[0].action).toBe('PROJECT_CREATED');
    });

    it('GET /api/dashboard/analytics should return productivity metrics', async () => {
      const res = await request(app)
        .get('/api/dashboard/analytics')
        .set('Authorization', `Bearer ${token}`);

      expect(res.statusCode).toBe(200);
      expect(res.body.statusDistribution).toBeDefined();
      expect(res.body.priorityDistribution).toBeDefined();
      expect(res.body.healthScore).toBeGreaterThanOrEqual(0);
    });
  });
});
