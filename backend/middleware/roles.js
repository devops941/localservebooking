const { sendError } = require('../utils/response');

const authorizeRoles = (...allowedRoles) => {
  return (req, res, next) => {
    if (!req.user) {
      return sendError(res, 'User identity not found. Authorization required.', 401);
    }

    if (!allowedRoles.includes(req.user.role)) {
      return sendError(
        res,
        `Access denied. Role '${req.user.role}' is not authorized to access this resource. Required: [${allowedRoles.join(', ')}]`,
        403
      );
    }

    next();
  };
};

module.exports = authorizeRoles;
