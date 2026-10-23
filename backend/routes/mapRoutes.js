const express = require('express');
const router = express.Router();
const { getRoute } = require('../controllers/mapController');
const authenticate = require('../middleware/auth');

// GET /api/map/route?startLat=&startLng=&endLat=&endLng=
router.get('/route', authenticate, getRoute);

module.exports = router;
