import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class KonumService {
  static final KonumService _instance = KonumService._();
  factory KonumService() => _instance;
  KonumService._();

  /// Konum iznini kontrol et ve iste. True dönerse izin verildi.
  Future<bool> izinKontrol() async {
    bool servisAktif = await Geolocator.isLocationServiceEnabled();
    if (!servisAktif) return false;

    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    return perm == LocationPermission.always ||
        perm == LocationPermission.whileInUse;
  }

  /// Mevcut konumu al
  Future<Position?> konumAl() async {
    final izin = await izinKontrol();
    if (!izin) return null;
    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
    } catch (e) {
      return null;
    }
  }

  /// Koordinata göre mahalle bul ve subscribe ol
  /// [fcmToken] null olabilir (backend kendi kaydından alır)
  Future<KonumSonuc> konumaGoreMahalleAbone({String? fcmToken}) async {
    final pos = await konumAl();
    if (pos == null) {
      return KonumSonuc(
        basarili: false,
        mesaj: 'Konum alınamadı. Konum servisinin açık olduğundan ve izin verildiğinden emin olun.',
      );
    }

    try {
      final api = ApiService();
      final result = await api.konumSubscribe(
        lat: pos.latitude,
        lng: pos.longitude,
        mod: 'konum',
        fcmToken: fcmToken,
      );

      if (result['success'] == true && result['data'] != null) {
        return KonumSonuc(
          basarili: true,
          mahalleId: result['data']['mahalle_id'],
          mahalleAd: result['data']['mahalle_ad'],
          mesaj: result['mesaj'] ?? 'Mahalle tespit edildi',
        );
      } else {
        return KonumSonuc(
          basarili: false,
          mesaj: result['mesaj'] ?? 'Mahalle tespit edilemedi. Lütfen listeden seçin.',
          konumDisi: true,
        );
      }
    } catch (e) {
      return KonumSonuc(
        basarili: false,
        mesaj: 'Bağlantı hatası: $e',
      );
    }
  }

  /// Arka planda sessiz konum güncellemesi — /api/konum/guncelle çağrısı
  /// Hata olsa da kullanıcıya bir şey göstermez.
  Future<void> sessizKonumGuncelle() async {
    try {
      final izin = await izinKontrol();
      if (!izin) return;
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 8),
        ),
      );
      await ApiService().konumGuncelle(lat: pos.latitude, lng: pos.longitude);
    } catch (_) {}
  }

  /// Konum iznini daha önce sorduk mu?
  Future<bool> izinSorulduMu() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('konum_izin_soruldu') ?? false;
  }

  /// "Soruldu" olarak işaretle
  Future<void> izinSorulduIsaretle() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('konum_izin_soruldu', true);
  }

  /// Listeden seçilen mahalleye subscribe ol
  Future<KonumSonuc> listeyeGoreMahalleAbone(int mahalleId, {String? fcmToken}) async {
    try {
      final api = ApiService();
      final result = await api.konumSubscribe(
        mahalleId: mahalleId,
        mod: 'liste',
        fcmToken: fcmToken,
      );

      if (result['success'] == true) {
        return KonumSonuc(
          basarili: true,
          mahalleId: result['data']['mahalle_id'],
          mahalleAd: result['data']['mahalle_ad'],
          mesaj: result['mesaj'] ?? 'Mahalle seçildi',
        );
      } else {
        return KonumSonuc(basarili: false, mesaj: result['message'] ?? 'Hata');
      }
    } catch (e) {
      return KonumSonuc(basarili: false, mesaj: 'Bağlantı hatası');
    }
  }
}

class KonumSonuc {
  final bool basarili;
  final int? mahalleId;
  final String? mahalleAd;
  final String mesaj;
  final bool konumDisi; // Polygon dışında mı?

  const KonumSonuc({
    required this.basarili,
    this.mahalleId,
    this.mahalleAd,
    required this.mesaj,
    this.konumDisi = false,
  });
}
