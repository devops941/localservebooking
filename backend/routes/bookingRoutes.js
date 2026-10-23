const express = require('express');
const router = express.Router();
const {
  createBooking,
  getCustomerBookings,
  getProviderBookings,
  updateBookingStatus,
  submitReview,
} = require('../controllers/bookingController');
const authenticate = require('../middleware/auth');
const authorizeRoles = require('../middleware/roles');

router.use(authenticate);

// POST /api/bookings - Create booking (customer)
router.post('/', authorizeRoles('customer', 'admin'), createBooking);

// GET /api/bookings/mine - Customer booking history
router.get('/mine', authorizeRoles('customer', 'admin'), getCustomerBookings);
router.get('/customer', authorizeRoles('customer', 'admin'), getCustomerBookings);

// GET /api/bookings/provider - Provider booking history (alternative path)
router.get('/provider', authorizeRoles('provider', 'admin'), getProviderBookings);

// PATCH /api/bookings/:id/status - Authorized status update
router.patch('/:id/status', updateBookingStatus);

// Customer review by booking ID
router.post('/:id/review', authorizeRoles('customer'), submitReview);

module.exports = router;
