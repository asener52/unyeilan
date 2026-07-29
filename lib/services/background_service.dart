import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

const _taskName = 'konum_guncelleme';
const _taskTag  = 'io.unye.burada.konum';
const _baseUrl  = 'https://duyuru.unye.bel.tr';

// ─────────────────────────────────────────────────────────────────────────────
// WorkManager callback — release modda tree-shaking'den korunur
// ─────────────────────────────────────────────────────────────────────────────
@pragma('vm:entry-point')
void workmanagerCallbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    try {
      if (taskName != _taskName) return true;

      // 1. Token al
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null || token.isEmpty) return true;

      // 2. Konum servis + izin kontrolü
      final serviceAktif = await Geolocator.isLocationServiceEnabled();
      if (!serviceAktif) return true;

      final perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) return true;

      // 3. Konumu al (kısa timeout — arka plan görevinin süresi sınırlı)
      Position pos;
      try {
        pos = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.medium,
            timeLimit: Duration(seconds: 15),
          ),
        );
      } catch (_) {
        // GPS timeout veya konum alınamadı — sessizce çık
        return true;
      }

      // 4. Backend'e gönder (dart:io — ayrı isolate'da Dio kullanılamaz)
      try {
        final client = HttpClient();
        client.connectionTimeout = const Duration(seconds: 10);
        final request = await client.postUrl(
          Uri.parse('$_baseUrl/api/konum/guncelle'),
        );
        request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
        request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
        request.write(jsonEncode({
          'lat': pos.latitude,
          'lng': pos.longitude,
        }));
        final response = await request.close();
        await response.drain<void>();
        client.close();
      } catch (_) {
        // Ağ hatası — sessizce geç, WorkManager yeniden denemesin
      }
    } catch (e) {
      debugPrint('[BGService] Beklenmeyen hata: $e');
    }
    return true;
  });
}

// ─────────────────────────────────────────────────────────────────────────────
class BackgroundService {
  static final BackgroundService _instance = BackgroundService._();
  factory BackgroundService() => _instance;
  BackgroundService._();

  Future<void> baslat() async {
    await Workmanager().initialize(
      workmanagerCallbackDispatcher,
      isInDebugMode: false,
    );

    // Kaydı başlat — hata olursa uygulama etkilenmesin
    try {
      await Workmanager().registerPeriodicTask(
        _taskTag,
        _taskName,
        tag: _taskTag,
        frequency: const Duration(minutes: 30),
        constraints: Constraints(
          networkType: NetworkType.connected,
          requiresBatteryNotLow: false,
        ),
        existingWorkPolicy: ExistingPeriodicWorkPolicy.replace,
        backoffPolicy: BackoffPolicy.linear,
        backoffPolicyDelay: const Duration(minutes: 5),
        initialDelay: const Duration(minutes: 5),
      );
    } catch (e) {
      debugPrint('[BGService] Görev kaydedilemedi: $e');
    }
  }

  Future<void> durdur() async {
    try {
      await Workmanager().cancelByTag(_taskTag);
    } catch (_) {}
  }
}
