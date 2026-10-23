const Booking = require('../models/Booking');
const ProviderProfile = require('../models/ProviderProfile');
const { sendSuccess, sendError } = require('../utils/response');

// GET /api/payments/:bookingId
const getPaymentDetails = async (req, res) => {
  try {
    const booking = await Booking.findById(req.params.bookingId)
      .populate('customer', 'name phone')
      .populate('provider', 'name phone');

    if (!booking) return sendError(res, 'Booking not found.', 404);

    if (
      req.user.role !== 'admin' &&
      booking.customer?._id?.toString() !== req.user._id.toString() &&
      booking.provider?._id?.toString() !== req.user._id.toString()
    ) {
      return sendError(res, 'Unauthorized.', 403);
    }

    const providerProfile = await ProviderProfile.findOne({ user: booking.provider?._id || booking.provider });

    return sendSuccess(res, 'Payment details fetched.', {
      payment: {
        bookingId: booking._id,
        bookingNumber: booking.bookingNumber,
        customerName: booking.customer?.name || 'Customer',
        providerName: booking.provider?.name || 'Provider',
        serviceTitle: booking.serviceTitle,
        amount: booking.totalAmount,
        paymentStatus: booking.paymentStatus,
        paymentMethod: booking.paymentMethod,
        transactionId: booking.transactionId || null,
        paidAt: booking.paidAt || null,
        providerUpiId: providerProfile?.upiId || null,
      },
    });
  } catch (error) {
    return sendError(res, `Failed to fetch payment details: ${error.message}`, 500);
  }
};

// POST /api/payments/:bookingId/cash
const confirmCashPayment = async (req, res) => {
  try {
    const booking = await Booking.findById(req.params.bookingId);
    if (!booking) return sendError(res, 'Booking not found.', 404);

    if (booking.provider.toString() !== req.user._id.toString()) {
      return sendError(res, 'Only the assigned provider can confirm payment.', 403);
    }
    if (booking.status !== 'completed') {
      return sendError(res, 'Payment can only be collected for completed bookings.', 400);
    }
    if (booking.paymentStatus === 'paid') {
      return sendError(res, 'Payment already confirmed for this booking.', 400);
    }

    booking.paymentStatus = 'paid';
    booking.paymentMethod = 'cash';
    booking.paidAt = new Date();
    await booking.save();

    await ProviderProfile.findOneAndUpdate(
      { user: booking.provider },
      { $inc: { totalEarnings: booking.totalAmount } }
    );

    return sendSuccess(res, 'Cash payment confirmed successfully.', {
      paymentStatus: 'paid',
      paymentMethod: 'cash',
      paidAt: booking.paidAt,
    });
  } catch (error) {
    return sendError(res, `Failed to confirm cash payment: ${error.message}`, 500);
  }
};

// POST /api/payments/:bookingId/upi
const confirmUpiPayment = async (req, res) => {
  try {
    const { transactionId } = req.body;
    const booking = await Booking.findById(req.params.bookingId);
    if (!booking) return sendError(res, 'Booking not found.', 404);

    if (booking.provider.toString() !== req.user._id.toString()) {
      return sendError(res, 'Only the assigned provider can confirm payment.', 403);
    }
    if (booking.status !== 'completed') {
      return sendError(res, 'Payment can only be collected for completed bookings.', 400);
    }
    if (booking.paymentStatus === 'paid') {
      return sendError(res, 'Payment already confirmed for this booking.', 400);
    }

    booking.paymentStatus = 'paid';
    booking.paymentMethod = 'upi';
    booking.transactionId = transactionId || '';
    booking.paidAt = new Date();
    await booking.save();

    await ProviderProfile.findOneAndUpdate(
      { user: booking.provider },
      { $inc: { totalEarnings: booking.totalAmount } }
    );

    return sendSuccess(res, 'UPI payment confirmed successfully.', {
      paymentStatus: 'paid',
      paymentMethod: 'upi',
      transactionId: booking.transactionId,
      paidAt: booking.paidAt,
    });
  } catch (error) {
    return sendError(res, `Failed to confirm UPI payment: ${error.message}`, 500);
  }
};

module.exports = { getPaymentDetails, confirmCashPayment, confirmUpiPayment };
