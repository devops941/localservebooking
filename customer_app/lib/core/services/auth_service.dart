import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import 'api_client.dart';
import '../models/user_model.dart';

class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final ApiClient _api = ApiClient();
  final _storage = const FlutterSecureStorage();

  UserModel? _currentUser;
  bool _isAuthenticated = false;
  bool _isLoading = false;

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;

  Future<void> loadSession() async {
    final token = await _storage.read(key: 'auth_token');
    if (token == null) return;
    try {
      final res = await _api.get('/auth/me');
      final data = res.data as Map<String, dynamic>;
      _currentUser = UserModel.fromJson(
          (data['data'] as Map<String, dynamic>)['user'] as Map<String, dynamic>);
      _isAuthenticated = true;
      notifyListeners();
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        // Token rejected by server — clear it
        await _storage.delete(key: 'auth_token');
      } else {
        // Network / timeout error — token may still be valid, trust it
        _isAuthenticated = true;
        notifyListeners();
      }
    } catch (_) {
      // Unexpected parsing error — keep token for next launch
      _isAuthenticated = true;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      final res = await _api.post('/auth/login', data: {
        'email': email.trim(),
        'password': password,
      });
      final d = res.data['data'];
      await _storage.write(key: 'auth_token', value: d['token']);
      _currentUser = UserModel.fromJson(d['user']);
      _isAuthenticated = true;
      return {'success': true};
    } on DioException catch (e) {
      return {'success': false, 'message': _extractError(e, 'Login failed.')};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final res = await _api.post('/auth/register', data: {
        'name': name.trim(),
        'email': email.trim(),
        'phone': phone.trim(),
        'password': password,
        'role': 'customer',
      });
      final d = res.data['data'];
      await _storage.write(key: 'auth_token', value: d['token']);
      _currentUser = UserModel.fromJson(d['user']);
      _isAuthenticated = true;
      return {'success': true};
    } on DioException catch (e) {
      return {'success': false, 'message': _extractError(e, 'Registration failed.')};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile({required String name, required String phone, String? gender}) async {
    try {
      final data = <String, dynamic>{'name': name, 'phone': phone};
      if (gender != null) data['gender'] = gender;
      final res = await _api.put('/auth/profile', data: data);
      _currentUser = UserModel.fromJson(res.data['data']['user']);
      notifyListeners();
    } catch (_) {}
  }

  Future<Map<String, dynamic>> sendOtp(String email) async {
    try {
      final res = await _api.post('/auth/forgot-password', data: {'email': email.trim()});
      return {'success': true, 'message': res.data['message']};
    } on DioException catch (e) {
      return {'success': false, 'message': _extractError(e, 'Failed to send OTP.')};
    }
  }

  Future<Map<String, dynamic>> verifyOtp(String email, String otp) async {
    try {
      final res = await _api.post('/auth/verify-otp', data: {
        'email': email.trim(),
        'otp': otp.trim(),
      });
      final resetToken = res.data['data']['resetToken'] as String;
      return {'success': true, 'resetToken': resetToken};
    } on DioException catch (e) {
      return {'success': false, 'message': _extractError(e, 'OTP verification failed.')};
    }
  }

  Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String resetToken,
    required String newPassword,
  }) async {
    try {
      await _api.post('/auth/reset-password', data: {
        'email': email.trim(),
        'resetToken': resetToken,
        'newPassword': newPassword,
      });
      return {'success': true};
    } on DioException catch (e) {
      return {'success': false, 'message': _extractError(e, 'Password reset failed.')};
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: 'auth_token');
    _currentUser = null;
    _isAuthenticated = false;
    notifyListeners();
  }

  String _extractError(DioException e, String fallback) {
    if (e.response == null) return 'Cannot connect to server. Make sure backend is running.';
    final data = e.response!.data;
    if (data is Map && data['message'] != null) return data['message'].toString();
    return '$fallback (${e.response!.statusCode})';
  }
}
