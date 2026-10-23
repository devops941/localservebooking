import 'dart:async';
import 'package:flutter/material.dart';
import 'api_client.dart';
import '../models/notification_model.dart';

class NotificationService extends ChangeNotifier {
  final ApiClient _api = ApiClient();
  List<NotificationModel> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  Timer? _pollingTimer;

  List<NotificationModel> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;

  Future<void> loadNotifications() async {
    _isLoading = true;
    notifyListeners();
    try {
      final res = await _api.get('/notifications');
      final data = res.data['data'];
      _unreadCount = (data?['unreadCount'] as num?)?.toInt() ?? 0;
      final List raw = (data?['notifications']) ?? [];
      _notifications = raw
          .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      _notifications = [];
      _unreadCount = 0;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markRead(String id) async {
    try {
      await _api.patch('/notifications/$id/read');
      final idx = _notifications.indexWhere((n) => n.id == id);
      if (idx != -1 && !_notifications[idx].read) {
        _notifications[idx] = _notifications[idx].copyWith(read: true);
        if (_unreadCount > 0) _unreadCount--;
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> markAllRead() async {
    try {
      await _api.patch('/notifications/read-all');
      _notifications = _notifications.map((n) => n.copyWith(read: true)).toList();
      _unreadCount = 0;
      notifyListeners();
    } catch (_) {}
  }

  void startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      loadNotifications();
    });
  }

  void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  @override
  void dispose() {
    stopPolling();
    super.dispose();
  }
}
