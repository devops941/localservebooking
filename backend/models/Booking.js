const mongoose = require('mongoose');

const bookingSchema = new mongoose.Schema(
  {
    bookingNumber: {
      type: String,
      unique: true,
    },
    customer: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },
    provider: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },
    serviceTitle: {
      type: String,
      required: true,
    },
    categoryName: {
      type: String,
      default: 'General Service',
    },
    bookingDate: {
      type: Date,
      required: true,
    },
    timeSlot: {
      type: String,
      required: true,
    },
    status: {
      type: String,
      enum: ['pending', 'confirmed', 'inProgress', 'completed', 'cancelled'],
      default: 'pending',
    },
    totalAmount: {
      type: Number,
      required: true,
    },
    commissionFee: {
      type: Number,
      default: 0,
    },
    paymentStatus: {
      type: String,
      enum: ['pending', 'paid', 'refunded'],
      default: 'pending',
    },
    paymentMethod: {
      type: String,
      default: 'Cash / UPI after service',
    },
    transactionId: { type: String, default: '' },
    paidAt: { type: Date },
    address: {
      fullAddress: { type: String, required: true },
      landmark: { type: String, default: '' },
      area: { type: String, required: true },
      city: { type: String, default: 'Madurai' },
      pincode: { type: String, default: '' },
    },
    customerLocation: {
      lat: { type: Number, default: null },
      lng: { type: Number, default: null },
    },
    notes: {
      type: String,
      default: '',
    },
    rating: {
      type: Number,
      min: 1,
      max: 5,
    },
    reviewComment: {
      type: String,
      default: '',
    },
    createdAt: {
      type: Date,
      default: Date.now,
    },
  },
  {
    timestamps: true,
  }
);

// Auto generate bookingNumber if missing
bookingSchema.pre('save', function (next) {
  if (!this.bookingNumber) {
    this.bookingNumber = `BK-${Math.floor(1000 + Math.random() * 9000)}`;
  }
  next();
});

module.exports = mongoose.model('Booking', bookingSchema);
