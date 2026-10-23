const express = require('express');
const router = express.Router();
const { getProviderBookings } = require('../controllers/bookingController');
const authenticate = require('../middleware/auth');
const authorizeRoles = require('../middleware/roles');

// GET /api/provider/bookings - Provider assigned bookings
router.get('/bookings', authenticate, authorizeRoles('provider', 'admin'), getProviderBookings);

module.exports = router;
