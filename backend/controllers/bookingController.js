const Booking = require('../models/Booking');
const ProviderProfile = require('../models/ProviderProfile');
const Notification = require('../models/Notification');
const { sendSuccess, sendError } = require('../utils/response');

// Create a new booking (Customer)
const createBooking = async (req, res) => {
  try {
    const {
      providerId,
      serviceTitle,
      categoryName,
      bookingDate,
      timeSlot,
      totalAmount,
      address,
      notes,
      customerLat,
      customerLng,
    } = req.body;

    if (!providerId || !serviceTitle || !bookingDate || !timeSlot || !totalAmount || !address) {
      return sendError(res, 'Please provide all required booking details.', 400);
    }

    // Resolve provider User ID if ProviderProfile ID was passed
    let targetProviderUserId = providerId;
    const profile = await ProviderProfile.findById(providerId);
    if (profile && profile.user) {
      targetProviderUserId = profile.user;
    }

    // Normalize address object so Mongoose validation never fails
    let normalizedAddress = {};
    if (typeof address === 'string') {
      const cleanStr = address.trim();
      const parts = cleanStr.split(',').map((s) => s.trim());
      const parsedArea = parts.length > 1 ? parts[1] : (parts[0] || 'Madurai');
      normalizedAddress = {
        fullAddress: cleanStr,
        area: parsedArea || 'Madurai',
        city: 'Madurai',
        landmark: '',
        pincode: '',
      };
    } else if (typeof address === 'object') {
      const full = (address.fullAddress || address.address || 'Madurai').trim();
      const parts = full.split(',').map((s) => s.trim());
      const fallbackArea = parts.length > 1 ? parts[1] : (parts[0] || 'Madurai');
      normalizedAddress = {
        fullAddress: full,
        area: (address.area || fallbackArea || 'Madurai').trim(),
        city: (address.city || 'Madurai').trim(),
        landmark: (address.landmark || '').trim(),
        pincode: (address.pincode || '').trim(),
      };
    }

    const booking = await Booking.create({
      customer: req.user._id,
      provider: targetProviderUserId,
      serviceTitle,
      categoryName: categoryName || (profile ? profile.profession : 'Service'),
      bookingDate: new Date(bookingDate),
      timeSlot,
      totalAmount,
      commissionFee: Math.round(totalAmount * 0.15), // 15% platform commission
      address: normalizedAddress,
      customerLocation: {
        lat: customerLat ? parseFloat(customerLat) : null,
        lng: customerLng ? parseFloat(customerLng) : null,
      },
      notes: notes || '',
      status: 'pending',
    });

    // Notify the service provider immediately about the new booking request
    try {
      await Notification.create({
        user: targetProviderUserId,
        type: 'booking_request',
        title: 'New Service Booking Request!',
        message: `New booking for ${serviceTitle} from ${req.user.name || 'Customer'} at ${normalizedAddress.area}, Madurai (₹${totalAmount}). Check and accept now!`,
      });
    } catch (notifErr) {
      console.warn('Could not create provider notification:', notifErr.message);
    }

    const populated = await Booking.findById(booking._id)
      .populate('customer', 'name email phone')
      .populate('provider', 'name email phone');

    return sendSuccess(res, 'Booking created successfully.', { booking: populated }, 201);
  } catch (error) {
    return sendError(res, `Failed to create booking: ${error.message}`, 500);
  }
};

// Get bookings for logged-in Customer
const getCustomerBookings = async (req, res) => {
  try {
    const { status } = req.query;
    const filter = { customer: req.user._id };
    if (status) filter.status = status;

    const bookings = await Booking.find(filter)
      .populate('provider', 'name email phone')
      .sort({ createdAt: -1 });

    return sendSuccess(res, 'Customer bookings retrieved.', {
      count: bookings.length,
      bookings,
    });
  } catch (error) {
    return sendError(res, `Failed to get customer bookings: ${error.message}`, 500);
  }
};

