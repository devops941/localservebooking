const Booking = require('../models/Booking');
const ProviderProfile = require('../models/ProviderProfile');
const { sendSuccess, sendError } = require('../utils/response');

// POST /api/reviews - Review completed booking (Customer)
const submitReview = async (req, res) => {
  try {
    const { bookingId, rating, reviewComment, comment } = req.body;
    const finalComment = reviewComment || comment || '';

    if (!bookingId) {
      return sendError(res, 'bookingId is required to submit a review.', 400);
    }

    const numRating = Number(rating);
    if (!numRating || numRating < 1 || numRating > 5) {
      return sendError(res, 'Rating must be an integer between 1 and 5.', 400);
    }

    const booking = await Booking.findById(bookingId);
    if (!booking) {
      return sendError(res, 'Booking not found with the provided bookingId.', 404);
    }

    // Role check: Only the customer who booked can submit review
    if (booking.customer.toString() !== req.user._id.toString()) {
      return sendError(res, 'Unauthorized: Only the customer who made this booking can submit a review.', 403);
    }

    // Check if booking is completed
    if (booking.status !== 'completed') {
      return sendError(
        res,
        `Cannot review a booking with status '${booking.status}'. Review can only be posted after job completion.`,
        400
      );
    }

    // Update booking rating and review
    booking.rating = numRating;
    booking.reviewComment = finalComment;
    await booking.save();

    // Recalculate average rating & review count for the provider
    const providerBookings = await Booking.find({
      provider: booking.provider,
      rating: { $exists: true, $ne: null },
    });

    if (providerBookings.length > 0) {
      const avg =
        providerBookings.reduce((sum, b) => sum + (b.rating || 0), 0) / providerBookings.length;
      await ProviderProfile.findOneAndUpdate(
        { user: booking.provider },
        {
          rating: Number(avg.toFixed(1)),
          reviewCount: providerBookings.length,
        }
      );
    }

    const populated = await Booking.findById(booking._id)
      .populate('customer', 'name email phone')
      .populate('provider', 'name email phone');

    return sendSuccess(
      res,
      'Review submitted successfully.',
      {
        review: {
          bookingId: booking._id,
          bookingNumber: booking.bookingNumber,
          rating: booking.rating,
          reviewComment: booking.reviewComment,
          providerId: booking.provider,
          createdAt: new Date(),
        },
        booking: populated,
      },
      201
    );
  } catch (error) {
    return sendError(res, `Failed to submit review: ${error.message}`, 500);
  }
};

module.exports = {
  submitReview,
};
