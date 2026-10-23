class ProviderServiceItem {
  final String id;
  final String title;
  final double price;
  final String duration;
  final String description;

  ProviderServiceItem({
    required this.id,
    required this.title,
    required this.price,
    this.duration = '1 hr',
    this.description = '',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'price': price,
        'duration': duration,
        'description': description,
      };

  factory ProviderServiceItem.fromJson(Map<String, dynamic> json) =>
      ProviderServiceItem(
        id: json['id'] ?? '',
        title: json['title'] ?? '',
        price: (json['price'] as num?)?.toDouble() ?? 0.0,
        duration: json['duration'] ?? '1 hr',
        description: json['description'] ?? '',
      );
}

class ProviderModel {
  final String id;
  final String name;
  final String profession;
  final String categoryId;
  final double rating;
  final int reviewCount;
  final double hourlyRate;
  final int experienceYears;
  final String profileImage;
  final String bio;
  final String area;
  final String city;
  final String phone;
  final List<ProviderServiceItem> services;
  final bool isVerified;
  final int completedJobs;
  final String availability;

  ProviderModel({
    required this.id,
    required this.name,
    required this.profession,
    required this.categoryId,
    this.rating = 4.8,
    this.reviewCount = 50,
    required this.hourlyRate,
    this.experienceYears = 3,
    this.profileImage = '',
    this.bio = '',
    required this.area,
    this.city = 'Chennai',
    required this.phone,
    this.services = const [],
    this.isVerified = true,
    this.completedJobs = 120,
    this.availability = 'Available Today',
  });

  static List<ProviderModel> get mockProviders => [
        ProviderModel(
          id: 'prov_01',
          name: 'Suresh Kumar',
          profession: 'Certified Electrician',
          categoryId: 'cat_electrician',
          rating: 4.9,
          reviewCount: 142,
          hourlyRate: 249.0,
          experienceYears: 7,
          area: 'Adyar',
          city: 'Chennai',
          phone: '+91 98401 23456',
          bio: 'Government certified master electrician with 7+ years of experience in domestic and commercial electrical wiring and fault finding.',
          completedJobs: 380,
          availability: 'Available in 30 mins',
          services: [
            ProviderServiceItem(
              id: 'srv_e1',
              title: 'General Electrical Inspection & Repair',
              price: 249.0,
              duration: '45 mins',
              description: 'Checking short-circuits, switches, sockets and repairing issues.',
            ),
            ProviderServiceItem(
              id: 'srv_e2',
              title: 'Ceiling Fan Installation / Replacement',
              price: 199.0,
              duration: '30 mins',
              description: 'Installation of ceiling fan with regulator connection.',
            ),
            ProviderServiceItem(
              id: 'srv_e3',
              title: 'MCB / Distribution Box Repair',
              price: 349.0,
              duration: '1 hr',
              description: 'Troubleshooting trips, MCB replacement and wire tightening.',
            ),
          ],
        ),
        ProviderModel(
          id: 'prov_02',
          name: 'Muthu Vel',
          profession: 'Master Plumber',
          categoryId: 'cat_plumber',
          rating: 4.8,
          reviewCount: 98,
          hourlyRate: 299.0,
          experienceYears: 6,
          area: 'T. Nagar',
          city: 'Chennai',
          phone: '+91 98402 34567',
          bio: 'Expert plumbing solutions for residential apartments and houses. Specialized in bathroom leaks, motor pumps, and pipeline fittings.',
          completedJobs: 240,
          availability: 'Available Today',
          services: [
            ProviderServiceItem(
              id: 'srv_p1',
              title: 'Tap & Shower Leakage Fix',
              price: 249.0,
              duration: '30 mins',
              description: 'Washer replacement, tap fixture repair or cartridge change.',
            ),
            ProviderServiceItem(
              id: 'srv_p2',
              title: 'Drainage & Pipe Blockage Clearance',
              price: 399.0,
              duration: '1 hr',
              description: 'Clearing sink, washbasin or bathroom drain clog using drain auger.',
            ),
            ProviderServiceItem(
              id: 'srv_p3',
              title: 'Water Motor Pump Servicing',
              price: 499.0,
              duration: '1.5 hrs',
              description: 'Motor check, priming, electrical connection and pipeline test.',
            ),
          ],
        ),
        ProviderModel(
          id: 'prov_03',
          name: 'CleanPro Services (Ramesh)',
          profession: 'Deep Cleaning Specialist',
          categoryId: 'cat_cleaning',
          rating: 4.7,
          reviewCount: 215,
          hourlyRate: 599.0,
          experienceYears: 5,
          area: 'Anna Nagar',
          city: 'Chennai',
          phone: '+91 98403 45678',
          bio: 'Eco-friendly and deep sanitization cleaning using professional grade steam machines and safe solutions.',
          completedJobs: 510,
          availability: 'Slots open tomorrow',
          services: [
            ProviderServiceItem(
              id: 'srv_c1',
              title: 'Full Bathroom Deep Sanitization',
              price: 499.0,
              duration: '1.5 hrs',
              description: 'Tile descaling, floor scrubbing, toilet and sink disinfection.',
            ),
            ProviderServiceItem(
              id: 'srv_c2',
              title: 'Kitchen Deep Degreasing',
              price: 699.0,
              duration: '2 hrs',
              description: 'Chimney surface, gas stove, countertops, cabinets and floor.',
            ),
            ProviderServiceItem(
              id: 'srv_c3',
              title: 'Sofa Shampooing (3 Seater)',
              price: 549.0,
              duration: '1 hr',
              description: 'Dry vacuuming, fabric foam shampoo and moisture extraction.',
            ),
          ],
        ),
        ProviderModel(
          id: 'prov_04',
          name: 'Arun Cool Care',
          profession: 'HVAC & AC Technician',
          categoryId: 'cat_ac',
          rating: 4.9,
          reviewCount: 164,
          hourlyRate: 449.0,
          experienceYears: 8,
          area: 'Velachery',
          city: 'Chennai',
          phone: '+91 98404 56789',
          bio: 'Specialist in split & inverter AC jet pump servicing, coolant gas refilling and PCB repairs for all major brands.',
          completedJobs: 430,
          availability: 'Available in 1 hr',
          services: [
            ProviderServiceItem(
              id: 'srv_a1',
              title: 'Foam Jet AC Wet Servicing',
              price: 449.0,
              duration: '45 mins',
              description: 'Indoor coil jet wash, outdoor unit flush and filter deep clean.',
            ),
            ProviderServiceItem(
              id: 'srv_a2',
              title: 'AC Gas Check & Leakage Detection',
              price: 299.0,
              duration: '30 mins',
              description: 'Pressure check with gauge and nitrogen test if leaking.',
            ),
            ProviderServiceItem(
              id: 'srv_a3',
              title: 'AC Uninstallation / Installation',
              price: 899.0,
              duration: '2 hrs',
              description: 'Complete split AC dismounting or mounting with copper pipe flare.',
            ),
          ],
        ),
        ProviderModel(
          id: 'prov_05',
          name: 'Selvam Woods',
          profession: 'Furniture & Woodcraft Expert',
          categoryId: 'cat_carpentry',
          rating: 4.6,
          reviewCount: 76,
          hourlyRate: 349.0,
          experienceYears: 10,
          area: 'Tambaram',
          city: 'Chennai',
          phone: '+91 98405 67890',
          bio: 'High quality carpentry, door lock installation, hinge repairs, modular shelf assemblies and custom wood work.',
          completedJobs: 190,
          availability: 'Available Today',
          services: [
            ProviderServiceItem(
              id: 'srv_cp1',
              title: 'Door Lock & Handle Fitting',
              price: 299.0,
              duration: '45 mins',
              description: 'Godrej or standard cylindrical lock cutting and fixing.',
            ),
            ProviderServiceItem(
              id: 'srv_cp2',
              title: 'Cupboard Hinge & Channel Repair',
              price: 249.0,
              duration: '30 mins',
              description: 'Hydraulic soft-close hinge replacement and alignment.',
            ),
          ],
        ),
      ];
}
