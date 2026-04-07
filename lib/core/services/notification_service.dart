import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    // 1. Request permissions for iOS/Android 13+
    await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // 2. Initialize local notifications
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();

    await _localNotifications.initialize(
      settings: const InitializationSettings(
          android: androidSettings, iOS: iosSettings),
    );

    // 3. Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 4. Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showLocalNotification(message);
    });
  }

  Future<String?> getToken() async {
    return await _fcm.getToken();
  }

  Future<void> subscribeToTopic(String topic) async {
    await _fcm.subscribeToTopic(topic);
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    await _fcm.unsubscribeFromTopic(topic);
  }

  void _showLocalNotification(RemoteMessage message) {
    final notification = message.notification;

    if (notification != null && !kIsWeb) {
      _localNotifications.show(
        id: notification.hashCode,
        title: notification.title,
        body: notification.body,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'High Importance Notifications',
            importance: Importance.max,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
      );
    }
  }
}

// Global background handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    // Handle background message logic
    // In production, you would initialize local notifications and show them
    final notification = message.notification;

    if (notification != null) {
      // Log the notification for debugging
      print('Background notification received: ${notification.title}');
      print('Body: ${notification.body}');

      // You can perform additional background tasks here:
      // - Store notification in database
      // - Perform data synchronization
      // - Update local cache
      // - Send analytics

      // Note: To show notifications in background, you need to:
      // 1. Initialize local notifications in background isolate
      // 2. Use FlutterLocalNotificationsPlugin to display
      // For now, we just log it as FCM handles background display on most platforms
    }
  } catch (e) {
    print('Error handling background message: $e');
  }
}
