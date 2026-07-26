import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'fcm_service.dart';

class FirebaseNotificationService {
  FirebaseNotificationService._();

  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'penggilingan_channel',
    'Penggilingan Notification',
    description: 'Notifikasi aplikasi penggilingan bumbu',
    importance: Importance.high,
  );

  static Future<void> initialize() async {
    if (!Platform.isAndroid && !Platform.isIOS) {
      return;
    }

    // ===========================
    // Permission Notification
    // ===========================
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    debugPrint("Notification Permission : ${settings.authorizationStatus}");

    // ===========================
    // Local Notification
    // ===========================
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: androidSettings);

    await _localNotifications.initialize(initializationSettings);

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_channel);

    // ===========================
    // Kirim Token ke Laravel
    // ===========================
    await _sendCurrentToken();

    // ===========================
    // Token Refresh
    // ===========================
    _messaging.onTokenRefresh.listen((token) async {
      debugPrint("FCM TOKEN REFRESH");
      debugPrint(token);

      await _sendToken(token);
    });

    // ===========================
    // Foreground Notification
    // ===========================
    FirebaseMessaging.onMessage.listen((message) async {
      debugPrint("========== FOREGROUND ==========");
      debugPrint(message.notification?.title);
      debugPrint(message.notification?.body);

      final notification = message.notification;

      if (notification != null) {
        await _localNotifications.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              _channel.id,
              _channel.name,
              channelDescription: _channel.description,
              importance: Importance.high,
              priority: Priority.high,
              icon: '@mipmap/ic_launcher',
            ),
          ),
        );
      }
    });

    // ===========================
    // Klik Notification
    // ===========================
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      debugPrint("Notification Clicked");
      debugPrint(message.data.toString());
    });

    // ===========================
    // App dibuka dari notifikasi
    // ===========================
    RemoteMessage? initialMessage = await _messaging.getInitialMessage();

    if (initialMessage != null) {
      debugPrint("App Open From Notification");
      debugPrint(initialMessage.data.toString());
    }
  }

  // ===================================
  // Ambil Token Pertama
  // ===================================
  static Future<void> _sendCurrentToken() async {
    final token = await _messaging.getToken();

    if (token == null) return;

    debugPrint("===========================");
    debugPrint("FCM TOKEN");
    debugPrint(token);
    debugPrint("===========================");

    try {
      await FcmService().updateToken(token);

      debugPrint("FCM Token berhasil dikirim ke Laravel");
    } catch (e) {
      debugPrint("Gagal mengirim token");
      debugPrint(e.toString());
    }
  }

  // ===================================
  // Refresh Token
  // ===================================
  static Future<void> _sendToken(String token) async {
    try {
      await FcmService().updateToken(token);

      debugPrint("FCM Token berhasil diperbarui");
    } catch (e) {
      debugPrint("Gagal update token");
      debugPrint(e.toString());
    }
  }
}
