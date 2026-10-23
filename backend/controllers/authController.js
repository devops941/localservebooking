const crypto = require('crypto');
const bcrypt = require('bcryptjs');
const nodemailer = require('nodemailer');
const dotenv = require('dotenv');
const User = require('../models/User');
const Otp = require('../models/Otp');
const ProviderProfile = require('../models/ProviderProfile');
const { generateToken } = require('../utils/jwt');
const { sendSuccess, sendError } = require('../utils/response');

// ─── Register ────────────────────────────────────────────────────────────────
const register = async (req, res) => {
  try {
    const { name, email, phone, password, role = 'customer', profession, area, hourlyRate, experienceYears } = req.body;

    if (!name || !email || !phone || !password) {
      return sendError(res, 'Please provide name, email, phone, and password.', 400);
    }

    const existingUser = await User.findOne({ email: email.toLowerCase() });
    if (existingUser) {
      return sendError(res, 'An account with this email already exists.', 400);
    }

    const passwordHash = await User.hashPassword(password);

    const user = await User.create({
      name,
      email: email.toLowerCase(),
      phone,
      passwordHash,
      role: ['customer', 'provider', 'admin'].includes(role) ? role : 'customer',
      status: role === 'provider' ? 'pending' : 'active',
    });

    if (user.role === 'provider') {
      const cleanArea = (area || 'Madurai').trim();
      await ProviderProfile.create({
        user: user._id,
        profession: profession || 'General Service Specialist',
        area: cleanArea,
        city: 'Madurai',
        hourlyRate: hourlyRate || 249,
        experienceYears: experienceYears || 1,
        isVerified: false,
      });
    }

    const token = generateToken(user);
    return sendSuccess(res, 'Registration successful.', { user, token }, 201);
  } catch (error) {
    return sendError(res, `Registration failed: ${error.message}`, 500);
  }
};

// ─── Login ────────────────────────────────────────────────────────────────────
const login = async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return sendError(res, 'Please provide email and password.', 400);
    }

    const user = await User.findOne({ email: email.toLowerCase() });
    if (!user) return sendError(res, 'Invalid credentials. User not found.', 401);

    const isMatch = await user.comparePassword(password);
    if (!isMatch) return sendError(res, 'Invalid credentials. Incorrect password.', 401);

    if (user.status === 'suspended') {
      return sendError(res, 'Your account is suspended. Contact administrator.', 403);
    }

    const token = generateToken(user);

    let providerProfile = null;
    if (user.role === 'provider') {
      providerProfile = await ProviderProfile.findOne({ user: user._id });
    }

    return sendSuccess(res, 'Logged in successfully.', { user, providerProfile, token });
  } catch (error) {
    return sendError(res, `Login failed: ${error.message}`, 500);
  }
};

// ─── Get current user ─────────────────────────────────────────────────────────
const getMe = async (req, res) => {
  try {
    let providerProfile = null;
    if (req.user.role === 'provider') {
      providerProfile = await ProviderProfile.findOne({ user: req.user._id });
    }
    return sendSuccess(res, 'Profile retrieved.', { user: req.user, providerProfile });
  } catch (error) {
    return sendError(res, `Failed to get profile: ${error.message}`, 500);
  }
};

// ─── Update profile ───────────────────────────────────────────────────────────
const updateProfile = async (req, res) => {
  try {
    const { name, phone, gender } = req.body;
    const user = await User.findById(req.user._id);
    if (name) user.name = name;
    if (phone) user.phone = phone;
    if (gender && ['male', 'female', 'other'].includes(gender)) user.gender = gender;
    await user.save();
    return sendSuccess(res, 'Profile updated successfully.', { user });
  } catch (error) {
    return sendError(res, `Profile update failed: ${error.message}`, 500);
  }
};

// ─── Helpers ──────────────────────────────────────────────────────────────────
function isEmailConfigured() {
  dotenv.config();
  // Generic SMTP (SMTP_HOST, SMTP_USER, SMTP_PASS)
  const smtpHost = (process.env.SMTP_HOST || '').trim();
  const smtpUser = (process.env.SMTP_USER || '').trim();
  const smtpPass = (process.env.SMTP_PASS || '').trim();
  if (smtpHost && smtpUser && smtpPass && !smtpPass.includes('xxxx')) {
    return true;
  }
  // Brevo SMTP
  const brevoUser = (process.env.BREVO_SMTP_USER || '').trim();
  const brevoKey  = (process.env.BREVO_SMTP_KEY  || '').trim();
  if (brevoUser.includes('@') && brevoKey.length >= 20 && !brevoKey.includes('xxxx')) {
    return true;
  }
  // Gmail App Password
  const gmailUser = (process.env.GMAIL_USER         || '').trim();
  const gmailPass = (process.env.GMAIL_APP_PASSWORD || '').trim();
  return (
    gmailUser.includes('@') &&
    !gmailUser.includes('your_gmail') &&
    gmailPass.length >= 16 &&
    !gmailPass.includes('xxxx')
  );
}

