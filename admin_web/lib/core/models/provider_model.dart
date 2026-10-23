class ProviderModel {
  final String id;
  final String userId;
  final String name;
  final String email;
  final String phone;
  final String profession;
  final String area;
  final String city;
  final double hourlyRate;
  final int experienceYears;
  final bool isVerified;
  final String status;
  final double rating;
  final int completedJobs;
  final DateTime? createdAt;

  ProviderModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.email,
    required this.phone,
    required this.profession,
    required this.area,
    required this.city,
    required this.hourlyRate,
    required this.experienceYears,
    required this.isVerified,
    required this.status,
    required this.rating,
    required this.completedJobs,
    this.createdAt,
  });

  factory ProviderModel.fromJson(Map<String, dynamic> json) {
    // Backend populates 'user' field via .populate('user', 'name email phone status createdAt')
    String uid = '';
    String uName = '';
    String uEmail = '';
    String uPhone = '';
    String uStatus = 'pending';
    DateTime? uCreatedAt;
    final userField = json['user'];
    if (userField is Map<String, dynamic>) {
      uid = userField['_id']?.toString() ?? '';
      uName = userField['name']?.toString() ?? '';
      uEmail = userField['email']?.toString() ?? '';
      uPhone = userField['phone']?.toString() ?? '';
      uStatus = userField['status']?.toString() ?? 'pending';
      final raw = userField['createdAt']?.toString();
      if (raw != null) uCreatedAt = DateTime.tryParse(raw);
    } else if (userField is String) {
      uid = userField;
    }

    return ProviderModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      userId: uid,
      name: uName,
      email: uEmail,
      phone: uPhone,
      profession: json['profession']?.toString() ?? '',
      area: json['area']?.toString() ?? json['location']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      hourlyRate: (json['hourlyRate'] as num?)?.toDouble() ?? 0.0,
      experienceYears: (json['experienceYears'] as num?)?.toInt() ?? 0,
      isVerified: json['isVerified'] == true,
      status: uStatus,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      completedJobs: (json['completedJobs'] as num?)?.toInt() ?? 0,
      createdAt: uCreatedAt,
    );
  }
}
