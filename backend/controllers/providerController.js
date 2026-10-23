const mongoose = require('mongoose');
const ProviderProfile = require('../models/ProviderProfile');
const Booking = require('../models/Booking');
const Category = require('../models/Category');
const { sendSuccess, sendError } = require('../utils/response');

// GET /api/providers?categoryId=&areaId= - Search approved providers
const getProviders = async (req, res) => {
  try {
    const { categoryId, category, areaId, area, city = 'Madurai', search, includeUnverified } = req.query;
    const filter = {};

    // Requirement 4: Show only Admin KYC-approved service providers
    if (includeUnverified !== 'true') {
      filter.isVerified = true;
    }

    // Requirement 4: Show only Active service providers
    filter.isAvailable = true;

    // Requirement 1: Filter by Madurai city
    if (city && city.trim() !== '') {
      filter.city = { $regex: city.trim(), $options: 'i' };
    }

    // Category filter: support categoryId or category query param
    const selectedCategory = categoryId || category;
    if (selectedCategory && selectedCategory.trim() !== '') {
      const catTrimmed = selectedCategory.trim();
      if (mongoose.Types.ObjectId.isValid(catTrimmed)) {
        const catDoc = await Category.findById(catTrimmed);
        filter.$and = filter.$and || [];
        if (catDoc) {
          filter.$and.push({
            $or: [
              { category: catTrimmed },
              { profession: { $regex: catDoc.name, $options: 'i' } },
            ],
          });
        } else {
          filter.$and.push({ category: catTrimmed });
        }
      } else {
        const catDoc = await Category.findOne({
          name: { $regex: new RegExp(`^${catTrimmed}$`, 'i') },
        });
        filter.$and = filter.$and || [];
        if (catDoc) {
          filter.$and.push({
            $or: [
              { category: catDoc._id },
              { profession: { $regex: catDoc.name, $options: 'i' } },
            ],
          });
        } else {
          filter.$and.push({ profession: { $regex: catTrimmed, $options: 'i' } });
        }
      }
    }

    // Area filter: support areaId or area query param (Requirement 3)
    const selectedArea = areaId || area;
    if (selectedArea && selectedArea.trim() !== '') {
      const cleanArea = selectedArea.replace(/^area-/, '').replace(/-/g, ' ').trim();
      const locality = cleanArea.split(',')[0].trim();
      // Only filter by specific locality if it's not the entire city name
      if (locality.toLowerCase() !== 'madurai') {
        filter.$or = [
          { area: { $regex: locality, $options: 'i' } },
          { area: { $regex: cleanArea, $options: 'i' } },
        ];
      }
    }

    let query = ProviderProfile.find(filter)
      .populate('user', 'name email phone status role')
      .populate('category', 'name icon startingPrice');

    const providers = await query.exec();

    // Requirement 4: Filter out any provider whose associated user account is not active
    let result = providers.filter(
      (p) => p.user && p.user.status === 'active'
    );

    // If search text is provided, filter by user name or profession
    if (search && search.trim() !== '') {
      const q = search.trim().toLowerCase();
      result = result.filter(
        (p) =>
          p.profession.toLowerCase().includes(q) ||
          (p.user && p.user.name && p.user.name.toLowerCase().includes(q)) ||
          p.services.some((s) => s.title.toLowerCase().includes(q))
      );
    }

    // Ensure name is populated from user account if empty
    const formatted = result.map((p) => {
      const pObj = p.toObject ? p.toObject() : p;
      if (!pObj.name && pObj.user && pObj.user.name) {
        pObj.name = pObj.user.name;
      }
      return pObj;
    });

    return sendSuccess(res, 'Approved providers retrieved successfully.', {
      count: formatted.length,
      providers: formatted,
    });
  } catch (error) {
    return sendError(res, `Failed to get providers: ${error.message}`, 500);
  }
};

// GET /api/providers/:id - Provider details
const getProviderById = async (req, res) => {
  try {
    const targetId = req.params.id;
    let provider = null;

    if (mongoose.Types.ObjectId.isValid(targetId)) {
      provider = await ProviderProfile.findById(targetId)
        .populate('user', 'name email phone status')
        .populate('category', 'name icon startingPrice');

      if (!provider) {
        // Try finding by user ID
        provider = await ProviderProfile.findOne({ user: targetId })
          .populate('user', 'name email phone status')
          .populate('category', 'name icon startingPrice');
      }
    }

    if (!provider) {
      return sendError(res, 'Provider profile not found.', 404);
    }

    // Fetch recent reviews for this provider
    const recentReviews = await Booking.find({
      provider: provider.user?._id || provider.user,
      rating: { $exists: true, $ne: null },
    })
      .select('rating reviewComment bookingNumber createdAt customer')
      .populate('customer', 'name')
      .sort({ createdAt: -1 })
      .limit(5);

    const pObj = provider.toObject ? provider.toObject() : provider;
    if (!pObj.name && pObj.user && pObj.user.name) {
      pObj.name = pObj.user.name;
    }

    return sendSuccess(res, 'Provider details retrieved successfully.', {
      provider: pObj,
      reviews: recentReviews,
    });
  } catch (error) {
    return sendError(res, `Failed to get provider: ${error.message}`, 500);
  }
};

