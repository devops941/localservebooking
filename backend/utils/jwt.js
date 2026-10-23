const jwt = require('jsonwebtoken');

const generateToken = (user) => {
  const payload = {
    id: user._id,
    email: user.email,
    role: user.role,
  };

  const secret = process.env.JWT_SECRET || 'supersecret_localserve_jwt_key_2026';
  const expiresIn = process.env.JWT_EXPIRES_IN || '7d';

  return jwt.sign(payload, secret, { expiresIn });
};

const verifyToken = (token) => {
  const secret = process.env.JWT_SECRET || 'supersecret_localserve_jwt_key_2026';
  return jwt.verify(token, secret);
};

module.exports = {
  generateToken,
  verifyToken,
};
