const http = require('http');
const express = require('express');
const cors = require('cors');
const morgan = require('morgan');
const dotenv = require('dotenv');
const { Server } = require('socket.io');
const connectDB = require('./config/db');

dotenv.config(); // Reload env
// Non-blocking initial connection attempt for local environment
connectDB().catch((err) => console.error('Initial DB connection attempt:', err.message));

const app = express();
const httpServer = http.createServer(app);

// Socket.IO — live provider location tracking
const io = new Server(httpServer, {
  cors: { origin: '*', methods: ['GET', 'POST'] },
});

io.on('connection', (socket) => {
  // Customer or provider joins a booking room
  socket.on('join:booking', (bookingId) => {
    socket.join(`booking:${bookingId}`);
  });

  // Provider emits their current GPS; server fans out to the booking room
  socket.on('provider:location', ({ bookingId, lat, lng }) => {
    if (!bookingId || lat == null || lng == null) return;
    socket.to(`booking:${bookingId}`).emit('provider:location:update', { lat, lng });
  });

  socket.on('leave:booking', (bookingId) => {
    socket.leave(`booking:${bookingId}`);
  });
});

// Middlewares
app.use(cors());
app.use(express.json());
app.use(morgan('dev'));
app.use((req, _res, next) => { req.io = io; next(); });

// Ensure MongoDB connection readiness for database-dependent routes
app.use(async (req, res, next) => {
  // Liveness check, root message, and Socket.IO handshakes do not block on database connection
  if (req.path === '/api/health' || req.path === '/api/health/' || req.path === '/' || req.path.startsWith('/socket.io')) {
    return next();
  }
  try {
    await connectDB();
    next();
  } catch (err) {
    console.error(`Database connection unavailable for ${req.method} ${req.path}:`, err.message);
    res.status(503).json({
      success: false,
      message: 'Database connection unavailable. Please try again in a few moments.',
    });
  }
});

// Route imports
const authRoutes = require('./routes/authRoutes');
const userRoutes = require('./routes/userRoutes');
const categoryRoutes = require('./routes/categoryRoutes');
const areaRoutes = require('./routes/areaRoutes');
const providerRoutes = require('./routes/providerRoutes');
const providerBookingRoutes = require('./routes/providerBookingRoutes');
const bookingRoutes = require('./routes/bookingRoutes');
const reviewRoutes = require('./routes/reviewRoutes');
const adminRoutes = require('./routes/adminRoutes');
const notificationRoutes = require('./routes/notificationRoutes');
const paymentRoutes = require('./routes/paymentRoutes');
const mapRoutes = require('./routes/mapRoutes');

// Mount routes
app.use('/api/auth', authRoutes);
app.use('/api/users', userRoutes);
app.use('/api/categories', categoryRoutes);
app.use('/api/areas', areaRoutes);
app.use('/api/providers', providerRoutes);
app.use('/api/provider', providerBookingRoutes);
app.use('/api/bookings', bookingRoutes);
app.use('/api/reviews', reviewRoutes);
app.use('/api/admin', adminRoutes);
app.use('/api/notifications', notificationRoutes);
app.use('/api/payments', paymentRoutes);
app.use('/api/map', mapRoutes);

app.get('/api/health', (req, res) => {
  const mongoose = require('mongoose');
  const dbState = mongoose.connection.readyState;
  const dbStatusMap = {
    0: 'disconnected',
    1: 'connected',
    2: 'connecting',
    3: 'disconnecting',
  };

  res.status(200).json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    service: 'Local Service Booking Backend API',
    database: dbStatusMap[dbState] || 'unknown',
  });
});

app.get('/', (req, res) => {
  res.status(200).json({
    message: 'Welcome to Local Service Booking REST API',
    version: '1.0.0',
  });
});

app.use((req, res) => {
  res.status(404).json({ success: false, message: `API Route not found: ${req.originalUrl}` });
});

app.use((err, req, res, next) => {
  console.error('Unhandled Error:', err.stack);
  res.status(err.status || 500).json({ success: false, message: err.message || 'Internal Server Error' });
});

const PORT = process.env.PORT || 5000;
if (require.main === module) {
  httpServer.listen(PORT, () => {
    console.log(`🚀 LocalServe Backend running on http://localhost:${PORT}`);
    console.log(`🔌 Socket.IO ready for live location tracking`);
  });
}

module.exports = app;
