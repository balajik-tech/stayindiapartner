import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import '../utils/logger.dart';
import 'dart:convert';
import 'package:stayindia_owner/features/notifications/presentation/pages/notifications_page.dart';
import 'package:stayindia_owner/features/navigation/presentation/pages/main_navigation_page.dart';

import 'app_bootstrapper.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final Set<String> _processedDeliveryIds = {};
  static const int _maxCacheSize = 100;

  Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    // Allow iOS to show banners/play sounds even when the app is in the foreground
    await _fcm.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
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
      AppLogger.info(
        'Received foreground message: ${message.notification?.title}',
      );

      final deliveryId = message.data['idempotencyKey'];
      if (deliveryId != null) {
        if (_processedDeliveryIds.contains(deliveryId)) return;
        _processedDeliveryIds.add(deliveryId);
        if (_processedDeliveryIds.length > _maxCacheSize) {
          _processedDeliveryIds.remove(_processedDeliveryIds.first);
        }

        trackInteraction(deliveryId, 'RECEIVED');
        trackInteraction(deliveryId, 'DISPLAYED');
      }

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
      final deliveryId = message.data['idempotencyKey'];
      if (deliveryId != null) {
        trackInteraction(deliveryId, 'OPENED');
        trackInteraction(deliveryId, 'CLICKED');
      }
      _handleNotificationTap(message.data);
    });

    await _handleTerminatedAppNotification();
  }

  Future<void> _handleTerminatedAppNotification() async {
    final RemoteMessage? initial = await _fcm.getInitialMessage();
    if (initial != null) {
      AppLogger.info('Terminated state notification: ${initial.data}');

      Future.delayed(const Duration(milliseconds: 800), () {
        _handleNotificationTap(initial.data);
      });
    }
  }

  Future<void> trackInteraction(String idempotencyKey, String action) async {
    try {
      final getIt = GetIt.instance;
      if (getIt.isRegistered<Dio>()) {
        final dio = getIt<Dio>();
        await dio.post(
          '/notifications/interact',
          data: {'idempotencyKey': idempotencyKey, 'action': action},
        );
      }
    } catch (e) {
      AppLogger.error('Failed to track interaction: $e');
    }
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
      case 'EMERGENCY':
      case 'SECURITY_LOGIN_ALERT':
        navigatorKey.currentState?.push(
          MaterialPageRoute(builder: (_) => const NotificationsPage()),
        );
        break;
      case 'BOOKING':
      case 'BOOKING_CREATED':
      case 'CHECK_IN_REQUEST':
      case 'STAY_EXPIRING':
        navigatorKey.currentState?.pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => const MainNavigationPage(initialIndex: 1),
          ),
          (route) => false,
        );
        break;
      case 'TICKET':
      case 'TICKET_CREATED':
      case 'TICKET_UPDATED':
      case 'TICKET_UPDATE':
      case 'COMPLAINT':
      case 'MAINTENANCE':
        navigatorKey.currentState?.pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => const MainNavigationPage(initialIndex: 2),
          ),
          (route) => false,
        );
        break;
      case 'ANNOUNCEMENT':
      case 'NOTICE':
      case 'GEOFENCE':
      case 'TEMP_LEAVE':
      case 'AWAY_STATUS':
        navigatorKey.currentState?.pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => const MainNavigationPage(initialIndex: 3),
          ),
          (route) => false,
        );
        break;
      case 'GUEST_REQUEST':
      case 'GUEST_STATUS':
        navigatorKey.currentState?.pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => const MainNavigationPage(initialIndex: 0),
          ),
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
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        // Firebase on iOS requires APNs token before generating an FCM token.
        String? apnsToken = await _fcm.getAPNSToken();
        if (apnsToken == null) {
          // Wait briefly for Apple's APNs server handshake
          for (int i = 0; i < 3; i++) {
            await Future.delayed(const Duration(seconds: 1));
            apnsToken = await _fcm.getAPNSToken();
            if (apnsToken != null) break;
          }
        }

        if (apnsToken == null) {
          AppLogger.warning(
            'APNS token not available on iOS yet. Skipping immediate FCM token retrieval.',
          );
          return null;
        }
      }

      final token = await _fcm.getToken();
      if (token != null) {
        AppLogger.info('========================================');
        AppLogger.info('>>> FCM REGISTRATION TOKEN: $token');
        AppLogger.info('========================================');
      }
      return token;
    } catch (e) {
      if (e.toString().contains('apns-token-not-set')) {
        AppLogger.warning('APNS token not ready yet: $e');
      } else {
        AppLogger.error('Failed to get FCM token: $e');
      }
      return null;
    }
  }

  Future<void> requestPermissions() async {
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    AppLogger.info('User granted permission: ${settings.authorizationStatus}');

    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _notificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();

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
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
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
      interruptionLevel: InterruptionLevel.active,
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

  void reset() {
    _processedDeliveryIds.clear();
  }
}
