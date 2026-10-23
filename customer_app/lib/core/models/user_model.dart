class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String status;
  final String? gender;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.status,
    this.gender,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['_id'] ?? json['id'] ?? '',
        name: json['name'] ?? '',
        email: json['email'] ?? '',
        phone: json['phone'] ?? '',
        role: json['role'] ?? 'customer',
        status: json['status'] ?? 'active',
        gender: json['gender']?.toString(),
      );

  Map<String, dynamic> toJson() => {
        '_id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'role': role,
        'status': status,
        'gender': gender,
      };

  UserModel copyWith({String? name, String? email, String? phone, String? gender}) => UserModel(
        id: id,
        name: name ?? this.name,
        email: email ?? this.email,
        phone: phone ?? this.phone,
        role: role,
        status: status,
        gender: gender ?? this.gender,
      );
}
