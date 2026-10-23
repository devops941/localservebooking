const express = require('express');
const router = express.Router();
const { submitReview } = require('../controllers/reviewController');
const authenticate = require('../middleware/auth');
const authorizeRoles = require('../middleware/roles');

// POST /api/reviews - Review completed booking (Customer)
router.post('/', authenticate, authorizeRoles('customer', 'admin'), submitReview);

module.exports = router;
