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
        return 'Pending Approval';
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
        return Colors.purple;
      case BookingStatus.completed:
        return Colors.green;
      case BookingStatus.cancelled:
        return Colors.red;
    }
  }

  IconData get icon {
    switch (this) {
      case BookingStatus.pending:
        return Icons.hourglass_top;
      case BookingStatus.confirmed:
        return Icons.check_circle_outline;
      case BookingStatus.inProgress:
        return Icons.build_circle_outlined;
      case BookingStatus.completed:
        return Icons.verified_outlined;
      case BookingStatus.cancelled:
        return Icons.cancel_outlined;
    }
  }
}

class BookingModel {
  final String id;
  final String customerId;
  final String customerName;
  final String customerPhone;
  final String providerId;
  final String providerName;
  final String providerProfession;
  final String serviceCategory;
  final String serviceTitle;
  final DateTime bookingDate;
  final String timeSlot;
  final BookingStatus status;
  final double totalAmount;
  final String address;
  final String notes;
  final double? rating;
  final String? reviewComment;
  final DateTime createdAt;

  BookingModel({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    required this.providerId,
    required this.providerName,
    required this.providerProfession,
    required this.serviceCategory,
    required this.serviceTitle,
    required this.bookingDate,
    required this.timeSlot,
    this.status = BookingStatus.confirmed,
    required this.totalAmount,
    required this.address,
    this.notes = '',
    this.rating,
    this.reviewComment,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  BookingModel copyWith({
    String? id,
    String? customerId,
    String? customerName,
    String? customerPhone,
    String? providerId,
    String? providerName,
    String? providerProfession,
    String? serviceCategory,
    String? serviceTitle,
    DateTime? bookingDate,
    String? timeSlot,
    BookingStatus? status,
    double? totalAmount,
    String? address,
    String? notes,
    double? rating,
    String? reviewComment,
    DateTime? createdAt,
  }) {
    return BookingModel(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      providerId: providerId ?? this.providerId,
      providerName: providerName ?? this.providerName,
      providerProfession: providerProfession ?? this.providerProfession,
      serviceCategory: serviceCategory ?? this.serviceCategory,
      serviceTitle: serviceTitle ?? this.serviceTitle,
      bookingDate: bookingDate ?? this.bookingDate,
      timeSlot: timeSlot ?? this.timeSlot,
      status: status ?? this.status,
      totalAmount: totalAmount ?? this.totalAmount,
      address: address ?? this.address,
      notes: notes ?? this.notes,
      rating: rating ?? this.rating,
      reviewComment: reviewComment ?? this.reviewComment,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  static List<BookingModel> get mockBookings => [
        BookingModel(
          id: 'BK-1082',
          customerId: 'cust_001',
          customerName: 'Karthik Raja',
          customerPhone: '+91 98765 43210',
          providerId: 'prov_01',
          providerName: 'Suresh Kumar',
          providerProfession: 'Certified Electrician',
          serviceCategory: 'Electrician',
          serviceTitle: 'General Electrical Inspection & Repair',
          bookingDate: DateTime.now().add(const Duration(days: 1)),
          timeSlot: '10:00 AM - 11:30 AM',
          status: BookingStatus.confirmed,
          totalAmount: 249.0,
          address: 'Plot No. 42, 2nd Cross Street, Gandhi Nagar, Adyar, Chennai - 600020',
          notes: 'Living room light flickers and one socket is sparking.',
        ),
        BookingModel(
          id: 'BK-1075',
          customerId: 'cust_001',
          customerName: 'Karthik Raja',
          customerPhone: '+91 98765 43210',
          providerId: 'prov_04',
          providerName: 'Arun Cool Care',
          providerProfession: 'HVAC & AC Technician',
          serviceCategory: 'AC Repair',
          serviceTitle: 'Foam Jet AC Wet Servicing',
          bookingDate: DateTime.now().subtract(const Duration(days: 3)),
          timeSlot: '02:00 PM - 03:30 PM',
          status: BookingStatus.completed,
          totalAmount: 449.0,
          address: 'Plot No. 42, 2nd Cross Street, Gandhi Nagar, Adyar, Chennai - 600020',
          notes: 'Master bedroom AC not cooling properly.',
          rating: 5.0,
          reviewComment: 'Arun did a fantastic job with the foam jet wash! AC is cooling like new now.',
        ),
        BookingModel(
          id: 'BK-1061',
          customerId: 'cust_001',
          customerName: 'Karthik Raja',
          customerPhone: '+91 98765 43210',
          providerId: 'prov_02',
          providerName: 'Muthu Vel',
          providerProfession: 'Master Plumber',
          serviceCategory: 'Plumbing',
          serviceTitle: 'Tap & Shower Leakage Fix',
          bookingDate: DateTime.now().subtract(const Duration(days: 8)),
          timeSlot: '11:00 AM - 12:00 PM',
          status: BookingStatus.completed,
          totalAmount: 249.0,
          address: 'Plot No. 42, 2nd Cross Street, Gandhi Nagar, Adyar, Chennai - 600020',
          notes: 'Shower mixer tap leaking steadily.',
          rating: 4.5,
          reviewComment: 'Arrived promptly and replaced the faulty cartridge quickly.',
        ),
      ];
}
