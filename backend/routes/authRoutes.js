const express = require('express');
const router = express.Router();
const {
  register,
  login,
  getMe,
  updateProfile,
  sendOtp,
  verifyOtp,
  resetPassword,
} = require('../controllers/authController');
const authenticate = require('../middleware/auth');

router.post('/register', register);
router.post('/login', login);
router.get('/me', authenticate, getMe);
router.put('/profile', authenticate, updateProfile);

// Password reset via OTP
router.post('/forgot-password', sendOtp);
router.post('/verify-otp', verifyOtp);
router.post('/reset-password', resetPassword);

module.exports = router;
