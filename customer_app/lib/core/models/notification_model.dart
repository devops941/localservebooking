class NotificationModel {
  final String id;
  final String type;
  final String title;
  final String message;
  final bool read;
  final DateTime createdAt;
  final String? bookingId;
  final int? delayMinutes;
  final String? providerName;
  final String? serviceTitle;

  const NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.read,
    required this.createdAt,
    this.bookingId,
    this.delayMinutes,
    this.providerName,
    this.serviceTitle,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['_id']?.toString() ?? '',
      type: json['type']?.toString() ?? 'general',
      title: json['title']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      read: json['read'] == true,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      bookingId: json['bookingId']?.toString(),
      delayMinutes: (json['delayMinutes'] as num?)?.toInt(),
      providerName: json['providerName']?.toString(),
      serviceTitle: json['serviceTitle']?.toString(),
    );
  }

  NotificationModel copyWith({bool? read}) {
    return NotificationModel(
      id: id,
      type: type,
      title: title,
      message: message,
      read: read ?? this.read,
      createdAt: createdAt,
      bookingId: bookingId,
      delayMinutes: delayMinutes,
      providerName: providerName,
      serviceTitle: serviceTitle,
    );
  }
}
