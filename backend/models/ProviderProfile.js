const mongoose = require('mongoose');

const serviceItemSchema = new mongoose.Schema({
  title: {
    type: String,
    required: true,
  },
  price: {
    type: Number,
    required: true,
  },
  duration: {
    type: String,
    default: '1 hr',
  },
  description: {
    type: String,
    default: '',
  },
});

const providerProfileSchema = new mongoose.Schema(
  {
    user: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
      unique: true,
    },
    name: {
      type: String,
      default: '',
    },
    profession: {
      type: String,
      required: [true, 'Profession / Trade title is required'],
      trim: true,
    },
    category: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Category',
    },
    hourlyRate: {
      type: Number,
      required: true,
      default: 249,
    },
    experienceYears: {
      type: Number,
      default: 1,
    },
    bio: {
      type: String,
      default: '',
    },
    upiId: { type: String, default: '' },
    area: {
      type: String,
      required: [true, 'Operating locality / area is required'],
      default: 'Madurai',
    },
    city: {
      type: String,
      default: 'Madurai',
    },
    isAvailable: {
      type: Boolean,
      default: true,
    },
    isVerified: {
      type: Boolean,
      default: false,
    },
    rating: {
      type: Number,
      default: 5.0,
    },
    reviewCount: {
      type: Number,
      default: 0,
    },
    completedJobs: {
      type: Number,
      default: 0,
    },
    totalEarnings: {
      type: Number,
      default: 0,
    },
    totalWithdrawn: {
      type: Number,
      default: 0,
    },
    services: [serviceItemSchema],
  },
  {
    timestamps: true,
  }
);

module.exports = mongoose.model('ProviderProfile', providerProfileSchema);
