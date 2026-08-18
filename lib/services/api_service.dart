import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../config/api_config.dart';
import '../models/icerik.dart';
import '../models/kategori.dart';
import '../models/mahalle.dart';
import '../models/user.dart';
import '../models/eczane.dart';
import '../models/harita.dart';
import '../models/muhtar.dart';
import '../models/kayip.dart';
import '../models/takas.dart';
import '../models/yarisma.dart';
import '../models/dilekce.dart';
import 'storage_service.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  late final Dio _dio;

  // main.dart'taki GlobalKey<NavigatorState> buraya set edilir
  static GlobalKey<NavigatorState>? _navigatorKey;
  static void setNavigatorKey(GlobalKey<NavigatorState> key) {
    _navigatorKey = key;
  }

  ApiService._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: ApiConfig.connectTimeout,
      receiveTimeout: ApiConfig.receiveTimeout,
      headers: {'Content-Type': 'application/json'},
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await StorageService.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) async {
        final status = error.response?.statusCode;
        final isPublicAuth = error.requestOptions.path.contains('/sms/kod-');
        if ((status == 401 || status == 403) && !isPublicAuth) {
          // Token geçersiz veya süresi dolmuş — çıkış yap
          await StorageService.clear();
          // Global navigator ile login ekranına yönlendir
          try {
            // main.dart'taki navigatorKey'i kullan
            final ctx = _navigatorKey?.currentContext;
            if (ctx != null && ctx.mounted) {
              ScaffoldMessenger.of(ctx).showSnackBar(
                const SnackBar(
                  content: Text('Oturumunuz sona erdi. Lütfen tekrar giriş yapın.'),
                  backgroundColor: Colors.red,
                  duration: Duration(seconds: 3),
                ),
              );
            }
            _navigatorKey?.currentState
                ?.pushNamedAndRemoveUntil('/login', (_) => false);
          } catch (_) {}
        }
        return handler.next(error);
      },
    ));
  }

  // --- Auth ---
  Future<Map<String, dynamic>> requestLoginCode(String telefon) async {
    final res = await _dio.post('/sms/kod-gonder', data: {'telefon': telefon});
    return Map<String, dynamic>.from(res.data['data']);
  }

  Future<Map<String, dynamic>> verifyLoginCode(String token, String kod, {String? fcmToken}) async {
    final res = await _dio.post('/sms/kod-dogrula', data: {
      'token': token,
      'kod': kod,
      if (fcmToken != null) 'fcm_token': fcmToken,
    });
    return Map<String, dynamic>.from(res.data['data']);
  }

  Future<void> sendAppFeedback({required int rating, String? comment}) async {
    await _dio.post('/sikayet', data: {
      'kategori': 'uygulama_degerlendirmesi',
      'baslik': 'Uygulama Değerlendirmesi ($rating/5)',
      'aciklama': (comment == null || comment.trim().isEmpty)
          ? 'Kullanıcı uygulamaya $rating yıldız verdi.'
          : comment.trim(),
    });
  }

  Future<Map<String, dynamic>> register({
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
    final res = await _dio.post('/auth/register', data: {
      'ad_soyad': adSoyad,
      'email': email,
      'password': password,
      'telefon': telefon,
      if (mahalleId != null) 'mahalle_id': mahalleId,
      'tum_haberler': tumHaberler,
      'kvkk_onay': kvkkOnay.toString(),
      'acik_riza_onay': acikRizaOnay.toString(),
      if (dogumTarihi != null) 'dogum_tarihi': dogumTarihi,
      if (cinsiyet != null) 'cinsiyet': cinsiyet,
      if (meslek != null) 'meslek': meslek,
      'engel_durumu': engelDurumu.toString(),
      if (engelOrani != null) 'engel_orani': engelOrani,
    });
    return res.data['data'];
  }

  Future<void> updateProfile({
    String? adSoyad,
    String? telefon,
    int? mahalleId,
    bool? tumHaberler,
    List<int>? mahalleIds,
  }) async {
    await _dio.put('/auth/profile', data: {
      if (adSoyad != null) 'ad_soyad': adSoyad,
      if (telefon != null) 'telefon': telefon,
      'mahalle_id': mahalleId,
      if (tumHaberler != null) 'tum_haberler': tumHaberler,
      if (mahalleIds != null) 'mahalle_ids': mahalleIds,
    });
  }

  Future<void> updateFcmToken(String token) async {
    try {
      await _dio.put('/auth/fcm-token', data: {'fcm_token': token});
    } catch (_) {}
  }

  Future<User> getProfile() async {
    final res = await _dio.get('/kullanicilar/me');
    return User.fromJson(res.data['data']);
  }

  // --- İçerikler ---
  Future<IcerikListResponse> getIcerikler({
    String? kategori,
    int? mahalleId,
    int sayfa = 1,
    int limit = 15,
    String? arama,
    bool? onemli,
    bool? oneCikan,
  }) async {
    final res = await _dio.get('/icerikler', queryParameters: {
      if (kategori != null) 'kategori': kategori,
      if (mahalleId != null) 'mahalle_id': mahalleId,
      'sayfa': sayfa,
      'limit': limit,
      if (arama != null) 'arama': arama,
      if (onemli == true) 'onemli': 'true',
      if (oneCikan == true) 'one_cikan': 'true',
    });
    return IcerikListResponse.fromJson(res.data);
  }

  Future<Icerik> getIcerik(int id) async {
    final res = await _dio.get('/icerikler/$id');
    return Icerik.fromJson(res.data['data']);
  }

  // --- Kategoriler ---
  Future<List<Kategori>> getKategoriler() async {
    final res = await _dio.get('/kategoriler');
    return (res.data['data'] as List).map((e) => Kategori.fromJson(e)).toList();
  }

  // --- Mahalleler ---
  Future<List<Mahalle>> getMahalles() async {
    final res = await _dio.get('/mahalles');
    return (res.data['data'] as List).map((e) => Mahalle.fromJson(e)).toList();
  }

  // --- Bildirimler ---
  Future<List<Map<String, dynamic>>> getBildirimler({int sayfa = 1}) async {
    final res = await _dio.get('/bildirimler/me', queryParameters: {'sayfa': sayfa, 'limit': 30});
    return List<Map<String, dynamic>>.from(res.data['data'] ?? []);
  }

  Future<void> bildirimOku(int id) async {
    try {
      await _dio.patch('/bildirimler/me/$id/oku');
    } catch (_) {}
  }

  Future<void> bildirimSil(int id) async {
    await _dio.delete('/bildirimler/me/$id');
  }

  Future<void> bildirimlerTumunuOku() async {
    try { await _dio.patch('/bildirimler/me/tumu/oku'); } catch (_) {}
  }

  Future<List<Map<String, dynamic>>> getKategoriEngelleme() async {
    final res = await _dio.get('/bildirimler/me/kategori-engelleme');
    return List<Map<String, dynamic>>.from(res.data['data'] ?? []);
  }

  Future<void> updateKategoriEngelleme(List<int> kategoriIds) async {
    await _dio.put('/bildirimler/me/kategori-engelleme', data: {'kategori_ids': kategoriIds});
  }

  // --- Eczane ---
  Future<List<Eczane>> getEczaneler({String? tarih}) async {
    final res = await _dio.get('/eczane', queryParameters: {
      if (tarih != null) 'tarih': tarih,
    });
    return (res.data['data'] as List).map((e) => Eczane.fromJson(e)).toList();
  }

  // --- Harita ---
  Future<List<HaritaKategori>> getHaritaKategoriler() async {
    final res = await _dio.get('/harita/kategoriler');
    return (res.data['data'] as List).map((e) => HaritaKategori.fromJson(e)).toList();
  }

  Future<List<HaritaNokta>> getHaritaNoktalar({int? kategoriId}) async {
    final res = await _dio.get('/harita/noktalar', queryParameters: {
      if (kategoriId != null) 'kategori_id': kategoriId,
    });
    return (res.data['data'] as List).map((e) => HaritaNokta.fromJson(e)).toList();
  }

  // --- Muhtar ---
  Future<List<Muhtar>> getMuhtarlar() async {
    final res = await _dio.get('/muhtar');
    return (res.data['data'] as List).map((e) => Muhtar.fromJson(e)).toList();
  }

  // --- Kayıp Kişiler ---
  Future<List<KayipKisi>> getKayipKisiler() async {
    final res = await _dio.get('/kayip');
    return (res.data['data'] as List).map((e) => KayipKisi.fromJson(e)).toList();
  }

  // --- Sohbet ---
  Future<List<Map<String, dynamic>>> getSohbet({int? mahalleId}) async {
    final res = await _dio.get('/sohbet', queryParameters: {
      if (mahalleId != null) 'mahalle_id': mahalleId,
    });
    return List<Map<String, dynamic>>.from(res.data['data'] ?? []);
  }

  Future<void> sendSohbet(String mesaj, {int? mahalleId}) async {
    await _dio.post('/sohbet', data: {
      'mesaj': mesaj,
      if (mahalleId != null) 'mahalle_id': mahalleId,
    });
  }

  // --- Takas ---
  Future<List<TakasIlan>> getTakasIlanlari({String? kategori, String? tip}) async {
    final res = await _dio.get('/takas', queryParameters: {
      if (kategori != null) 'kategori': kategori,
      if (tip != null) 'tip': tip,
    });
    return (res.data['data'] as List).map((e) => TakasIlan.fromJson(e)).toList();
  }

  // --- Yarışma ---
  Future<List<Yarisma>> getYarismallar() async {
    final res = await _dio.get('/yarisma');
    return (res.data['data'] as List).map((e) => Yarisma.fromJson(e)).toList();
  }

  Future<List<YarismaFotograf>> getYarismaFotograflar(int yarismaId) async {
    final res = await _dio.get('/yarisma/$yarismaId/fotograflar');
    return (res.data['data'] as List).map((e) => YarismaFotograf.fromJson(e)).toList();
  }

  Future<void> begenYarismaFoto(int fotoId) async {
    await _dio.post('/yarisma/fotograflar/$fotoId/begen');
  }

  // --- Dilekçe ---
  Future<List<DileceSablon>> getDileceSablonlari({String? kategori}) async {
    final res = await _dio.get('/dilekce', queryParameters: {
      if (kategori != null) 'kategori': kategori,
    });
    return (res.data['data'] as List).map((e) => DileceSablon.fromJson(e)).toList();
  }

  // --- Puan ---
  Future<Map<String, dynamic>> getBenimPuan() async {
    final res = await _dio.get('/puan/benim');
    return res.data['data'];
  }

  // Konum servisi
  Future<Map<String, dynamic>> konumMahalleBul({required double lat, required double lng}) async {
    final res = await _dio.get('/konum/mahalle', queryParameters: {'lat': lat, 'lng': lng});
    return res.data;
  }

  Future<Map<String, dynamic>> konumSubscribe({
    double? lat,
    double? lng,
    int? mahalleId,
    required String mod,
    String? fcmToken,
  }) async {
    final body = <String, dynamic>{'mod': mod};
    if (lat != null) body['lat'] = lat;
    if (lng != null) body['lng'] = lng;
    if (mahalleId != null) body['mahalle_id'] = mahalleId;
    if (fcmToken != null) body['fcm_token'] = fcmToken;
    final res = await _dio.post('/konum/subscribe', data: body);
    return res.data;
  }

  Future<List<dynamic>> getMahalleListesi() async {
    final res = await _dio.get('/konum/mahalles');
    return res.data['data'] ?? [];
  }

  Future<void> konumGuncelle({required double lat, required double lng}) async {
    await _dio.post('/konum/guncelle', data: {'lat': lat, 'lng': lng});
  }

  // --- Acil Numaralar ---
  Future<List<Map<String, dynamic>>> getAcilNumaralar() async {
    final res = await _dio.get('/acil');
    return List<Map<String, dynamic>>.from(res.data['data'] ?? []);
  }

  // --- Şikayet & Talep ---
  Future<List<Map<String, dynamic>>> getBenimSikayetler() async {
    final res = await _dio.get('/sikayet/benim');
    return List<Map<String, dynamic>>.from(res.data['data'] ?? []);
  }

  // --- Randevu ---
  Future<List<Map<String, dynamic>>> getRandevuBirimleri() async {
    final res = await _dio.get('/randevu/birimler');
    return List<Map<String, dynamic>>.from(res.data['data'] ?? []);
  }

  Future<List<Map<String, dynamic>>> getBenimRandevular() async {
    final res = await _dio.get('/randevu/benim');
    return List<Map<String, dynamic>>.from(res.data['data'] ?? []);
  }

  Future<List<String>> getRandevuDoluSaatler({required int birimId, required String tarih}) async {
    final res = await _dio.get('/randevu/dolu-saatler', queryParameters: {'birim_id': birimId, 'tarih': tarih});
    return List<String>.from(res.data['data'] ?? []);
  }

  Future<Map<String, dynamic>> randevuAl({
    required int birimId,
    required String tarih,
    required String saat,
    required String konu,
    String? adSoyad,
    String? telefon,
  }) async {
    final res = await _dio.post('/randevu', data: {
      'birim_id': birimId,
      'tarih': tarih,
      'saat': saat,
      'konu': konu,
      if (adSoyad != null) 'ad_soyad': adSoyad,
      if (telefon != null) 'telefon': telefon,
    });
    return res.data['data'];
  }

  Future<void> randevuIptal(int id) async {
    await _dio.patch('/randevu/$id/iptal');
  }

  // --- Anket ---
  Future<List<Map<String, dynamic>>> getAnketler() async {
    final res = await _dio.get('/anket');
    return List<Map<String, dynamic>>.from(res.data['data'] ?? []);
  }

  Future<List<Map<String, dynamic>>> getBenimOylarim() async {
    final res = await _dio.get('/anket/benim-oylarim');
    return List<Map<String, dynamic>>.from(res.data['data'] ?? []);
  }

  Future<List<Map<String, dynamic>>> anketOyVer({required int anketId, required int secenekId}) async {
    final res = await _dio.post('/anket/$anketId/oy', data: {'secenek_id': secenekId});
    return List<Map<String, dynamic>>.from(res.data['data'] ?? []);
  }

  // --- Tesisler ---
  Future<List<Map<String, dynamic>>> getTesisler({String? kategori}) async {
    final res = await _dio.get('/tesis', queryParameters: {
      if (kategori != null) 'kategori': kategori,
    });
    return List<Map<String, dynamic>>.from(res.data['data'] ?? []);
  }
}
