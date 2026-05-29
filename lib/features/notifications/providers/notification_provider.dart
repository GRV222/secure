import 'dart:async';
import 'package:flutter/material.dart';
import '../../../services/firestore_service.dart';

class NotificationProvider extends ChangeNotifier {
  final FirestoreService _fs = FirestoreService();

  List<Map<String, dynamic>> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  StreamSubscription? _notifSub;
  StreamSubscription? _unreadSub;

  List<Map<String, dynamic>> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;

  void startListening(String uid) {
    _isLoading = true;
    notifyListeners();

    _notifSub?.cancel();
    _notifSub = _fs.getNotifications(uid).listen(
      (list) {
        _notifications = list;
        _isLoading = false;
        notifyListeners();
      },
      onError: (_) {
        _isLoading = false;
        notifyListeners();
      },
    );

    _unreadSub?.cancel();
    _unreadSub = _fs.getUnreadCount(uid).listen(
      (count) {
        _unreadCount = count;
        notifyListeners();
      },
    );
  }

  Future<void> markRead(String id) async {
    try {
      await _fs.markNotificationRead(id);
    } catch (e) {
      debugPrint('NotificationProvider.markRead error: $e');
    }
  }

  Future<void> markAllRead(String uid) async {
    try {
      await _fs.markAllNotificationsRead(uid);
    } catch (e) {
      debugPrint('NotificationProvider.markAllRead error: $e');
    }
  }

  @override
  void dispose() {
    _notifSub?.cancel();
    _unreadSub?.cancel();
    super.dispose();
  }
}
