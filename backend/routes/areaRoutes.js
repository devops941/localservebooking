const express = require('express');
const router = express.Router();
const { getAreas } = require('../controllers/areaController');

// GET /api/areas - List supported areas (Public)
router.get('/', getAreas);

module.exports = router;
