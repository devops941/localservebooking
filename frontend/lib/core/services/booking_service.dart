import 'package:flutter/material.dart';
import '../models/booking_model.dart';

class BookingService extends ChangeNotifier {
  static final BookingService _instance = BookingService._internal();
  factory BookingService() => _instance;
  BookingService._internal();

  final List<BookingModel> _bookings = List.from(BookingModel.mockBookings);

  List<BookingModel> get bookings => List.unmodifiable(_bookings);

  List<BookingModel> getUpcomingBookings() {
    return _bookings
        .where((b) =>
            b.status == BookingStatus.confirmed ||
            b.status == BookingStatus.pending ||
            b.status == BookingStatus.inProgress)
        .toList();
  }

  List<BookingModel> getCompletedBookings() {
    return _bookings.where((b) => b.status == BookingStatus.completed).toList();
  }

  List<BookingModel> getCancelledBookings() {
    return _bookings.where((b) => b.status == BookingStatus.cancelled).toList();
  }

  BookingModel? getBookingById(String id) {
    try {
      return _bookings.firstWhere((b) => b.id == id);
    } catch (_) {
      return null;
    }
  }

  BookingModel createBooking({
    required String customerId,
    required String customerName,
    required String customerPhone,
    required String providerId,
    required String providerName,
    required String providerProfession,
    required String serviceCategory,
    required String serviceTitle,
    required DateTime bookingDate,
    required String timeSlot,
    required double totalAmount,
    required String address,
    String notes = '',
  }) {
    final newBooking = BookingModel(
      id: 'BK-${1090 + _bookings.length}',
      customerId: customerId,
      customerName: customerName,
      customerPhone: customerPhone,
      providerId: providerId,
      providerName: providerName,
      providerProfession: providerProfession,
      serviceCategory: serviceCategory,
      serviceTitle: serviceTitle,
      bookingDate: bookingDate,
      timeSlot: timeSlot,
      status: BookingStatus.confirmed,
      totalAmount: totalAmount,
      address: address,
      notes: notes,
    );

    _bookings.insert(0, newBooking);
    notifyListeners();
    return newBooking;
  }

  bool cancelBooking(String bookingId) {
    final index = _bookings.indexWhere((b) => b.id == bookingId);
    if (index != -1) {
      _bookings[index] = _bookings[index].copyWith(status: BookingStatus.cancelled);
      notifyListeners();
      return true;
    }
    return false;
  }

  bool submitReview(String bookingId, double rating, String comment) {
    final index = _bookings.indexWhere((b) => b.id == bookingId);
    if (index != -1) {
      _bookings[index] = _bookings[index].copyWith(
        rating: rating,
        reviewComment: comment,
      );
      notifyListeners();
      return true;
    }
    return false;
  }
}
