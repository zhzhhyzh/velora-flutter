import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService extends ChangeNotifier {
  static final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  final List<Map<String, dynamic>> _notifications = [];

  static Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('ic_stat_logo');

    const DarwinInitializationSettings initializationSettingsIOS =
    DarwinInitializationSettings();

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);

    if (Platform.isAndroid) {
      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    } else if (Platform.isIOS) {
      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  // 🟡 UNREAD COUNTER MANAGEMENT
  int _unreadCount = 0;

  int get unreadCount => _unreadCount;

  List<Map<String, dynamic>> get notifications => List.unmodifiable(_notifications);

  void incrementUnread() {
    _unreadCount++;
    notifyListeners();
  }

  void setUnreadCount(int count) {
    _unreadCount = count;
    notifyListeners();
  }

  void clearUnread() {
    _unreadCount = 0;
    notifyListeners();
  }

  void addNotification(Map<String, dynamic> notification) {
    _notifications.add(notification);
    if (notification['isRead'] == false) {
      _unreadCount++;
      notifyListeners();
    }
  }

  void updateNotificationStatus(String id, bool isRead) {
    final index = _notifications.indexWhere((n) => n['id'] == id);
    if (index != -1) {
      final currentStatus = _notifications[index]['isRead'];
      if (currentStatus != isRead) {
        _notifications[index]['isRead'] = isRead;

        if (isRead && _unreadCount > 0) {
          _unreadCount--;
        } else if (!isRead) {
          _unreadCount++;
        }

        notifyListeners();
      }
    }
  }

  // 🟢 SHOW SYSTEM NOTIFICATION
  static Future<void> showNotification({
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'velora_channel_id',
      'Velora Notifications',
      channelDescription: 'Notifications about job updates and applications',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      enableLights: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      notificationDetails,
    );
  }
}
