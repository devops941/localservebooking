import 'package:flutter/material.dart';

class BookingModel {
  final String id;
  final String customerName;
  final String providerName;
  final String serviceTitle;
  final DateTime bookingDate;
  final String timeSlot;
  final String status;
  final double totalAmount;
  final String address;
  final int? rating;
  final String? reviewComment;

  BookingModel({
    required this.id,
    required this.customerName,
    required this.providerName,
    required this.serviceTitle,
    required this.bookingDate,
    required this.timeSlot,
    required this.status,
    required this.totalAmount,
    required this.address,
    this.rating,
    this.reviewComment,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    // Handle populated customer object or plain string
    String customerName = '';
    final customer = json['customer'];
    if (customer is Map<String, dynamic>) {
      customerName = customer['name']?.toString() ?? '';
    } else if (customer is String) {
      customerName = customer;
    }

    // Handle populated provider object (User doc) or plain string
    String providerName = '';
    final provider = json['provider'];
    if (provider is Map<String, dynamic>) {
      providerName = provider['name']?.toString() ?? '';
    } else if (provider is String) {
      providerName = provider;
    }

    // Handle date parsing
    DateTime bookingDate;
    try {
      bookingDate = DateTime.parse(json['bookingDate']?.toString() ?? '');
    } catch (_) {
      bookingDate = DateTime.now();
    }

    return BookingModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      customerName: customerName,
      providerName: providerName,
      serviceTitle: json['serviceTitle']?.toString() ??
          json['service']?.toString() ?? '',
      bookingDate: bookingDate,
      timeSlot: json['timeSlot']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      address: json['address']?.toString() ?? '',
      rating: (json['rating'] as num?)?.toInt(),
      reviewComment: json['reviewComment']?.toString(),
    );
  }

  Color get statusColor {
    switch (status.toLowerCase()) {
      case 'confirmed':
      case 'active':
        return const Color(0xFF1E88E5);
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.redAccent;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
