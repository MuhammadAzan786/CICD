const express = require('express');
const cors = require('cors');

const app = express();
const PORT = process.env.PORT || 5000;

// Middleware
app.use(cors());
app.use(express.json());

// GET /api/health - Health check endpoint
app.get('/api/health', (req, res) => {
  res.json({
    status: 'OK',
    message: 'Backend is running'
  });
});

// GET /api/users - Returns hardcoded array of users
app.get('/api/users', (req, res) => {
  const users = [
    { id: 1, name: 'John' },
    { id: 2, name: 'Jane' }
  ];
  res.json(users);
});

// GET /api/info - Returns app info with current timestamp
app.get('/api/info', (req, res) => {
  res.json({
    app: 'my-backend',
    version: '1.0.0',
    timestamp: new Date().toISOString()
  });
});

// Start server only if this file is run directly
if (require.main === module) {
  app.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`);
  });
}

// Export app for testing
module.exports = app;