// Update current provider profile
const updateMyProfile = async (req, res) => {
  try {
    const { profession, hourlyRate, experienceYears, bio, area, city, services, upiId } = req.body;

    let profile = await ProviderProfile.findOne({ user: req.user._id });

    if (!profile) {
      profile = new ProviderProfile({ user: req.user._id });
    }

    if (profession) profile.profession = profession;
    if (hourlyRate !== undefined) profile.hourlyRate = hourlyRate;
    if (experienceYears !== undefined) profile.experienceYears = experienceYears;
    if (bio !== undefined) profile.bio = bio;
    if (area) profile.area = area;
    if (city) profile.city = city;
    if (services) profile.services = services;
    if (upiId !== undefined) profile.upiId = upiId.trim();

    await profile.save();

    return sendSuccess(res, 'Provider profile updated successfully.', { profile });
  } catch (error) {
    return sendError(res, `Failed to update provider profile: ${error.message}`, 500);
  }
};

// Toggle provider online/offline status
const toggleAvailability = async (req, res) => {
  try {
    const profile = await ProviderProfile.findOne({ user: req.user._id });
    if (!profile) {
      return sendError(res, 'Provider profile not found.', 404);
    }

    profile.isAvailable = !profile.isAvailable;
    await profile.save();

    return sendSuccess(res, `Provider is now ${profile.isAvailable ? 'Available' : 'Offline'}.`, {
      isAvailable: profile.isAvailable,
    });
  } catch (error) {
    return sendError(res, `Failed to toggle availability: ${error.message}`, 500);
  }
};

// Get provider dashboard statistics
const getProviderStats = async (req, res) => {
  try {
    const profile = await ProviderProfile.findOne({ user: req.user._id });
    const totalJobs = await Booking.countDocuments({
      provider: req.user._id,
      status: 'completed',
    });
    const pendingJobs = await Booking.countDocuments({
      provider: req.user._id,
      status: 'pending',
    });
    const activeJobs = await Booking.countDocuments({
      provider: req.user._id,
      status: { $in: ['confirmed', 'inProgress'] },
    });

    const completedBookings = await Booking.find({
      provider: req.user._id,
      status: 'completed',
    });

    const totalEarnings = completedBookings.reduce((sum, b) => sum + (b.totalAmount || 0), 0);
    const availableBalance = Math.max(0, Math.round(totalEarnings * 0.85) - (profile?.totalWithdrawn || 0));

    return sendSuccess(res, 'Provider stats retrieved.', {
      rating: profile ? profile.rating : 5.0,
      reviewCount: profile ? profile.reviewCount : 0,
      totalCompletedJobs: totalJobs,
      pendingRequests: pendingJobs,
      activeJobs: activeJobs,
      totalEarnings: totalEarnings,
      walletBalance: availableBalance, // 15% platform commission minus withdrawals
      isAvailable: profile ? profile.isAvailable : true,
      isVerified: profile ? profile.isVerified : false,
    });
  } catch (error) {
    return sendError(res, `Failed to get provider stats: ${error.message}`, 500);
  }
};

const withdrawWallet = async (req, res) => {
  try {
    const { amount, bankName, accountNumber, ifscCode } = req.body;
    if (!amount || amount <= 0) return sendError(res, 'Invalid withdrawal amount.', 400);
    if (!bankName || !accountNumber || !ifscCode) return sendError(res, 'Bank details are required.', 400);

    const profile = await ProviderProfile.findOne({ user: req.user._id });
    if (!profile) return sendError(res, 'Provider profile not found.', 404);

    // Compute available balance
    const completedBookings = await Booking.find({ provider: req.user._id, status: 'completed' });
    const totalEarnings = completedBookings.reduce((sum, b) => sum + (b.totalAmount || 0), 0);
    const availableBalance = Math.max(0, Math.round(totalEarnings * 0.85) - (profile.totalWithdrawn || 0));

    if (amount > availableBalance) return sendError(res, `Insufficient balance. Available: ₹${availableBalance}`, 400);

    profile.totalWithdrawn = (profile.totalWithdrawn || 0) + amount;
    await profile.save();

    return sendSuccess(res, 'Withdrawal request submitted successfully. Funds will be credited within 2 business days.', {
      withdrawnAmount: amount,
      newBalance: availableBalance - amount,
    });
  } catch (error) {
    return sendError(res, `Withdrawal failed: ${error.message}`, 500);
  }
};

module.exports = {
  getProviders,
  getProviderById,
  updateMyProfile,
  toggleAvailability,
  getProviderStats,
  withdrawWallet,
};
