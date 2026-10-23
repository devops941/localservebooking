class AddressModel {
  final String id;
  final String label; // Home, Work, Other
  final String fullAddress;
  final String landmark;
  final String area;
  final String city;
  final String pincode;
  final bool isDefault;

  AddressModel({
    required this.id,
    required this.label,
    required this.fullAddress,
    this.landmark = '',
    required this.area,
    required this.city,
    required this.pincode,
    this.isDefault = false,
  });

  AddressModel copyWith({
    String? id,
    String? label,
    String? fullAddress,
    String? landmark,
    String? area,
    String? city,
    String? pincode,
    bool? isDefault,
  }) {
    return AddressModel(
      id: id ?? this.id,
      label: label ?? this.label,
      fullAddress: fullAddress ?? this.fullAddress,
      landmark: landmark ?? this.landmark,
      area: area ?? this.area,
      city: city ?? this.city,
      pincode: pincode ?? this.pincode,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'fullAddress': fullAddress,
      'landmark': landmark,
      'area': area,
      'city': city,
      'pincode': pincode,
      'isDefault': isDefault,
    };
  }

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'] ?? '',
      label: json['label'] ?? 'Home',
      fullAddress: json['fullAddress'] ?? '',
      landmark: json['landmark'] ?? '',
      area: json['area'] ?? '',
      city: json['city'] ?? '',
      pincode: json['pincode'] ?? '',
      isDefault: json['isDefault'] ?? false,
    );
  }
}

class CustomerModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String profileImage;
  final List<AddressModel> addresses;
  final DateTime createdAt;

  CustomerModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.profileImage = '',
    this.addresses = const [],
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  CustomerModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? profileImage,
    List<AddressModel>? addresses,
    DateTime? createdAt,
  }) {
    return CustomerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profileImage: profileImage ?? this.profileImage,
      addresses: addresses ?? this.addresses,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'profileImage': profileImage,
      'addresses': addresses.map((a) => a.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      profileImage: json['profileImage'] ?? '',
      addresses: (json['addresses'] as List<dynamic>?)
              ?.map((a) => AddressModel.fromJson(a as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  static CustomerModel get mockCustomer => CustomerModel(
        id: 'cust_001',
        name: 'Karthik Raja',
        email: 'karthik@example.com',
        phone: '+91 98765 43210',
        profileImage: '',
        addresses: [
          AddressModel(
            id: 'addr_01',
            label: 'Home',
            fullAddress: 'Plot No. 42, 2nd Cross Street, Gandhi Nagar',
            landmark: 'Near Apollo Pharmacy',
            area: 'Adyar',
            city: 'Chennai',
            pincode: '600020',
            isDefault: true,
          ),
          AddressModel(
            id: 'addr_02',
            label: 'Office',
            fullAddress: 'Level 5, Ascendas Tech Park, CSIR Road',
            landmark: 'Next to Tidel Park',
            area: 'Taramani',
            city: 'Chennai',
            pincode: '600113',
            isDefault: false,
          ),
        ],
      );
}
