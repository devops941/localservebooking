import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import '../models/user_model.dart';
import '../models/provider_profile_model.dart';
import 'api_client.dart';

class AuthService extends ChangeNotifier {
  final _storage = const FlutterSecureStorage();
  final _api = ApiClient();

  UserModel? _currentUser;
  ProviderProfileModel? _providerProfile;
  bool _isAuthenticated = false;
  bool _cachedIsVerified = false;
  String? _errorMessage;

  // Unread KYC approval notification (shown once, then cleared)
  String? _pendingNotificationTitle;
  String? _pendingNotificationMessage;

  UserModel? get currentUser => _currentUser;
  ProviderProfileModel? get providerProfile => _providerProfile;
  bool get isAuthenticated => _isAuthenticated;
  // True if profile says verified OR cached flag says verified (used on network error)
  bool get isProviderVerified => _providerProfile?.isVerified ?? _cachedIsVerified;
  String? get errorMessage => _errorMessage;
  String? get pendingNotificationTitle => _pendingNotificationTitle;
  String? get pendingNotificationMessage => _pendingNotificationMessage;

  void clearPendingNotification() {
    _pendingNotificationTitle = null;
    _pendingNotificationMessage = null;
    notifyListeners();
  }

  // Unwrap backend envelope: { success, message, data: {...} }
  Map<String, dynamic> _unwrap(dynamic responseData) {
    final body = responseData as Map<String, dynamic>;
    return (body['data'] ?? body) as Map<String, dynamic>;
  }

  Future<bool> login(String email, String password) async {
    try {
      _errorMessage = null;
      final response = await _api.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      final data = _unwrap(response.data);
      final token = data['token']?.toString();
      if (token == null) {
        _errorMessage = 'Invalid response from server.';
        notifyListeners();
        return false;
      }

      await _storage.write(key: 'auth_token', value: token);

      _currentUser = UserModel.fromJson(data['user'] as Map<String, dynamic>);
      if (data['providerProfile'] != null) {
        _providerProfile = ProviderProfileModel.fromJson(
            data['providerProfile'] as Map<String, dynamic>);
      }
      _isAuthenticated = true;
      notifyListeners();
      return true;
    } on DioException catch (e) {
      _errorMessage =
          e.response?.data?['message'] ?? 'Login failed. Please try again.';
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    String profession = 'General Service Specialist',
    String area = 'Chennai',
    int experienceYears = 1,
    int hourlyRate = 249,
  }) async {
    try {
      _errorMessage = null;
      final response = await _api.post('/auth/register', data: {
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
        'role': 'provider',
        'profession': profession,
        'area': area,
        'experienceYears': experienceYears,
        'hourlyRate': hourlyRate,
      });

      final data = _unwrap(response.data);
      final token = data['token']?.toString();
      if (token != null) {
        await _storage.write(key: 'auth_token', value: token);
        _currentUser =
            UserModel.fromJson(data['user'] as Map<String, dynamic>);
        _isAuthenticated = true;
        notifyListeners();
      }
      return true;
    } on DioException catch (e) {
      _errorMessage = e.response?.data?['message'] ??
          'Registration failed. Please try again.';
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred.';
      notifyListeners();
      return false;
    }
  }

  Future<void> loadSession() async {
    final token = await _storage.read(key: 'auth_token');
    if (token == null) {
      _isAuthenticated = false;
      notifyListeners();
      return;
    }

    try {
      final response = await _api.get('/auth/me');
      final data = _unwrap(response.data);
      _currentUser = UserModel.fromJson(data['user'] as Map<String, dynamic>);
      if (data['providerProfile'] != null) {
        _providerProfile = ProviderProfileModel.fromJson(
            data['providerProfile'] as Map<String, dynamic>);
        // Cache verification status so offline launches still route correctly
        _cachedIsVerified = _providerProfile!.isVerified;
        await _storage.write(
            key: 'provider_verified', value: _cachedIsVerified.toString());
      }
      _isAuthenticated = true;
      await _checkKycNotification();
      notifyListeners();
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        // Token rejected by server — clear everything
        await _storage.delete(key: 'auth_token');
        await _storage.delete(key: 'provider_verified');
        _isAuthenticated = false;
      } else {
        // Network / timeout error — trust the stored token
        final cached = await _storage.read(key: 'provider_verified');
        _cachedIsVerified = cached == 'true';
        _isAuthenticated = true;
      }
      notifyListeners();
    } catch (_) {
      // Unexpected parsing error — keep token for next launch
      final cached = await _storage.read(key: 'provider_verified');
      _cachedIsVerified = cached == 'true';
      _isAuthenticated = true;
      notifyListeners();
    }
  }

  // Fetches unread KYC notifications and stores them for display
  Future<void> _checkKycNotification() async {
    try {
      final response = await _api.get('/notifications');
      final data = _unwrap(response.data);
      final list = (data['notifications'] as List<dynamic>? ?? []);

      for (final n in list) {
        final notif = n as Map<String, dynamic>;
        if (notif['read'] == false &&
            (notif['type'] == 'kyc_approved' ||
                notif['type'] == 'kyc_rejected')) {
          _pendingNotificationTitle = notif['title']?.toString();
          _pendingNotificationMessage = notif['message']?.toString();
          // Mark it read so it doesn't show again
          final id = notif['_id']?.toString();
          if (id != null) {
            await _api.patch('/notifications/$id/read');
          }
          break;
        }
      }
    } catch (_) {
      // Non-critical — ignore notification fetch errors
    }
  }

  // Lightweight poll — re-fetches /auth/me and updates providerProfile.
  // Returns true if provider just got verified (transition pending→verified).
  Future<bool> refreshProfile() async {
    try {
      final wasVerified = _providerProfile?.isVerified ?? false;
      final response = await _api.get('/auth/me');
      final data = _unwrap(response.data);
      _currentUser =
          UserModel.fromJson(data['user'] as Map<String, dynamic>);
      if (data['providerProfile'] != null) {
        _providerProfile = ProviderProfileModel.fromJson(
            data['providerProfile'] as Map<String, dynamic>);
      }
      final nowVerified = _providerProfile?.isVerified ?? false;
      final justVerified = !wasVerified && nowVerified;
      if (justVerified) {
        await _checkKycNotification();
      }
      notifyListeners();
      return justVerified;
    } catch (_) {
      return false;
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: 'auth_token');
    await _storage.delete(key: 'provider_verified');
    _currentUser = null;
    _providerProfile = null;
    _isAuthenticated = false;
    _cachedIsVerified = false;
    _pendingNotificationTitle = null;
    _pendingNotificationMessage = null;
    notifyListeners();
  }
}
