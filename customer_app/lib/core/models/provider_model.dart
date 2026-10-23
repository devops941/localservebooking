class ProviderModel {
  final String id;
  final String userId;
  final String name;
  final String email;
  final String phone;
  final String profession;
  final String categoryId;
  final String categoryName;
  final double rating;
  final int reviewCount;
  final double hourlyRate;
  final int experienceYears;
  final String area;
  final String city;
  final bool isVerified;
  final bool isAvailable;
  final int completedJobs;
  final String bio;

  const ProviderModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.email,
    required this.phone,
    required this.profession,
    required this.categoryId,
    required this.categoryName,
    required this.rating,
    required this.reviewCount,
    required this.hourlyRate,
    required this.experienceYears,
    required this.area,
    required this.city,
    required this.isVerified,
    required this.isAvailable,
    required this.completedJobs,
    required this.bio,
  });

  factory ProviderModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] is Map
        ? json['user'] as Map<String, dynamic>
        : (json['userId'] is Map
            ? json['userId'] as Map<String, dynamic>
            : <String, dynamic>{});

    final rawName = json['name']?.toString() ?? '';
    final userName = user['name']?.toString() ?? '';
    final finalName = rawName.isNotEmpty
        ? rawName
        : (userName.isNotEmpty ? userName : 'Verified Provider');

    final categoryMap = json['category'] is Map ? json['category'] as Map : null;
    final categoryId = categoryMap != null
        ? categoryMap['_id']?.toString() ?? ''
        : json['category']?.toString() ?? '';
    final categoryName = categoryMap != null
        ? categoryMap['name']?.toString() ?? ''
        : json['profession']?.toString() ?? 'General Service';

    return ProviderModel(
      id: json['_id']?.toString() ?? '',
      userId: user['_id']?.toString() ?? json['userId']?.toString() ?? '',
      name: finalName,
      email: user['email']?.toString() ?? json['email']?.toString() ?? '',
      phone: user['phone']?.toString() ?? json['phone']?.toString() ?? '',
      profession: json['profession']?.toString() ?? categoryName,
      categoryId: categoryId,
      categoryName: categoryName,
      rating: (json['rating'] ?? 5.0).toDouble(),
      reviewCount: json['reviewCount'] ?? 0,
      hourlyRate: (json['hourlyRate'] ?? 0).toDouble(),
      experienceYears: json['experienceYears'] ?? 1,
      area: json['area']?.toString() ?? 'Madurai',
      city: json['city']?.toString() ?? 'Madurai',
      isVerified: json['isVerified'] ?? false,
      isAvailable: json['isAvailable'] ?? false,
      completedJobs: json['completedJobs'] ?? 0,
      bio: json['bio']?.toString() ?? '',
    );
  }
}
