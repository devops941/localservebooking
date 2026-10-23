/**
 * One-time migration: update all provider profiles that still have
 * city='Chennai' (old schema default) to city='Madurai'.
 *
 * Run from the backend/ directory:
 *   node scripts/fixProviderCity.js
 */

const mongoose = require('mongoose');
const ProviderProfile = require('../models/ProviderProfile');

const MONGO_URI =
  process.env.MONGO_URI || 'mongodb://127.0.0.1:27017/local_service_booking';

async function migrate() {
  await mongoose.connect(MONGO_URI);
  console.log('Connected to MongoDB.');

  const result = await ProviderProfile.updateMany(
    { city: { $in: ['Chennai', 'Adyar', ''] } },
    { $set: { city: 'Madurai' } }
  );

  console.log(
    `Migration complete. Updated ${result.modifiedCount} provider profile(s) to city=Madurai.`
  );

  await mongoose.disconnect();
}

migrate().catch((err) => {
  console.error('Migration failed:', err.message);
  process.exit(1);
});
