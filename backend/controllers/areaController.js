const Area = require('../models/Area');
const ProviderProfile = require('../models/ProviderProfile');
const { sendSuccess, sendError } = require('../utils/response');

// Predefined Madurai city localities for database seeding
const MADURAI_AREAS = [
  {
    name: 'Anna Nagar',
    city: 'Madurai',
    state: 'Tamil Nadu',
    pincode: '625020',
    popular: true,
    description: 'Prime residential and commercial locality in East Madurai.',
  },
  {
    name: 'KK Nagar',
    city: 'Madurai',
    state: 'Tamil Nadu',
    pincode: '625020',
    popular: true,
    description: 'Major residential hub near District Court and Apollo Hospital.',
  },
  {
    name: 'Mattuthavani',
    city: 'Madurai',
    state: 'Tamil Nadu',
    pincode: '625007',
    popular: true,
    description: 'Integrated bus terminal hub with high service demand.',
  },
  {
    name: 'Tallakulam',
    city: 'Madurai',
    state: 'Tamil Nadu',
    pincode: '625002',
    popular: true,
    description: 'Central Madurai commercial zone and historical area.',
  },
  {
    name: 'Kalavasal',
    city: 'Madurai',
    state: 'Tamil Nadu',
    pincode: '625016',
    popular: true,
    description: 'Active transit junction connecting Theni main road and residential hubs.',
  },
  {
    name: 'Simmakkal',
    city: 'Madurai',
    state: 'Tamil Nadu',
    pincode: '625001',
    popular: true,
    description: 'Vibrant trade center near Meenakshi Amman Temple.',
  },
  {
    name: 'Goripalayam',
    city: 'Madurai',
    state: 'Tamil Nadu',
    pincode: '625002',
    popular: true,
    description: 'Major junction near Madurai Medical College and Government Hospital.',
  },
  {
    name: 'Arapalayam',
    city: 'Madurai',
    state: 'Tamil Nadu',
    pincode: '625016',
    popular: true,
    description: 'Key transit & residential center in West Madurai.',
  },
  {
    name: 'Teppakulam',
    city: 'Madurai',
    state: 'Tamil Nadu',
    pincode: '625009',
    popular: true,
    description: 'Heritage and residential locality around Vandiyur Mariamman Teppakulam.',
  },
  {
    name: 'Villapuram',
    city: 'Madurai',
    state: 'Tamil Nadu',
    pincode: '625012',
    popular: true,
    description: 'Growing South Madurai residential neighborhood.',
  },
  {
    name: 'Thirunagar',
    city: 'Madurai',
    state: 'Tamil Nadu',
    pincode: '625006',
    popular: false,
    description: 'Peaceful residential suburb along the GST Highway.',
  },
  {
    name: 'Palanganatham',
    city: 'Madurai',
    state: 'Tamil Nadu',
    pincode: '625003',
    popular: false,
    description: 'Strategic junction connecting Madurai railway and southern bypass.',
  },
  {
    name: 'Iyer Bungalow',
    city: 'Madurai',
    state: 'Tamil Nadu',
    pincode: '625014',
    popular: false,
    description: 'Prominent residential zone in North Madurai.',
  },
  {
    name: 'Kochadai',
    city: 'Madurai',
    state: 'Tamil Nadu',
    pincode: '625016',
    popular: false,
    description: 'Residential belt on the Madurai-Theni highway.',
  },
  {
    name: 'Sellur',
    city: 'Madurai',
    state: 'Tamil Nadu',
    pincode: '625002',
    popular: false,
    description: 'Active commercial and residential zone north of Vaigai river.',
  },
  {
    name: 'Bypass Road',
    city: 'Madurai',
    state: 'Tamil Nadu',
    pincode: '625010',
    popular: true,
    description: 'Commercial artery connecting prime Madurai shopping and business centers.',
  },
];

// Seed Madurai areas into MongoDB if not present
const seedMaduraiAreasIfEmpty = async () => {
  try {
    const count = await Area.countDocuments({ city: 'Madurai' });
    if (count === 0) {
      await Area.insertMany(MADURAI_AREAS);
      console.log('✅ Seeded Madurai areas into MongoDB collection');
    }
  } catch (error) {
    console.error('Error seeding Madurai areas:', error.message);
  }
};

// GET /api/areas - Fetch Madurai areas from MongoDB
const getAreas = async (req, res) => {
  try {
    // Ensure Madurai areas exist in MongoDB
    await seedMaduraiAreasIfEmpty();

    const { city, search, popularOnly } = req.query;

    // Filter strictly for Madurai city as required
    const targetCity = city ? new RegExp(`^${city}$`, 'i') : new RegExp('^Madurai$', 'i');
    const query = {
      city: targetCity,
      isActive: true,
    };

    if (popularOnly === 'true') {
      query.popular = true;
    }

    if (search && search.trim() !== '') {
      const q = search.trim();
      query.$or = [
        { name: { $regex: q, $options: 'i' } },
        { pincode: { $regex: q, $options: 'i' } },
        { description: { $regex: q, $options: 'i' } },
      ];
    }

    const areasFromDb = await Area.find(query).sort({ popular: -1, name: 1 });

    // Fetch active and verified providers from MongoDB to calculate real provider count per area
    const activeProviders = await ProviderProfile.find({
      isVerified: true,
      isAvailable: true,
      city: new RegExp('^Madurai$', 'i'),
    }).populate('user', 'status');

    // Only count providers whose user status is 'active'
    const validProviders = activeProviders.filter(
      (p) => p.user && p.user.status === 'active'
    );

    const areasWithCounts = areasFromDb.map((areaDoc) => {
      const areaName = areaDoc.name.toLowerCase();
      const count = validProviders.filter((p) => {
        const pArea = (p.area || '').toLowerCase();
        return pArea.includes(areaName);
      }).length;

      return {
        id: areaDoc._id.toString(),
        areaId: `area-${areaDoc.name.toLowerCase().replace(/\s+/g, '')}`,
        name: areaDoc.name,
        city: areaDoc.city,
        state: areaDoc.state,
        pincode: areaDoc.pincode,
        isActive: areaDoc.isActive,
        popular: areaDoc.popular,
        description: areaDoc.description,
        providerCount: count,
      };
    });

    return sendSuccess(res, 'Madurai areas retrieved from MongoDB successfully.', {
      count: areasWithCounts.length,
      city: 'Madurai',
      areas: areasWithCounts,
    });
  } catch (error) {
    return sendError(res, `Failed to fetch areas from MongoDB: ${error.message}`, 500);
  }
};

module.exports = {
  getAreas,
  MADURAI_AREAS,
};