function createTransporter() {
  const smtpHost = (process.env.SMTP_HOST || '').trim();
  const smtpUser = (process.env.SMTP_USER || '').trim();
  const smtpPass = (process.env.SMTP_PASS || '').trim();

  if (smtpHost && smtpUser && smtpPass && !smtpPass.includes('xxxx')) {
    const smtpPort = parseInt(process.env.SMTP_PORT || '465', 10);
    const smtpSecure = process.env.SMTP_SECURE === 'true' || smtpPort === 465;
    return nodemailer.createTransport({
      host: smtpHost,
      port: smtpPort,
      secure: smtpSecure,
      auth: { user: smtpUser, pass: smtpPass },
      tls: { rejectUnauthorized: false },
    });
  }

  const brevoUser = (process.env.BREVO_SMTP_USER || '').trim();
  const brevoKey  = (process.env.BREVO_SMTP_KEY  || '').trim();

  if (brevoUser.includes('@') && brevoKey.length >= 20 && !brevoKey.includes('xxxx')) {
    // Brevo SMTP (preferred — no 2FA needed)
    return nodemailer.createTransport({
      host: 'smtp-relay.brevo.com',
      port: 587,
      secure: false,
      auth: { user: brevoUser, pass: brevoKey },
    });
  }

  // Gmail App Password fallback
  return nodemailer.createTransport({
    service: 'gmail',
    auth: {
      user: process.env.GMAIL_USER,
      pass: process.env.GMAIL_APP_PASSWORD,
    },
    tls: { rejectUnauthorized: false },
  });
}

function getSenderAddress() {
  if (process.env.SMTP_FROM && process.env.SMTP_FROM.trim()) {
    return process.env.SMTP_FROM.trim();
  }
  const emailAddr = (process.env.SMTP_USER || process.env.GMAIL_USER || process.env.BREVO_SMTP_USER || '').trim();
  return `"LocalServe" <${emailAddr}>`;
}

// ─── Step 1: Send OTP ─────────────────────────────────────────────────────────
const sendOtp = async (req, res) => {
  try {
    const { email } = req.body;
    if (!email) return sendError(res, 'Email is required.', 400);

    const user = await User.findOne({ email: email.toLowerCase() });
    if (!user) return sendError(res, 'No account found with this email address.', 404);

    // Resend cooldown: 60 seconds
    const recent = await Otp.findOne({ email: email.toLowerCase(), verified: false }).sort({ createdAt: -1 });
    if (recent) {
      const elapsed = (Date.now() - new Date(recent.createdAt).getTime()) / 1000;
      if (elapsed < 60) {
        const wait = Math.ceil(60 - elapsed);
        return sendError(res, `Please wait ${wait} seconds before requesting another OTP.`, 429);
      }
    }

    // Clear old OTPs for this email
    await Otp.deleteMany({ email: email.toLowerCase() });

    // Generate & hash OTP
    const otp = Math.floor(100000 + Math.random() * 900000).toString();
    const salt = await bcrypt.genSalt(10);
    const otpHash = await bcrypt.hash(otp, salt);
    const expiresAt = new Date(Date.now() + 5 * 60 * 1000);

    await Otp.create({ email: email.toLowerCase(), otpHash, expiresAt });

    if (!isEmailConfigured()) {
      if (process.env.NODE_ENV === 'production') {
        return sendError(
          res,
          'Email service is not configured on this server. Contact support.',
          503
        );
      }
      // DEV: log to console only — OTP is never exposed in the API response
      console.log('\n========== DEV MODE OTP ==========');
      console.log(`  Email : ${email}`);
      console.log(`  OTP   : ${otp}`);
      console.log(`  Valid : 5 minutes`);
      console.log('  Tip   : Set GMAIL_USER + GMAIL_APP_PASSWORD in .env for real delivery');
      console.log('===================================\n');
      return sendSuccess(res, 'OTP generated. Check server console (dev mode). Valid for 5 minutes.');
    }

    const transporter = createTransporter();

    try {
      await transporter.sendMail({
        from: getSenderAddress(),
        to: email,
        subject: 'Your OTP for Password Reset – LocalServe',
        html: `
          <div style="font-family:Arial,sans-serif;max-width:480px;margin:auto;padding:28px;border:1px solid #e5e7eb;border-radius:14px;">
            <div style="text-align:center;margin-bottom:20px;">
              <h2 style="color:#1565C0;margin:0;">LocalServe</h2>
              <p style="color:#6B7280;font-size:13px;margin:4px 0 0;">Madurai Local Service Booking</p>
            </div>
            <p style="color:#374151;font-size:15px;">Hi <strong>${user.name}</strong>,</p>
            <p style="color:#374151;font-size:14px;">Your one-time password (OTP) for resetting your account password is:</p>
            <div style="font-size:38px;font-weight:bold;letter-spacing:12px;color:#1565C0;padding:18px 10px;background:#EFF6FF;border-radius:10px;text-align:center;margin:20px 0;">${otp}</div>
            <p style="color:#374151;font-size:14px;">This OTP is valid for <strong>5 minutes</strong> only. Do not share it with anyone.</p>
            <hr style="border:none;border-top:1px solid #E5E7EB;margin:20px 0;">
            <p style="color:#9CA3AF;font-size:12px;">If you did not request a password reset, you can safely ignore this email.</p>
          </div>
        `,
      });
    } catch (smtpError) {
      // Clean up the OTP we created since we couldn't deliver it
      await Otp.deleteMany({ email: email.toLowerCase() });

      const isAuthError =
        smtpError.code === 'EAUTH' ||
        (smtpError.responseCode >= 530 && smtpError.responseCode <= 538);

      console.error(`[OTP Email] SMTP error for ${email}:`, smtpError.message);

      if (isAuthError) {
        return sendError(
          res,
          'Email service authentication failed. Contact support.',
          503
        );
      }
      return sendError(
        res,
        'Failed to send OTP email. Please try again in a moment.',
        503
      );
    }

    return sendSuccess(res, `OTP sent to ${email}. Valid for 5 minutes.`);
  } catch (error) {
    return sendError(res, `Failed to send OTP: ${error.message}`, 500);
  }
};

