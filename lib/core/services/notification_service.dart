import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import '../utils/logger.dart';
import 'dart:convert';
import 'package:stayindia_owner/main.dart';
import 'package:stayindia_owner/features/notifications/presentation/pages/notifications_page.dart';
import 'package:stayindia_owner/features/navigation/presentation/pages/main_navigation_page.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  Future<void> init() async {
    
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      requestCriticalPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        AppLogger.info('Notification tapped: ${response.payload}');
        if (response.payload != null) {
          try {
            
            final Map<String, dynamic> data = jsonDecode(response.payload!);
            _handleNotificationTap(data);
          } catch (e) {
            AppLogger.error('Failed to parse notification payload: $e');
          }
        }
      },
    );

    
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      AppLogger.info('Received foreground message: ${message.notification?.title}');
      if (message.notification != null) {
        showNotification(
          id: message.hashCode,
          title: message.notification!.title ?? 'New Notification',
          body: message.notification!.body ?? '',
          payload: jsonEncode(message.data),
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      AppLogger.info('App opened via notification: ${message.data}');
      _handleNotificationTap(message.data);
    });
  }

  void _handleNotificationTap(Map<String, dynamic> data) {
    final String? type = data['type'];
    AppLogger.info('Handling notification tap for type: $type');

    if (navigatorKey.currentState == null) {
      AppLogger.error('Navigator key state is null, cannot navigate');
      return;
    }

    switch (type) {
      case 'SOS_ALERT':
        navigatorKey.currentState?.push(
          MaterialPageRoute(builder: (_) => const NotificationsPage()),
        );
        break;
      case 'BOOKING':
        
        navigatorKey.currentState?.pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const MainNavigationPage(initialIndex: 1)),
          (route) => false,
        );
        break;
      case 'ANNOUNCEMENT':
      case 'NOTICE':
        
        navigatorKey.currentState?.pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const MainNavigationPage(initialIndex: 3)),
          (route) => false,
        );
        break;
      default:
        navigatorKey.currentState?.push(
          MaterialPageRoute(builder: (_) => const NotificationsPage()),
        );
    }
  }

  Future<String?> getToken() async {
    try {
      return await _fcm.getToken();
    } catch (e) {
      AppLogger.error('Failed to get FCM token: $e');
      return null;
    }
  }

  Future<void> requestPermissions() async {
    
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      criticalAlert: true,
    );
    AppLogger.info('User granted permission: ${settings.authorizationStatus}');

    
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();
    }
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'sos_alerts_channel',
      'Emergency Alerts',
      channelDescription: 'High priority emergency and SOS alerts',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      color: Color(0xFFFF0000),
      icon: '@mipmap/ic_launcher',
      enableVibration: true,
      fullScreenIntent: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      interruptionLevel: InterruptionLevel.critical,
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: platformDetails,
      payload: payload,
    );
  }
}
