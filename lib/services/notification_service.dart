import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'api_service.dart';

// Arka planda gelen bildirimleri işle (top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await NotificationService().showLocalNotification(
    title: message.notification?.title ?? 'Ünye Belediyesi',
    body: message.notification?.body ?? '',
    payload: message.data['icerik_id'],
  );
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const _channelId = 'unye_ilan_channel';
  static const _channelName = 'Ünye Belediyesi Bildirimleri';

  // Bildirim tıklandığında yönlendirilecek icerik_id
  String? pendingIcerikId;

  Future<void> initialize() async {
    // Android notification channel
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: 'Ünye Belediyesi haber ve duyuru bildirimleri',
      importance: Importance.high,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // Local notifications init
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    await _localNotifications.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
      onDidReceiveNotificationResponse: (details) {
        pendingIcerikId = details.payload;
      },
    );

    // FCM izin iste
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional) {
      // Token al ve backend'e gönder
      await _registerToken();

      // Token yenilenince güncelle
      _fcm.onTokenRefresh.listen((newToken) {
        ApiService().updateFcmToken(newToken);
      });

      // Uygulama açıkken gelen bildirimler
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        showLocalNotification(
          title: message.notification?.title ?? 'Ünye Belediyesi',
          body: message.notification?.body ?? '',
          payload: message.data['icerik_id'],
        );
      });

      // Arka plandan açılan bildirimler
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        pendingIcerikId = message.data['icerik_id'];
      });

      // Uygulama kapalıyken açılan bildirim
      final initial = await _fcm.getInitialMessage();
      if (initial != null) {
        pendingIcerikId = initial.data['icerik_id'];
      }
    }
  }

  Future<void> _registerToken() async {
    try {
      String? token;
      if (Platform.isIOS) {
        token = await _fcm.getAPNSToken();
      }
      token ??= await _fcm.getToken();
      if (token != null) {
        await ApiService().updateFcmToken(token);
      }
    } catch (_) {}
  }

  Future<String?> getToken() async {
    try {
      return await _fcm.getToken();
    } catch (_) {
      return null;
    }
  }

  Future<void> showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: 'Ünye Belediyesi haber ve duyuru bildirimleri',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFF1a56db),
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      const NotificationDetails(android: androidDetails, iOS: iosDetails),
      payload: payload,
    );
  }
}
