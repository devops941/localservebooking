const mongoose = require('mongoose');

const notificationSchema = new mongoose.Schema(
  {
    user: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    type: {
      type: String,
      enum: ['kyc_approved', 'kyc_rejected', 'booking_request', 'booking_confirmed', 'booking_cancelled', 'general', 'delay_notification'],
      default: 'general',
    },
    title: { type: String, required: true },
    message: { type: String, required: true },
    read: { type: Boolean, default: false },
    bookingId: { type: mongoose.Schema.Types.ObjectId, ref: 'Booking' },
    delayMinutes: { type: Number },
    providerName: { type: String },
    serviceTitle: { type: String },
  },
  { timestamps: true }
);

module.exports = mongoose.model('Notification', notificationSchema);
