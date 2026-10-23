import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../models/booking_model.dart';
import '../models/provider_model.dart';
import '../models/user_model.dart';
import 'api_client.dart';

class AdminService extends ChangeNotifier {
  final ApiClient _client = ApiClient();

  Map<String, dynamic> _stats = {};
  List<ProviderModel> _pendingProviders = [];
  List<BookingModel> _bookings = [];
  List<UserModel> _users = [];
  List<Map<String, dynamic>> _categories = [];
  List<Map<String, dynamic>> _monthlyRevenue = [];

  bool _isLoading = false;
  String? _error;

  Map<String, dynamic> get stats => _stats;
  List<ProviderModel> get pendingProviders => _pendingProviders;
  List<BookingModel> get bookings => _bookings;
  List<UserModel> get users => _users;
  List<Map<String, dynamic>> get categories => _categories;
  List<Map<String, dynamic>> get monthlyRevenue => _monthlyRevenue;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  void _setError(String? msg) {
    _error = msg;
    notifyListeners();
  }

  /// GET /admin/analytics/monthly
  Future<void> loadMonthlyRevenue() async {
    try {
      final response = await _client.dio.get('/admin/analytics/monthly');
      final body = response.data as Map<String, dynamic>;
      final data = (body['data'] ?? body) as Map<String, dynamic>;
      final list = (data['monthlyData'] as List<dynamic>?) ?? [];
      _monthlyRevenue = list.cast<Map<String, dynamic>>();
      notifyListeners();
    } catch (_) {
      // non-critical — chart falls back to sample data
    }
  }

  /// GET /admin/stats
  Future<void> loadStats() async {
    _setLoading(true);
    _setError(null);
    try {
      final response = await _client.dio.get('/admin/stats');
      final body = response.data as Map<String, dynamic>;
      final data = (body['data'] ?? body) as Map<String, dynamic>;
      _stats = (data['stats'] as Map<String, dynamic>?) ?? {};
    } on DioException catch (e) {
      _setError(e.response?.data?['message']?.toString() ?? 'Failed to load stats.');
    } catch (e) {
      _setError('Unexpected error: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// GET /admin/providers/pending
  Future<void> loadPendingProviders() async {
    _setLoading(true);
    _setError(null);
    try {
      final response = await _client.dio.get('/admin/providers/pending');
      final body = response.data as Map<String, dynamic>;
      final data = (body['data'] ?? body) as Map<String, dynamic>;
      final list = (data['providers'] as List<dynamic>?) ?? [];
      _pendingProviders = list
          .map((e) => ProviderModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      _setError(e.response?.data?['message']?.toString() ?? 'Failed to load pending providers.');
    } catch (e) {
      _setError('Unexpected error: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// PATCH /admin/providers/:id/approval — approve
  Future<String?> approveProvider(String id) async {
    try {
      await _client.dio.patch(
        '/admin/providers/$id/approval',
        data: {'isVerified': true, 'status': 'active'},
      );
      _pendingProviders.removeWhere((p) => p.id == id);
      notifyListeners();
      return null;
    } on DioException catch (e) {
      return e.response?.data?['message']?.toString() ?? 'Approval failed.';
    } catch (e) {
      return 'Unexpected error: $e';
    }
  }

  /// PATCH /admin/providers/:id/approval — reject
  Future<String?> rejectProvider(String id) async {
    try {
      await _client.dio.patch(
        '/admin/providers/$id/approval',
        data: {'isVerified': false, 'status': 'suspended'},
      );
      _pendingProviders.removeWhere((p) => p.id == id);
      notifyListeners();
      return null;
    } on DioException catch (e) {
      return e.response?.data?['message']?.toString() ?? 'Rejection failed.';
    } catch (e) {
      return 'Unexpected error: $e';
    }
  }

  /// GET /admin/bookings?status=&limit=
  Future<void> loadBookings({String? status, int? limit}) async {
    _setLoading(true);
    _setError(null);
    try {
      final queryParams = <String, dynamic>{};
      if (status != null && status.isNotEmpty && status != 'All') {
        queryParams['status'] = status.toLowerCase();
      }
      if (limit != null) queryParams['limit'] = limit;

      final response = await _client.dio.get(
        '/admin/bookings',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      final body = response.data as Map<String, dynamic>;
      final data = (body['data'] ?? body) as Map<String, dynamic>;
      final list = (data['bookings'] as List<dynamic>?) ?? [];
      _bookings = list
          .map((e) => BookingModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      _setError(e.response?.data?['message']?.toString() ?? 'Failed to load bookings.');
    } catch (e) {
      _setError('Unexpected error: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// GET /users?role=&status=&search=
  Future<void> loadUsers({String? role, String? status, String? search}) async {
    _setLoading(true);
    _setError(null);
    try {
      final queryParams = <String, dynamic>{};
      if (role != null && role.isNotEmpty && role != 'All') {
        queryParams['role'] = role.toLowerCase();
      }
      if (status != null && status.isNotEmpty && status != 'All') {
        queryParams['status'] = status.toLowerCase();
      }
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      final response = await _client.dio.get(
        '/users',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      final body = response.data as Map<String, dynamic>;
      final data = (body['data'] ?? body) as Map<String, dynamic>;
      final list = (data['users'] as List<dynamic>?) ?? [];
      _users = list
          .map((e) => UserModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      _setError(e.response?.data?['message']?.toString() ?? 'Failed to load users.');
    } catch (e) {
      _setError('Unexpected error: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// PUT /users/:id/status
  Future<String?> updateUserStatus(String id, String status) async {
    try {
      await _client.dio.put('/users/$id/status', data: {'status': status});
      final idx = _users.indexWhere((u) => u.id == id);
      if (idx != -1) {
        _users[idx] = UserModel(
          id: _users[idx].id,
          name: _users[idx].name,
          email: _users[idx].email,
          phone: _users[idx].phone,
          role: _users[idx].role,
          status: status,
        );
        notifyListeners();
      }
      return null;
    } on DioException catch (e) {
      return e.response?.data?['message']?.toString() ?? 'Status update failed.';
    } catch (e) {
      return 'Unexpected error: $e';
    }
  }

  /// GET /categories
  Future<void> loadCategories() async {
    _setLoading(true);
    _setError(null);
    try {
      final response = await _client.dio.get('/categories');
      final body = response.data as Map<String, dynamic>;
      final data = (body['data'] ?? body) as Map<String, dynamic>;
      final list = (data['categories'] as List<dynamic>?) ?? [];
      _categories = list.cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      _setError(e.response?.data?['message']?.toString() ?? 'Failed to load categories.');
    } catch (e) {
      _setError('Unexpected error: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// POST /admin/categories
  Future<String?> createCategory({
    required String name,
    required String description,
    required double startingPrice,
  }) async {
    try {
      final response = await _client.dio.post(
        '/admin/categories',
        data: {
          'name': name,
          'description': description,
          'startingPrice': startingPrice,
        },
      );
      final body = response.data as Map<String, dynamic>;
      final data = (body['data'] ?? body) as Map<String, dynamic>;
      final newCat = data['category'] as Map<String, dynamic>?;
      if (newCat != null) {
        _categories.add(newCat);
        notifyListeners();
      } else {
        await loadCategories();
      }
      return null;
    } on DioException catch (e) {
      return e.response?.data?['message']?.toString() ?? 'Failed to create category.';
    } catch (e) {
      return 'Unexpected error: $e';
    }
  }
}
