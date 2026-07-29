import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/api_service.dart';

import '../services/storage_service.dart';
import '../services/notification_service.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  bool _loading = false;
  String? _error;

  User? get user => _user;
  bool get loading => _loading;
  String? get error => _error;
  bool get isLoggedIn => _user != null;

  Future<void> checkAuth() async {
    final loggedIn = await StorageService.isLoggedIn();
    if (loggedIn) {
      _user = await StorageService.getUser();
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final fcmToken = await NotificationService().getToken();
      final data = await ApiService().login(email, password, fcmToken: fcmToken);
      await _saveSession(data);
      return true;
    } catch (e) {
      _error = _parseError(e);
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> register({
    required String adSoyad,
    required String email,
    required String password,
    required String telefon,
    int? mahalleId,
    bool tumHaberler = true,
    bool kvkkOnay = true,
    bool acikRizaOnay = true,
    String? dogumTarihi,
    String? cinsiyet,
    String? meslek,
    bool engelDurumu = false,
    int? engelOrani,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final fcmToken = await NotificationService().getToken();
      final data = await ApiService().register(
        adSoyad: adSoyad,
        email: email,
        password: password,
        telefon: telefon,
        mahalleId: mahalleId,
        tumHaberler: tumHaberler,
        kvkkOnay: kvkkOnay,
        acikRizaOnay: acikRizaOnay,
        dogumTarihi: dogumTarihi,
        cinsiyet: cinsiyet,
        meslek: meslek,
        engelDurumu: engelDurumu,
        engelOrani: engelOrani,
      );
      await _saveSession(data);
      if (fcmToken != null) await ApiService().updateFcmToken(fcmToken);
      return true;
    } catch (e) {
      _error = _parseError(e);
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile({
    int? mahalleId,
    bool? tumHaberler,
    List<int>? mahalleIds,
  }) async {
    try {
      await ApiService().updateProfile(
        mahalleId: mahalleId,
        tumHaberler: tumHaberler,
        mahalleIds: mahalleIds,
      );
      final updated = await ApiService().getProfile();
      _user = updated;
      await StorageService.saveUser(updated);
      notifyListeners();
    } catch (_) {}
  }

  Future<void> refreshProfile() async {
    try {
      final updated = await ApiService().getProfile();
      _user = updated;
      await StorageService.saveUser(updated);
      notifyListeners();
    } catch (_) {}
  }

  Future<void> logout() async {
    await StorageService.clear();
    _user = null;
    notifyListeners();
  }

  Future<void> _saveSession(Map<String, dynamic> data) async {
    final token = data['access'];
    if (token == null || token is! String) {
      throw Exception('Geçersiz sunucu yanıtı (token alınamadı)');
    }
    await StorageService.saveToken(token);
    _user = User.fromJson(data);
    await StorageService.saveUser(_user!);
  }

  String _parseError(dynamic e) {
    if (e is DioException) {
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return 'Sunucu yanıt vermiyor. Lütfen bekleyin.';
        case DioExceptionType.connectionError:
          return 'Sunucuya bağlanılamadı. İnternet bağlantınızı kontrol edin.';
        case DioExceptionType.badCertificate:
          return 'Güvenli bağlantı kurulamadı. Lütfen tekrar deneyin.';
        case DioExceptionType.badResponse:
          final status = e.response?.statusCode;
          if (status == 401) return 'E-posta veya şifre hatalı';
          if (status == 409) return 'Bu e-posta zaten kayıtlı';
          if (status == 400) {
            final body = e.response?.data;
            final msg = body is Map ? body['message'] ?? body['error'] : null;
            return msg?.toString() ?? 'Geçersiz istek, bilgileri kontrol edin';
          }
          if (status == 500) return 'Sunucu hatası. Lütfen daha sonra deneyin.';
          return 'Sunucu hatası (${status ?? "?"})';
        case DioExceptionType.cancel:
          return 'İstek iptal edildi. Tekrar deneyin.';
        case DioExceptionType.unknown:
          final msg = e.message ?? '';
          if (msg.contains('SocketException') || msg.contains('Connection refused')) {
            return 'Sunucuya bağlanılamadı. İnternet bağlantınızı kontrol edin.';
          }
          debugPrint('Auth DioException.unknown: $e');
          return 'Bağlantı hatası. İnternet bağlantınızı kontrol edip tekrar deneyin.';
        default:
          debugPrint('Auth DioException (${e.type}): $e');
          return 'Bağlantı hatası oluştu. Tekrar deneyin.';
      }
    }
    debugPrint('Auth hatası (${e.runtimeType}): $e');
    return 'Bir hata oluştu: ${e.toString().split('\n').first}';
  }
}