// ─── Step 2: Verify OTP ───────────────────────────────────────────────────────
const verifyOtp = async (req, res) => {
  try {
    const { email, otp } = req.body;
    if (!email || !otp) return sendError(res, 'Email and OTP are required.', 400);

    const record = await Otp.findOne({ email: email.toLowerCase(), verified: false }).sort({ createdAt: -1 });
    if (!record) return sendError(res, 'No active OTP found. Please request a new one.', 404);

    if (new Date() > record.expiresAt) {
      await Otp.deleteOne({ _id: record._id });
      return sendError(res, 'OTP has expired. Please request a new one.', 410);
    }

    if (record.attempts >= 5) {
      await Otp.deleteOne({ _id: record._id });
      return sendError(res, 'Too many incorrect attempts. Please request a new OTP.', 429);
    }

    const isMatch = await bcrypt.compare(otp.toString(), record.otpHash);
    if (!isMatch) {
      await Otp.updateOne({ _id: record._id }, { $inc: { attempts: 1 } });
      const remaining = 4 - record.attempts;
      return sendError(res, `Incorrect OTP. ${remaining} attempt(s) remaining.`, 400);
    }

    // OTP verified — issue a short-lived reset token
    const resetToken = crypto.randomBytes(32).toString('hex');
    const resetTokenExpiresAt = new Date(Date.now() + 10 * 60 * 1000); // 10 min

    await Otp.updateOne({ _id: record._id }, { verified: true, resetToken, resetTokenExpiresAt });

    return sendSuccess(res, 'OTP verified successfully.', { resetToken });
  } catch (error) {
    return sendError(res, `OTP verification failed: ${error.message}`, 500);
  }
};

// ─── Step 3: Reset Password ───────────────────────────────────────────────────
const resetPassword = async (req, res) => {
  try {
    const { email, resetToken, newPassword } = req.body;
    if (!email || !resetToken || !newPassword) {
      return sendError(res, 'Email, reset token, and new password are required.', 400);
    }
    if (newPassword.length < 6) {
      return sendError(res, 'Password must be at least 6 characters.', 400);
    }

    const record = await Otp.findOne({
      email: email.toLowerCase(),
      verified: true,
      resetToken,
    });

    if (!record) return sendError(res, 'Invalid or expired reset session. Please start over.', 400);

    if (new Date() > record.resetTokenExpiresAt) {
      await Otp.deleteOne({ _id: record._id });
      return sendError(res, 'Reset session has expired. Please start over.', 410);
    }

    const user = await User.findOne({ email: email.toLowerCase() });
    if (!user) return sendError(res, 'User not found.', 404);

    user.passwordHash = await User.hashPassword(newPassword);
    await user.save();
    await Otp.deleteOne({ _id: record._id });

    return sendSuccess(res, 'Password reset successfully. You can now log in with your new password.');
  } catch (error) {
    return sendError(res, `Password reset failed: ${error.message}`, 500);
  }
};

module.exports = {
  register,
  login,
  getMe,
  updateProfile,
  sendOtp,
  verifyOtp,
  resetPassword,
};
