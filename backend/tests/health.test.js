const request = require('supertest');
const app = require('../src/app');

describe('Health Endpoint', () => {
  it('GET /api/health should return status ok', async () => {
    const res = await request(app).get('/api/health');

    expect(res.statusCode).toBe(200);
    expect(res.body.status).toBe('ok');
    expect(res.body.service).toBe('DevTrack API');
  });
});
