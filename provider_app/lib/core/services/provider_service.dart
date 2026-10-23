import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../models/booking_model.dart';
import 'api_client.dart';

class ProviderService extends ChangeNotifier {
  final _api = ApiClient();

  Map<String, dynamic> _stats = {};
  List<BookingModel> _bookings = [];
  List<Map<String, dynamic>> _notifications = [];
  int _unreadNotifications = 0;
  bool _isLoading = false;
  String? _errorMessage;
  bool _hasNewRequestAlert = false;
  Timer? _pollingTimer;

  Map<String, dynamic> get stats => _stats;
  List<BookingModel> get bookings => _bookings;
  List<Map<String, dynamic>> get notifications => _notifications;
  int get unreadNotifications => _unreadNotifications;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasNewRequestAlert => _hasNewRequestAlert;

  void clearNewRequestAlert() {
    _hasNewRequestAlert = false;
    notifyListeners();
  }

  void startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 12), (_) {
      loadBookings(silent: true);
      loadNotifications();
    });
  }

  void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  Future<void> loadStats() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final response = await _api.get('/providers/me/stats');
      final resData = response.data;
      if (resData is Map && resData['data'] is Map) {
        _stats = Map<String, dynamic>.from(resData['data']);
      } else if (resData is Map) {
        _stats = Map<String, dynamic>.from(resData);
      }
    } on DioException catch (e) {
      _errorMessage = e.response?.data?['message'] ?? 'Failed to load stats.';
    } catch (e) {
      _errorMessage = 'An unexpected error occurred.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> toggleAvailability(bool isAvailable) async {
    try {
      await _api.patch('/providers/me/availability', data: {'isAvailable': isAvailable});
      _stats['isAvailable'] = isAvailable;
      notifyListeners();
      return true;
    } on DioException catch (e) {
      _errorMessage = e.response?.data?['message'] ?? 'Failed to update availability.';
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred.';
      notifyListeners();
      return false;
    }
  }

  Future<void> loadBookings({bool silent = false}) async {
    try {
      if (!silent) {
        _isLoading = true;
        _errorMessage = null;
        notifyListeners();
      }

      final prevPendingCount = getIncomingRequests().length;

      final response = await _api.get('/provider/bookings');
      final resData = response.data;
      final rawList = (resData is Map && resData['data'] is Map && resData['data']['bookings'] is List)
          ? resData['data']['bookings'] as List
          : ((resData is Map && resData['bookings'] is List) ? resData['bookings'] as List : []);

      _bookings = rawList
          .map((b) => BookingModel.fromJson(b as Map<String, dynamic>))
          .toList();

      final newPendingCount = getIncomingRequests().length;
      if (newPendingCount > prevPendingCount && prevPendingCount >= 0) {
        _hasNewRequestAlert = true;
      }
    } on DioException catch (e) {
      if (!silent) {
        _errorMessage = e.response?.data?['message'] ?? 'Failed to load bookings.';
      }
    } catch (e) {
      if (!silent) {
        _errorMessage = 'An unexpected error occurred.';
      }
    } finally {
      if (!silent) {
        _isLoading = false;
      }
      notifyListeners();
    }
  }

  Future<void> loadNotifications() async {
    try {
      final res = await _api.get('/notifications');
      final resData = res.data;
      if (resData is Map && resData['data'] is Map) {
        final list = resData['data']['notifications'] as List? ?? [];
        _notifications = list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
        _unreadNotifications = (resData['data']['unreadCount'] as num?)?.toInt() ?? 0;
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> markAllNotificationsRead() async {
    try {
      await _api.patch('/notifications/read-all');
      for (var n in _notifications) {
        n['read'] = true;
      }
      _unreadNotifications = 0;
      notifyListeners();
    } catch (_) {}
  }

  Future<Map<String, dynamic>> withdrawWallet({
    required double amount,
    required String bankName,
    required String accountNumber,
    required String ifscCode,
  }) async {
    try {
      final res = await _api.post('/providers/me/withdraw', data: {
        'amount': amount,
        'bankName': bankName,
        'accountNumber': accountNumber,
        'ifscCode': ifscCode,
      });
      await loadStats();
      return {'success': true, 'message': res.data['message'] ?? 'Withdrawal submitted.'};
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? 'Withdrawal failed. Please try again.';
      return {'success': false, 'message': msg};
    } catch (_) {
      return {'success': false, 'message': 'An unexpected error occurred.'};
    }
  }

  Future<bool> updateBookingStatus(String bookingId, BookingStatus status) async {
    try {
      await _api.patch('/bookings/$bookingId/status', data: {'status': status.apiValue});
      final index = _bookings.indexWhere((b) => b.id == bookingId);
      if (index != -1) {
        _bookings[index] = _bookings[index].copyWith(status: status);
        notifyListeners();
      }
      await loadStats();
      return true;
    } on DioException catch (e) {
      _errorMessage = e.response?.data?['message'] ?? 'Failed to update booking status.';
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred.';
      notifyListeners();
      return false;
    }
  }

  List<BookingModel> getIncomingRequests() {
    return _bookings.where((b) => b.status == BookingStatus.pending).toList();
  }

  List<BookingModel> getActiveJobs() {
    return _bookings
        .where((b) => b.status == BookingStatus.confirmed || b.status == BookingStatus.inProgress)
        .toList();
  }

  List<BookingModel> getCompletedJobs() {
    return _bookings.where((b) => b.status == BookingStatus.completed).toList();
  }

  List<BookingModel> getReviewedBookings() {
    return _bookings
        .where((b) => b.rating != null && b.rating! > 0)
        .toList();
  }

  Future<Map<String, dynamic>> updateUpiId(String upiId) async {
    try {
      await _api.put('/providers/me', data: {'upiId': upiId.trim()});
      return {'success': true, 'message': 'UPI ID updated successfully.'};
    } on DioException catch (e) {
      return {'success': false, 'message': e.response?.data?['message'] ?? 'Failed to update UPI ID.'};
    } catch (_) {
      return {'success': false, 'message': 'An unexpected error occurred.'};
    }
  }

  Future<Map<String, dynamic>> getPaymentDetails(String bookingId) async {
    try {
      final response = await _api.get('/payments/$bookingId');
      final data = response.data;
      if (data is Map && data['data'] is Map) {
        return {'success': true, 'payment': data['data']['payment']};
      }
      return {'success': false, 'message': 'Invalid response'};
    } on DioException catch (e) {
      return {'success': false, 'message': e.response?.data?['message'] ?? 'Failed to fetch payment details.'};
    } catch (_) {
      return {'success': false, 'message': 'An unexpected error occurred.'};
    }
  }

  Future<Map<String, dynamic>> confirmCashPayment(String bookingId) async {
    try {
      final response = await _api.post('/payments/$bookingId/cash');
      final data = response.data;
      final index = _bookings.indexWhere((b) => b.id == bookingId);
      if (index != -1) {
        _bookings[index] = _bookings[index].copyWith(
          paymentStatus: 'paid',
          paymentMethod: 'cash',
        );
        notifyListeners();
      }
      await loadStats();
      return {'success': true, 'message': data['message'] ?? 'Cash payment confirmed.'};
    } on DioException catch (e) {
      return {'success': false, 'message': e.response?.data?['message'] ?? 'Failed to confirm payment.'};
    } catch (_) {
      return {'success': false, 'message': 'An unexpected error occurred.'};
    }
  }

  Future<Map<String, dynamic>> confirmUpiPayment(String bookingId, {String transactionId = ''}) async {
    try {
      final response = await _api.post('/payments/$bookingId/upi', data: {'transactionId': transactionId});
      final data = response.data;
      final index = _bookings.indexWhere((b) => b.id == bookingId);
      if (index != -1) {
        _bookings[index] = _bookings[index].copyWith(
          paymentStatus: 'paid',
          paymentMethod: 'upi',
        );
        notifyListeners();
      }
      await loadStats();
      return {'success': true, 'message': data['message'] ?? 'UPI payment confirmed.'};
    } on DioException catch (e) {
      return {'success': false, 'message': e.response?.data?['message'] ?? 'Failed to confirm payment.'};
    } catch (_) {
      return {'success': false, 'message': 'An unexpected error occurred.'};
    }
  }

  Future<String?> sendDelayNotification({
    required String bookingId,
    required int delayMinutes,
    String? message,
  }) async {
    try {
      final data = <String, dynamic>{
        'bookingId': bookingId,
        'delayMinutes': delayMinutes,
      };
      if (message != null && message.trim().isNotEmpty) {
        data['message'] = message.trim();
      }
      await _api.post('/notifications/delay', data: data);
      return null;
    } on DioException catch (e) {
      return e.response?.data?['message']?.toString() ?? 'Failed to send delay notification.';
    } catch (_) {
      return 'An unexpected error occurred.';
    }
  }

  @override
  void dispose() {
    stopPolling();
    super.dispose();
  }
}
