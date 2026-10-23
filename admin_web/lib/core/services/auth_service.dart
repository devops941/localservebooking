import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../models/user_model.dart';
import 'api_client.dart';

class AuthService extends ChangeNotifier {
  final ApiClient _client = ApiClient();

  UserModel? _currentUser;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _error;

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Attempt login with email + password. Returns error message or null on success.
  Future<String?> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _client.dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );

      final body = response.data as Map<String, dynamic>;
      final data = (body['data'] ?? body) as Map<String, dynamic>;
      final token = data['token']?.toString();
      final userJson = data['user'] as Map<String, dynamic>?;

      if (token == null || userJson == null) {
        _isLoading = false;
        notifyListeners();
        return 'Invalid response from server.';
      }

      // Verify the user has admin role
      final role = userJson['role']?.toString() ?? '';
      if (role != 'admin') {
        _isLoading = false;
        notifyListeners();
        return 'Access denied. Admin credentials required.';
      }

      await _client.saveToken(token);
      _currentUser = UserModel.fromJson(userJson);
      _isAuthenticated = true;
      _isLoading = false;
      notifyListeners();
      return null;
    } on DioException catch (e) {
      _isLoading = false;
      final msg = e.response?.data?['message']?.toString() ??
          e.response?.data?['error']?.toString() ??
          'Login failed. Check your credentials.';
      _error = msg;
      notifyListeners();
      return msg;
    } catch (e) {
      _isLoading = false;
      _error = 'Unexpected error: $e';
      notifyListeners();
      return _error;
    }
  }

  /// Load session from stored token via GET /auth/me
  Future<bool> loadSession() async {
    final hasToken = await _client.hasToken();
    if (!hasToken) return false;

    try {
      final response = await _client.dio.get('/auth/me');
      final body = response.data as Map<String, dynamic>;
      final data = (body['data'] ?? body) as Map<String, dynamic>;
      final userJson = data['user'] as Map<String, dynamic>?;

      if (userJson == null) return false;

      final role = userJson['role']?.toString() ?? '';
      if (role != 'admin') {
        await _client.clearToken();
        return false;
      }

      _currentUser = UserModel.fromJson(userJson);
      _isAuthenticated = true;
      notifyListeners();
      return true;
    } catch (_) {
      await _client.clearToken();
      return false;
    }
  }

  /// Logout and clear token
  Future<void> logout() async {
    await _client.clearToken();
    _currentUser = null;
    _isAuthenticated = false;
    _error = null;
    notifyListeners();
  }
}
