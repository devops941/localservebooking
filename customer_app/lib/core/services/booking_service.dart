import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'api_client.dart';
import '../models/booking_model.dart';

class BookingService extends ChangeNotifier {
  final ApiClient _api = ApiClient();
  List<BookingModel> _bookings = [];
  bool _isLoading = false;

  List<BookingModel> get bookings => _bookings;
  bool get isLoading => _isLoading;

  List<BookingModel> get upcoming => _bookings
      .where((b) =>
          b.status == BookingStatus.pending ||
          b.status == BookingStatus.confirmed ||
          b.status == BookingStatus.inProgress)
      .toList();

  List<BookingModel> get completed =>
      _bookings.where((b) => b.status == BookingStatus.completed).toList();

  List<BookingModel> get cancelled =>
      _bookings.where((b) => b.status == BookingStatus.cancelled).toList();

  BookingModel? getBookingById(String id) {
    try {
      return _bookings.firstWhere((b) => b.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> loadBookings() async {
    _isLoading = true;
    notifyListeners();
    try {
      final res = await _api.get('/bookings/mine');
      final List data = (res.data['data']?['bookings']) ?? [];
      _bookings = data
          .map((e) => BookingModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      _bookings = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> createBooking({
    required String providerId,
    required String serviceTitle,
    String? categoryName,
    required String bookingDate,
    required String timeSlot,
    required dynamic address,
    required double totalAmount,
    String notes = '',
    double? customerLat,
    double? customerLng,
  }) async {
    try {
      final res = await _api.post('/bookings', data: {
        'providerId': providerId,
        'serviceTitle': serviceTitle,
        if (categoryName != null) 'categoryName': categoryName,
        'bookingDate': bookingDate,
        'timeSlot': timeSlot,
        'address': address,
        'totalAmount': totalAmount,
        'notes': notes,
        if (customerLat != null) 'customerLat': customerLat,
        if (customerLng != null) 'customerLng': customerLng,
      });
      final booking = BookingModel.fromJson(
          res.data['data']['booking'] as Map<String, dynamic>);
      _bookings.insert(0, booking);
      notifyListeners();
      return {'success': true, 'booking': booking};
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data?['message'] ?? 'Booking failed',
      };
    }
  }

  Future<bool> cancelBooking(String bookingId) async {
    try {
      await _api.patch('/bookings/$bookingId/status', data: {'status': 'cancelled'});
      final idx = _bookings.indexWhere((b) => b.id == bookingId);
      if (idx != -1) {
        final b = _bookings[idx];
        _bookings[idx] = BookingModel(
          id: b.id,
          customerId: b.customerId,
          providerId: b.providerId,
          providerName: b.providerName,
          serviceTitle: b.serviceTitle,
          bookingDate: b.bookingDate,
          timeSlot: b.timeSlot,
          status: BookingStatus.cancelled,
          totalAmount: b.totalAmount,
          address: b.address,
          notes: b.notes,
        );
        notifyListeners();
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<Map<String, dynamic>> submitReview(
    String bookingId,
    double rating,
    String comment,
  ) async {
    try {
      await _api.post('/bookings/$bookingId/review', data: {
        'rating': rating,
        'reviewComment': comment,
      });
      // Refresh the booking to reflect the new rating
      final idx = _bookings.indexWhere((b) => b.id == bookingId);
      if (idx != -1) {
        final b = _bookings[idx];
        _bookings[idx] = BookingModel(
          id: b.id,
          customerId: b.customerId,
          providerId: b.providerId,
          providerName: b.providerName,
          serviceTitle: b.serviceTitle,
          bookingDate: b.bookingDate,
          timeSlot: b.timeSlot,
          status: b.status,
          totalAmount: b.totalAmount,
          address: b.address,
          notes: b.notes,
          rating: rating,
          reviewComment: comment,
        );
        notifyListeners();
      }
      return {'success': true};
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Review failed',
      };
    }
  }
}
