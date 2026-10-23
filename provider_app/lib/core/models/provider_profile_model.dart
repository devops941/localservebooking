class ProviderProfileModel {
  final String id;
  final String profession;
  final String categoryId;
  final double hourlyRate;
  final int experienceYears;
  final String area;
  final String city;
  final bool isVerified;
  final bool isAvailable;
  final double rating;
  final int reviewCount;
  final int completedJobs;
  final String bio;
  final double walletBalance;
  final String upiId;

  const ProviderProfileModel({
    required this.id,
    required this.profession,
    required this.categoryId,
    required this.hourlyRate,
    required this.experienceYears,
    required this.area,
    required this.city,
    required this.isVerified,
    required this.isAvailable,
    required this.rating,
    required this.reviewCount,
    required this.completedJobs,
    required this.bio,
    required this.walletBalance,
    this.upiId = '',
  });

  factory ProviderProfileModel.fromJson(Map<String, dynamic> json) {
    final catId = json['category'] is Map
        ? json['category']['_id'] ?? ''
        : json['category']?.toString() ?? '';
    return ProviderProfileModel(
      id: json['_id'] ?? '',
      profession: json['profession'] ?? '',
      categoryId: catId,
      hourlyRate: (json['hourlyRate'] ?? 0).toDouble(),
      experienceYears: json['experienceYears'] ?? 0,
      area: json['area'] ?? '',
      city: json['city'] ?? '',
      isVerified: json['isVerified'] ?? false,
      isAvailable: json['isAvailable'] ?? false,
      rating: (json['rating'] ?? 0).toDouble(),
      reviewCount: json['reviewCount'] ?? 0,
      completedJobs: json['completedJobs'] ?? 0,
      bio: json['bio'] ?? '',
      walletBalance: (json['walletBalance'] ?? 0).toDouble(),
      upiId: json['upiId'] ?? '',
    );
  }
}
