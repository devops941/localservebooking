const express = require('express');
const router = express.Router();
const {
  getCategories,
  getCategoryById,
  createCategory,
  updateCategory,
  deleteCategory,
} = require('../controllers/categoryController');
const authenticate = require('../middleware/auth');
const authorizeRoles = require('../middleware/roles');

// Public routes
router.get('/', getCategories);
router.get('/:id', getCategoryById);

// Admin-protected routes
router.post('/', authenticate, authorizeRoles('admin'), createCategory);
router.put('/:id', authenticate, authorizeRoles('admin'), updateCategory);
router.delete('/:id', authenticate, authorizeRoles('admin'), deleteCategory);

module.exports = router;
