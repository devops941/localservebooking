import 'package:flutter/material.dart';

enum BookingStatus { pending, confirmed, inProgress, completed, cancelled }

extension BookingStatusExt on BookingStatus {
  String get label {
    switch (this) {
      case BookingStatus.pending:
        return 'Pending';
      case BookingStatus.confirmed:
        return 'Confirmed';
      case BookingStatus.inProgress:
        return 'In Progress';
      case BookingStatus.completed:
        return 'Completed';
      case BookingStatus.cancelled:
        return 'Cancelled';
    }
  }

  Color get color {
    switch (this) {
      case BookingStatus.pending:
        return const Color(0xFFF59E0B);
      case BookingStatus.confirmed:
        return const Color(0xFF3B82F6);
      case BookingStatus.inProgress:
        return const Color(0xFF8B5CF6);
      case BookingStatus.completed:
        return const Color(0xFF10B981);
      case BookingStatus.cancelled:
        return const Color(0xFFEF4444);
    }
  }

  IconData get icon {
    switch (this) {
      case BookingStatus.pending:
        return Icons.hourglass_empty;
      case BookingStatus.confirmed:
        return Icons.check_circle_outline;
      case BookingStatus.inProgress:
        return Icons.engineering;
      case BookingStatus.completed:
        return Icons.task_alt;
      case BookingStatus.cancelled:
        return Icons.cancel_outlined;
    }
  }

  static BookingStatus fromString(String s) {
    switch (s) {
      case 'confirmed':
        return BookingStatus.confirmed;
      case 'inProgress':
        return BookingStatus.inProgress;
      case 'completed':
        return BookingStatus.completed;
      case 'cancelled':
        return BookingStatus.cancelled;
      default:
        return BookingStatus.pending;
    }
  }
}

class BookingModel {
  final String id;
  final String customerId;
  final String providerId;
  final String providerName;
  final String providerPhone;
  final String serviceTitle;
  final String bookingDate;
  final String timeSlot;
  final BookingStatus status;
  final double totalAmount;
  final String address;
  final String notes;
  final double? rating;
  final String? reviewComment;
  final String paymentStatus;
  final String paymentMethod;
  final String bookingNumber;
  final double? customerLat;
  final double? customerLng;

  const BookingModel({
    required this.id,
    required this.customerId,
    required this.providerId,
    required this.providerName,
    this.providerPhone = '',
    required this.serviceTitle,
    required this.bookingDate,
    required this.timeSlot,
    required this.status,
    required this.totalAmount,
    required this.address,
    required this.notes,
    this.rating,
    this.reviewComment,
    this.paymentStatus = 'pending',
    this.paymentMethod = 'Cash / UPI after service',
    this.bookingNumber = '',
    this.customerLat,
    this.customerLng,
  });

  static String _parseAddress(dynamic addr) {
    if (addr == null) return '';
    if (addr is String) return addr;
    if (addr is Map) {
      final full = addr['fullAddress']?.toString().trim() ?? '';
      final area = addr['area']?.toString().trim() ?? '';
      final city = addr['city']?.toString().trim() ?? '';
      final parts = [full, area, city].where((s) => s.isNotEmpty).toList();
      return parts.join(', ');
    }
    return addr.toString();
  }

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    final rawProvider = json['provider'] ?? json['providerId'];
    final providerMap = rawProvider is Map<String, dynamic> ? rawProvider : <String, dynamic>{};
    final providerUser = providerMap['userId'] is Map ? providerMap['userId'] as Map<String, dynamic> : providerMap;

    final rawCustomer = json['customer'] ?? json['customerId'];
    final customerId = rawCustomer is Map ? (rawCustomer['_id']?.toString() ?? '') : (rawCustomer?.toString() ?? '');

    final rawDate = json['bookingDate']?.toString() ?? '';
    final safeDate = rawDate.length >= 10 ? rawDate.substring(0, 10) : rawDate;

    return BookingModel(
      id: json['_id'] ?? '',
      customerId: customerId,
      providerId: providerMap['_id']?.toString() ?? (rawProvider is String ? rawProvider : ''),
      providerName: providerUser['name']?.toString() ?? providerMap['name']?.toString() ?? '',
      providerPhone: providerUser['phone']?.toString() ?? providerMap['phone']?.toString() ?? '',
      serviceTitle: json['serviceTitle'] ?? '',
      bookingDate: safeDate,
      timeSlot: json['timeSlot'] ?? '',
      status: BookingStatusExt.fromString(json['status'] ?? 'pending'),
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      address: _parseAddress(json['address']),
      notes: json['notes'] ?? '',
      rating: json['rating']?.toDouble(),
      reviewComment: json['reviewComment'],
      paymentStatus: json['paymentStatus'] ?? 'pending',
      paymentMethod: json['paymentMethod'] ?? 'Cash / UPI after service',
      bookingNumber: json['bookingNumber'] ?? '',
      customerLat: (json['customerLocation']?['lat'] as num?)?.toDouble(),
      customerLng: (json['customerLocation']?['lng'] as num?)?.toDouble(),
    );
  }
}
