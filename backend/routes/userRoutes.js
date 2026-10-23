const express = require('express');
const router = express.Router();
const {
  getUsers,
  getUserById,
  updateUserStatus,
  deleteUser,
} = require('../controllers/userController');
const authenticate = require('../middleware/auth');
const authorizeRoles = require('../middleware/roles');

// All user management routes require admin role
router.use(authenticate);
router.use(authorizeRoles('admin'));

router.get('/', getUsers);
router.get('/:id', getUserById);
router.put('/:id/status', updateUserStatus);
router.delete('/:id', deleteUser);

module.exports = router;
