import 'package:flutter/material.dart';

enum BookingStatus {
  pending,
  confirmed,
  inProgress,
  completed,
  cancelled;

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
        return Colors.orange;
      case BookingStatus.confirmed:
        return Colors.blue;
      case BookingStatus.inProgress:
        return Colors.teal;
      case BookingStatus.completed:
        return Colors.green;
      case BookingStatus.cancelled:
        return Colors.red;
    }
  }

  String get apiValue {
    switch (this) {
      case BookingStatus.pending:
        return 'pending';
      case BookingStatus.confirmed:
        return 'confirmed';
      case BookingStatus.inProgress:
        return 'inProgress';
      case BookingStatus.completed:
        return 'completed';
      case BookingStatus.cancelled:
        return 'cancelled';
    }
  }

  static BookingStatus fromString(String s) {
    switch (s.toLowerCase()) {
      case 'confirmed':
        return BookingStatus.confirmed;
      case 'inprogress':
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
  final String bookingNumber;
  final String customerId;
  final String customerName;
  final String customerPhone;
  final String serviceTitle;
  final DateTime bookingDate;
  final String timeSlot;
  final BookingStatus status;
  final double totalAmount;
  final String address;
  final String area;
  final String notes;
  final String paymentStatus;
  final String paymentMethod;
  final int? rating;
  final String? reviewComment;

  const BookingModel({
    required this.id,
    this.bookingNumber = '',
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    required this.serviceTitle,
    required this.bookingDate,
    required this.timeSlot,
    required this.status,
    required this.totalAmount,
    required this.address,
    this.area = 'Madurai',
    required this.notes,
    this.paymentStatus = 'pending',
    this.paymentMethod = 'Cash / UPI after service',
    this.rating,
    this.reviewComment,
  });

  static Map<String, String> _parseAddressParts(dynamic addr) {
    if (addr == null) return {'combined': '', 'area': 'Madurai'};
    if (addr is String) {
      final parts = addr.split(',').map((s) => s.trim()).toList();
      final area = parts.length > 1 ? parts[1] : (parts.isNotEmpty ? parts[0] : 'Madurai');
      return {'combined': addr, 'area': area};
    }
    if (addr is Map) {
      final full = addr['fullAddress']?.toString().trim() ?? '';
      final area = addr['area']?.toString().trim() ?? '';
      final city = addr['city']?.toString().trim() ?? 'Madurai';
      final parts = [full, area, city].where((s) => s.isNotEmpty).toList();
      return {
        'combined': parts.join(', '),
        'area': area.isNotEmpty ? area : 'Madurai',
      };
    }
    return {'combined': addr.toString(), 'area': 'Madurai'};
  }

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    String custId = '';
    String custName = 'Customer';
    String custPhone = '';

    final customerData = json['customer'] ?? json['customerId'];
    if (customerData is Map) {
      custId = customerData['_id']?.toString() ?? '';
      final rawName = customerData['name']?.toString().trim() ?? '';
      if (rawName.isNotEmpty) {
        custName = rawName;
      }
      custPhone = customerData['phone']?.toString().trim() ?? '';
    } else if (customerData != null) {
      custId = customerData.toString();
    }

    DateTime bookingDate;
    try {
      bookingDate = DateTime.parse(json['bookingDate'] ?? '');
    } catch (_) {
      bookingDate = DateTime.now();
    }

    final addrParts = _parseAddressParts(json['address']);

    return BookingModel(
      id: json['_id'] ?? '',
      bookingNumber: json['bookingNumber'] ?? '',
      customerId: custId,
      customerName: custName,
      customerPhone: custPhone,
      serviceTitle: json['serviceTitle'] ?? json['service'] ?? 'Service',
      bookingDate: bookingDate,
      timeSlot: json['timeSlot'] ?? '',
      status: BookingStatus.fromString(json['status'] ?? 'pending'),
      totalAmount: (json['totalAmount'] ?? json['amount'] ?? 0).toDouble(),
      address: addrParts['combined'] ?? '',
      area: addrParts['area'] ?? 'Madurai',
      notes: json['notes'] ?? '',
      paymentStatus: json['paymentStatus'] ?? 'pending',
      paymentMethod: json['paymentMethod'] ?? 'Cash / UPI after service',
      rating: (json['rating'] as num?)?.toInt(),
      reviewComment: json['reviewComment']?.toString(),
    );
  }

  BookingModel copyWith({BookingStatus? status, String? paymentStatus, String? paymentMethod}) {
    return BookingModel(
      id: id,
      bookingNumber: bookingNumber,
      customerId: customerId,
      customerName: customerName,
      customerPhone: customerPhone,
      serviceTitle: serviceTitle,
      bookingDate: bookingDate,
      timeSlot: timeSlot,
      status: status ?? this.status,
      totalAmount: totalAmount,
      address: address,
      area: area,
      notes: notes,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      rating: rating,
      reviewComment: reviewComment,
    );
  }
}
