const express = require('express');
const router = express.Router();
const {
  getAdminStats,
  getAllBookings,
  getPendingProviders,
  verifyProvider,
  handleProviderApproval,
  getMonthlyRevenue,
} = require('../controllers/adminController');
const { createCategory, getCategories } = require('../controllers/categoryController');
const authenticate = require('../middleware/auth');
const authorizeRoles = require('../middleware/roles');

router.use(authenticate);
router.use(authorizeRoles('admin'));

// Admin Dashboard KPIs
router.get('/stats', getAdminStats);

// Monthly revenue chart data
router.get('/analytics/monthly', getMonthlyRevenue);

// Platform Bookings
router.get('/bookings', getAllBookings);

// Provider KYC Verification & Approval
router.get('/providers/pending', getPendingProviders);
// PATCH /api/admin/providers/:id/approval - Approve/reject provider
router.patch('/providers/:id/approval', handleProviderApproval);
router.patch('/providers/:id/verify', verifyProvider);

// Service Categories (Admin)
// POST /api/admin/categories - Create service category
router.post('/categories', createCategory);
router.get('/categories', getCategories);

module.exports = router;
