const express = require('express');
const cors = require('cors');
const authRoutes = require('./routes/authRoutes');
const healthRoutes = require('./routes/healthRoutes');
const mapRoutes = require('./routes/mapRoutes');
const walletRoutes = require('./routes/walletRoutes');
const rentalRoutes = require('./routes/rentalRoutes');
const historyRoutes = require('./routes/historyRoutes');
const faultRoutes = require('./routes/faultRoutes');
const errorHandler = require('./middlewares/errorHandler');

const app = express();

// Middleware
app.use(cors());
app.use(express.json());

// Request logging
app.use((req, res, next) => {
  console.log(`[${new Date().toISOString()}] ${req.method} ${req.url}`);
  if (req.body && Object.keys(req.body).length > 0) {
    console.log('  Body:', JSON.stringify(req.body));
  }
  next();
});

// Routes
app.use('/api/health', healthRoutes);
app.use('/api/auth', authRoutes);
app.use('/api/map', mapRoutes);
app.use('/api/wallet', walletRoutes);
app.use('/api/rental', rentalRoutes);
app.use('/api/history', historyRoutes);
app.use('/api/faults', faultRoutes);

// Error handling middleware
app.use(errorHandler);

module.exports = app;
