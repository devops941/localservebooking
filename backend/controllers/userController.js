const User = require('../models/User');
const { sendSuccess, sendError } = require('../utils/response');

// Get all users (Admin only)
const getUsers = async (req, res) => {
  try {
    const { role, status, search } = req.query;
    const filter = {};

    if (role) filter.role = role;
    if (status) filter.status = status;
    if (search) {
      filter.$or = [
        { name: { $regex: search, $options: 'i' } },
        { email: { $regex: search, $options: 'i' } },
        { phone: { $regex: search, $options: 'i' } },
      ];
    }

    const users = await User.find(filter).sort({ createdAt: -1 });
    return sendSuccess(res, 'Users fetched successfully.', {
      count: users.length,
      users,
    });
  } catch (error) {
    return sendError(res, `Failed to fetch users: ${error.message}`, 500);
  }
};

// Get single user by ID
const getUserById = async (req, res) => {
  try {
    const user = await User.findById(req.params.id);
    if (!user) {
      return sendError(res, 'User not found.', 404);
    }
    return sendSuccess(res, 'User found.', { user });
  } catch (error) {
    return sendError(res, `Failed to get user: ${error.message}`, 500);
  }
};

// Update user status (Admin only)
const updateUserStatus = async (req, res) => {
  try {
    const { status } = req.body;
    if (!['active', 'inactive', 'pending', 'suspended'].includes(status)) {
      return sendError(res, 'Invalid status value.', 400);
    }

    const user = await User.findByIdAndUpdate(
      req.params.id,
      { status },
      { new: true }
    );

    if (!user) {
      return sendError(res, 'User not found.', 404);
    }

    return sendSuccess(res, `User status updated to ${status}.`, { user });
  } catch (error) {
    return sendError(res, `Failed to update user status: ${error.message}`, 500);
  }
};

// Delete user (Admin only)
const deleteUser = async (req, res) => {
  try {
    const user = await User.findByIdAndDelete(req.params.id);
    if (!user) {
      return sendError(res, 'User not found.', 404);
    }
    return sendSuccess(res, 'User deleted successfully.');
  } catch (error) {
    return sendError(res, `Failed to delete user: ${error.message}`, 500);
  }
};

module.exports = {
  getUsers,
  getUserById,
  updateUserStatus,
  deleteUser,
};
