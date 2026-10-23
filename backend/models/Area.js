const mongoose = require('mongoose');

const areaSchema = new mongoose.Schema(
  {
    name: {
      type: String,
      required: [true, 'Area name is required'],
      trim: true,
    },
    city: {
      type: String,
      required: true,
      default: 'Madurai',
      trim: true,
    },
    state: {
      type: String,
      default: 'Tamil Nadu',
    },
    pincode: {
      type: String,
      default: '',
    },
    isActive: {
      type: Boolean,
      default: true,
    },
    popular: {
      type: Boolean,
      default: true,
    },
    description: {
      type: String,
      default: '',
    },
  },
  {
    timestamps: true,
  }
);

module.exports = mongoose.model('Area', areaSchema);
