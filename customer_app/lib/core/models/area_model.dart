class AreaModel {
  final String id;
  final String areaId;
  final String name;
  final String city;
  final String state;
  final String pincode;
  final bool popular;
  final String description;
  final int providerCount;

  const AreaModel({
    required this.id,
    required this.areaId,
    required this.name,
    required this.city,
    required this.state,
    required this.pincode,
    required this.popular,
    required this.description,
    required this.providerCount,
  });

  factory AreaModel.fromJson(Map<String, dynamic> json) {
    return AreaModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      areaId: json['areaId']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      city: json['city']?.toString() ?? 'Madurai',
      state: json['state']?.toString() ?? 'Tamil Nadu',
      pincode: json['pincode']?.toString() ?? '',
      popular: json['popular'] ?? false,
      description: json['description']?.toString() ?? '',
      providerCount: json['providerCount'] ?? 0,
    );
  }
}
