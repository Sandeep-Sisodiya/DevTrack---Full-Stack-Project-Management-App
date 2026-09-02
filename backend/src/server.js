require('dotenv').config();
const app = require('./app');
const connectDB = require('./config/db');

const PORT = process.env.PORT || 5000;

// Connect to MongoDB and start server
connectDB().then(() => {
  app.listen(PORT, '0.0.0.0', () => {
    console.log(`DevTrack API running on http://0.0.0.0:${PORT} (accessible at http://192.168.1.6:${PORT})`);
  });
});
