const Notification = require('../models/Notification');
const { sendSuccess, sendError } = require('../utils/response');

// GET /notifications — fetch all notifications for logged-in user
const getNotifications = async (req, res) => {
  try {
    const notifications = await Notification.find({ user: req.user._id })
      .sort({ createdAt: -1 })
      .limit(50);

    return sendSuccess(res, 'Notifications fetched.', {
      unreadCount: notifications.filter((n) => !n.read).length,
      notifications,
    });
  } catch (error) {
    return sendError(res, `Failed to fetch notifications: ${error.message}`, 500);
  }
};

// PATCH /notifications/:id/read — mark one as read
const markRead = async (req, res) => {
  try {
    await Notification.findOneAndUpdate(
      { _id: req.params.id, user: req.user._id },
      { read: true }
    );
    return sendSuccess(res, 'Notification marked as read.');
  } catch (error) {
    return sendError(res, `Failed to mark notification: ${error.message}`, 500);
  }
};

// PATCH /notifications/read-all — mark all as read
const markAllRead = async (req, res) => {
  try {
    await Notification.updateMany({ user: req.user._id, read: false }, { read: true });
    return sendSuccess(res, 'All notifications marked as read.');
  } catch (error) {
    return sendError(res, `Failed to mark all: ${error.message}`, 500);
  }
};

// POST /notifications/delay — provider sends a delay notification to the customer
const sendDelayNotification = async (req, res) => {
  try {
    const { bookingId, delayMinutes, message } = req.body;
    if (!bookingId || !delayMinutes) {
      return sendError(res, 'bookingId and delayMinutes are required.', 400);
    }
    if (req.user.role !== 'provider') {
      return sendError(res, 'Only providers can send delay notifications.', 403);
    }

    const Booking = require('../models/Booking');
    const booking = await Booking.findById(bookingId)
      .populate('customer', '_id name')
      .populate('provider', '_id');

    if (!booking) return sendError(res, 'Booking not found.', 404);

    // Verify this provider owns this booking (booking.provider is ref: 'User')
    if (booking.provider._id.toString() !== req.user._id.toString()) {
      return sendError(res, 'You are not authorized to notify for this booking.', 403);
    }

    const notifMessage = message?.trim() ||
      `Your service provider is running approximately ${delayMinutes} minute(s) late. Thank you for your patience.`;

    const notification = await Notification.create({
      user: booking.customer._id,
      type: 'delay_notification',
      title: 'Service Delay Update',
      message: notifMessage,
      bookingId: booking._id,
      delayMinutes,
      providerName: req.user.name,
      serviceTitle: booking.serviceTitle,
    });

    // Real-time: emit to the booking room if customers are connected
    if (req.io) {
      req.io.to(`booking:${bookingId}`).emit('delay:notification', {
        bookingId,
        delayMinutes,
        message: notifMessage,
        providerName: req.user.name,
        serviceTitle: booking.serviceTitle,
        createdAt: notification.createdAt,
      });
    }

    return sendSuccess(res, 'Delay notification sent to customer.', { notification });
  } catch (error) {
    return sendError(res, `Failed to send delay notification: ${error.message}`, 500);
  }
};

module.exports = { getNotifications, markRead, markAllRead, sendDelayNotification };