// Get bookings for logged-in Provider
const getProviderBookings = async (req, res) => {
  try {
    const { status } = req.query;
    
    // Check both req.user._id and ProviderProfile ID to ensure no bookings are ever missed
    const profile = await ProviderProfile.findOne({ user: req.user._id });
    const providerIds = [req.user._id];
    if (profile) providerIds.push(profile._id);

    const filter = { provider: { $in: providerIds } };
    if (status) filter.status = status;

    const bookings = await Booking.find(filter)
      .populate('customer', 'name email phone')
      .sort({ createdAt: -1 });

    return sendSuccess(res, 'Provider bookings retrieved.', {
      count: bookings.length,
      bookings,
    });
  } catch (error) {
    return sendError(res, `Failed to get provider bookings: ${error.message}`, 500);
  }
};

// Update booking status (Accept, Start, Complete, Cancel)
const updateBookingStatus = async (req, res) => {
  try {
    const { status } = req.body;
    const allowed = ['pending', 'confirmed', 'inProgress', 'completed', 'cancelled'];

    if (!allowed.includes(status)) {
      return sendError(res, 'Invalid booking status transition.', 400);
    }

    const booking = await Booking.findById(req.params.id);
    if (!booking) {
      return sendError(res, 'Booking not found.', 404);
    }

    // Role check: Only customer can cancel, only assigned provider or admin can confirm/complete
    if (
      req.user.role !== 'admin' &&
      booking.customer.toString() !== req.user._id.toString() &&
      booking.provider.toString() !== req.user._id.toString()
    ) {
      return sendError(res, 'Unauthorized to update this booking.', 403);
    }

    booking.status = status;
    if (status === 'completed') {
      // Only increment completedJobs count; earnings update happens when payment is confirmed
      await ProviderProfile.findOneAndUpdate(
        { user: booking.provider },
        { $inc: { completedJobs: 1 } }
      );
    }

    await booking.save();

    // Notify customer about status update
    try {
      const statusTitle =
        status === 'confirmed'
          ? 'Booking Accepted!'
          : status === 'inProgress'
          ? 'Provider is on the way / In Progress'
          : status === 'completed'
          ? 'Service Completed!'
          : 'Booking Cancelled';

      await Notification.create({
        user: booking.customer,
        type:
          status === 'confirmed'
            ? 'booking_confirmed'
            : status === 'cancelled'
            ? 'booking_cancelled'
            : 'general',
        title: statusTitle,
        message: `Your booking for ${booking.serviceTitle} is now ${status}.`,
      });
    } catch (notifErr) {
      console.warn('Could not create customer status notification:', notifErr.message);
    }

    const populated = await Booking.findById(booking._id)
      .populate('customer', 'name email phone')
      .populate('provider', 'name email phone');

    return sendSuccess(res, `Booking marked as ${status}.`, { booking: populated });
  } catch (error) {
    return sendError(res, `Failed to update booking status: ${error.message}`, 500);
  }
};

// Submit rating and review
const submitReview = async (req, res) => {
  try {
    const { rating, reviewComment } = req.body;

    if (!rating || rating < 1 || rating > 5) {
      return sendError(res, 'Rating must be between 1 and 5 stars.', 400);
    }

    const booking = await Booking.findById(req.params.id);
    if (!booking) {
      return sendError(res, 'Booking not found.', 404);
    }

    if (booking.customer.toString() !== req.user._id.toString()) {
      return sendError(res, 'Only the customer who booked can submit a review.', 403);
    }

    booking.rating = rating;
    booking.reviewComment = reviewComment || '';
    await booking.save();

    // Recalculate provider average rating
    const providerBookings = await Booking.find({
      provider: booking.provider,
      rating: { $exists: true, $ne: null },
    });

    if (providerBookings.length > 0) {
      const avg =
        providerBookings.reduce((sum, b) => sum + b.rating, 0) / providerBookings.length;
      await ProviderProfile.findOneAndUpdate(
        { user: booking.provider },
        {
          rating: Number(avg.toFixed(1)),
          reviewCount: providerBookings.length,
        }
      );
    }

    return sendSuccess(res, 'Review submitted successfully.', { booking });
  } catch (error) {
    return sendError(res, `Failed to submit review: ${error.message}`, 500);
  }
};

module.exports = {
  createBooking,
  getCustomerBookings,
  getProviderBookings,
  updateBookingStatus,
  submitReview,
};
