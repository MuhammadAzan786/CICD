const request = require('supertest');
const app = require('./server');

describe('GET /api/health', () => {
  it('should return status OK and success message', async () => {
    const response = await request(app).get('/api/health');

    expect(response.statusCode).toBe(200);
    expect(response.body).toHaveProperty('status', 'OK');
    expect(response.body).toHaveProperty('message', 'Backend is running');
  });
});
