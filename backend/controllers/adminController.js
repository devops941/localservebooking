const User = require('../models/User');
const ProviderProfile = require('../models/ProviderProfile');
const Booking = require('../models/Booking');
const Category = require('../models/Category');
const Notification = require('../models/Notification');
const { sendSuccess, sendError } = require('../utils/response');

// Get high-level Admin dashboard KPI analytics
const getAdminStats = async (req, res) => {
  try {
    const totalUsers = await User.countDocuments();
    const totalCustomers = await User.countDocuments({ role: 'customer' });
    const totalProviders = await User.countDocuments({ role: 'provider' });
    const pendingVerifications = await ProviderProfile.countDocuments({ isVerified: false });

    const totalBookings = await Booking.countDocuments();
    const activeBookings = await Booking.countDocuments({
      status: { $in: ['confirmed', 'inProgress'] },
    });
    const completedBookings = await Booking.countDocuments({ status: 'completed' });
    const cancelledBookings = await Booking.countDocuments({ status: 'cancelled' });

    // Financial calculations
    const completed = await Booking.find({ status: 'completed' });
    const grossVolume = completed.reduce((sum, b) => sum + (b.totalAmount || 0), 0);
    const platformCommission = completed.reduce(
      (sum, b) => sum + (b.commissionFee || Math.round((b.totalAmount || 0) * 0.15)),
      0
    );

    const totalCategories = await Category.countDocuments();

    return sendSuccess(res, 'Admin analytics retrieved successfully.', {
      stats: {
        totalUsers,
        totalCustomers,
        totalProviders,
        pendingVerifications,
        totalBookings,
        activeBookings,
        completedBookings,
        cancelledBookings,
        grossVolume,
        platformCommission,
        totalCategories,
      },
    });
  } catch (error) {
    return sendError(res, `Failed to get admin analytics: ${error.message}`, 500);
  }
};

// Get all bookings with filtering (Admin view)
const getAllBookings = async (req, res) => {
  try {
    const { status, limit = 50 } = req.query;
    const filter = {};
    if (status) filter.status = status;

    const bookings = await Booking.find(filter)
      .populate('customer', 'name email phone')
      .populate('provider', 'name email phone')
      .sort({ createdAt: -1 })
      .limit(Number(limit));

    return sendSuccess(res, 'All bookings retrieved.', {
      count: bookings.length,
      bookings,
    });
  } catch (error) {
    return sendError(res, `Failed to get bookings: ${error.message}`, 500);
  }
};

// Get unverified providers waiting for approval
const getPendingProviders = async (req, res) => {
  try {
    const providers = await ProviderProfile.find({ isVerified: false })
      .populate('user', 'name email phone status createdAt')
      .populate('category', 'name startingPrice');

    return sendSuccess(res, 'Pending provider applications retrieved.', {
      count: providers.length,
      providers,
    });
  } catch (error) {
    return sendError(res, `Failed to get pending providers: ${error.message}`, 500);
  }
};

// PATCH /api/admin/providers/:id/approval - Approve/reject provider
const handleProviderApproval = async (req, res) => {
  try {
    const { status, action, isVerified, approved } = req.body;
    const targetId = req.params.id;

    let provider = await ProviderProfile.findById(targetId);
    if (!provider) {
      provider = await ProviderProfile.findOne({ user: targetId });
    }

    if (!provider) {
      return sendError(res, 'Provider profile not found.', 404);
    }

    // Determine approval state:
    // status can be 'approved' | 'rejected'
    // action can be 'approve' | 'reject'
    // approved can be true | false
    // isVerified can be true | false
    let isApproved = true;
    if (status === 'rejected' || action === 'reject' || approved === false || isVerified === false) {
      isApproved = false;
    }

    provider.isVerified = isApproved;
    await provider.save();

    // Update user status
    const userStatus = isApproved ? 'active' : 'suspended';
    await User.findByIdAndUpdate(provider.user, { status: userStatus });

    const updatedUser = await User.findById(provider.user).select('name email phone role status');

    // Create in-app notification for the provider
    await Notification.create({
      user: provider.user,
      type: isApproved ? 'kyc_approved' : 'kyc_rejected',
      title: isApproved
        ? 'KYC Verified Successfully! 🎉'
        : 'KYC Application Update',
      message: isApproved
        ? 'Congratulations! Your profile has been verified by LocalServe admin. You can now start receiving bookings.'
        : 'Your KYC application was not approved. Please contact LocalServe support for assistance.',
    });

    return sendSuccess(
      res,
      `Provider application has been ${isApproved ? 'approved and activated' : 'rejected / suspended'}.`,
      {
        providerId: provider._id,
        user: updatedUser,
        isVerified: provider.isVerified,
        status: userStatus,
      }
    );
  } catch (error) {
    return sendError(res, `Failed to update provider approval: ${error.message}`, 500);
  }
};

// Approve or reject provider KYC (legacy /verify)
const verifyProvider = async (req, res) => {
  return handleProviderApproval(req, res);
};

// GET /api/admin/analytics/monthly — last 6 months revenue grouped by month
const getMonthlyRevenue = async (req, res) => {
  try {
    const now = new Date();
    const sixMonthsAgo = new Date(now.getFullYear(), now.getMonth() - 5, 1);

    const results = await Booking.aggregate([
      { $match: { bookingDate: { $gte: sixMonthsAgo }, status: 'completed' } },
      {
        $group: {
          _id: { year: { $year: '$bookingDate' }, month: { $month: '$bookingDate' } },
          grossVolume: { $sum: '$totalAmount' },
          bookingCount: { $sum: 1 },
        },
      },
      { $sort: { '_id.year': 1, '_id.month': 1 } },
    ]);

    const monthNames = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    const monthlyData = [];
    for (let i = 5; i >= 0; i--) {
      const d = new Date(now.getFullYear(), now.getMonth() - i, 1);
      const year = d.getFullYear();
      const month = d.getMonth() + 1; // 1-based
      const found = results.find(r => r._id.year === year && r._id.month === month);
      const gross = found ? Math.round(found.grossVolume) : 0;
      monthlyData.push({
        year,
        month,
        label: monthNames[d.getMonth()],
        grossVolume: gross,
        commission: Math.round(gross * 0.15),
        bookingCount: found ? found.bookingCount : 0,
      });
    }

    return sendSuccess(res, 'Monthly revenue data retrieved.', { monthlyData });
  } catch (error) {
    return sendError(res, `Failed to get monthly revenue: ${error.message}`, 500);
  }
};

module.exports = {
  getAdminStats,
  getAllBookings,
  getPendingProviders,
  verifyProvider,
  handleProviderApproval,
  getMonthlyRevenue,
};
