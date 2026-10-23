const express = require('express');
const router = express.Router();
const {
  getProviders,
  getProviderById,
  updateMyProfile,
  toggleAvailability,
  getProviderStats,
  withdrawWallet,
} = require('../controllers/providerController');
const authenticate = require('../middleware/auth');
const authorizeRoles = require('../middleware/roles');

// Provider authenticated actions (must come before /:id)
router.put('/me', authenticate, authorizeRoles('provider'), updateMyProfile);
router.patch('/me/availability', authenticate, authorizeRoles('provider'), toggleAvailability);
router.get('/me/stats', authenticate, authorizeRoles('provider'), getProviderStats);
router.post('/me/withdraw', authenticate, authorizeRoles('provider'), withdrawWallet);

// Public search & view
// GET /api/providers?categoryId=&areaId= - Search approved providers
router.get('/', getProviders);
// GET /api/providers/:id - Provider details
router.get('/:id', getProviderById);
router.get('/profile/:id', getProviderById);

module.exports = router;
