import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

@pragma('vm:entry-point')
Future<void> _onBackgroundMessage(RemoteMessage message) async {
  debugPrint('Background FCM: ${message.messageId}');
}

class NotificationService {
  static final NotificationService _i = NotificationService._internal();
  factory NotificationService() => _i;
  NotificationService._internal();

  final _fcm = FirebaseMessaging.instance;
  final _localNotif = FlutterLocalNotificationsPlugin();
  final _db = FirebaseFirestore.instance;

  static const _channelId = 'secure_channel';
  static const _channelName = 'SECURE Notifications';

  Future<void> initialize() async {
    try {
      FirebaseMessaging.onBackgroundMessage(_onBackgroundMessage);
      await requestPermission();

      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const initSettings = InitializationSettings(android: androidSettings);
      await _localNotif.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTap,
      );

      const channel = AndroidNotificationChannel(
        _channelId,
        _channelName,
        importance: Importance.high,
      );
      await _localNotif
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      FirebaseMessaging.onMessage.listen(_showLocalNotification);
    } catch (e) {
      debugPrint('NotificationService.initialize error: $e');
    }
  }

  Future<void> requestPermission() async {
    try {
      await _fcm.requestPermission(alert: true, badge: true, sound: true);
    } catch (e) {
      debugPrint('requestPermission error: $e');
    }
  }

  Future<String?> getToken() async {
    try {
      return await _fcm.getToken();
    } catch (e) {
      debugPrint('getToken error: $e');
      return null;
    }
  }

  Future<void> saveTokenToFirestore(String uid) async {
    try {
      final token = await getToken();
      if (token == null) return;
      await _db.collection('users').doc(uid).update({'fcmToken': token});
    } catch (e) {
      debugPrint('saveTokenToFirestore error: $e');
    }
  }

  void _showLocalNotification(RemoteMessage message) {
    final n = message.notification;
    if (n == null) return;
    _localNotif.show(
      n.hashCode,
      n.title,
      n.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
  }

  void _onNotificationTap(NotificationResponse response) {
    // Navigation on tap is handled via getInitialMessage in the app entry
  }

  Future<void> saveNotification({
    required String toUid,
    required String type,
    required String title,
    required String body,
    String? relatedId,
  }) async {
    try {
      await _db.collection('notifications').add({
        'userId': toUid,
        'type': type,
        'title': title,
        'body': body,
        'relatedId': relatedId,
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('saveNotification error: $e');
    }
  }
}
