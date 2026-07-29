class MahalleAbonelik {
  final int mahalleId;
  final String mahalleAd;

  MahalleAbonelik({required this.mahalleId, required this.mahalleAd});

  factory MahalleAbonelik.fromJson(Map<String, dynamic> j) => MahalleAbonelik(
        mahalleId: j['mahalle_id'],
        mahalleAd: j['mahalle_ad'] ?? '',
      );
}

class User {
  final int id;
  final String adSoyad;
  final String email;
  final String? telefon;
  final int? mahalleId;
  final String? mahalleAd;
  final bool tumHaberler;
  final String? profilResmi;
  final List<MahalleAbonelik> mahalleAbonelikleri;
  final String? dogumTarihi;
  final String? cinsiyet;
  final String? meslek;
  final bool engelDurumu;
  final int? engelOrani;

  User({
    required this.id,
    required this.adSoyad,
    required this.email,
    this.telefon,
    this.mahalleId,
    this.mahalleAd,
    required this.tumHaberler,
    this.profilResmi,
    this.mahalleAbonelikleri = const [],
    this.dogumTarihi,
    this.cinsiyet,
    this.meslek,
    this.engelDurumu = false,
    this.engelOrani,
  });

  factory User.fromJson(Map<String, dynamic> j) => User(
        id: j['id'],
        adSoyad: j['ad_soyad'] ?? '',
        email: j['email'] ?? '',
        telefon: j['telefon'],
        mahalleId: j['mahalle_id'],
        mahalleAd: j['mahalle_ad'],
        tumHaberler: j['tum_haberler'] ?? true,
        profilResmi: j['profil_resmi'],
        mahalleAbonelikleri: (j['mahalle_abonelikleri'] as List? ?? [])
            .map((e) => MahalleAbonelik.fromJson(e))
            .toList(),
        dogumTarihi: j['dogum_tarihi'],
        cinsiyet: j['cinsiyet'],
        meslek: j['meslek'],
        engelDurumu: j['engel_durumu'] ?? false,
        engelOrani: j['engel_orani'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'ad_soyad': adSoyad,
        'email': email,
        'telefon': telefon,
        'mahalle_id': mahalleId,
        'mahalle_ad': mahalleAd,
        'tum_haberler': tumHaberler,
        'profil_resmi': profilResmi,
        'mahalle_abonelikleri': mahalleAbonelikleri
            .map((e) => {'mahalle_id': e.mahalleId, 'mahalle_ad': e.mahalleAd})
            .toList(),
        'dogum_tarihi': dogumTarihi,
        'cinsiyet': cinsiyet,
        'meslek': meslek,
        'engel_durumu': engelDurumu,
        'engel_orani': engelOrani,
      };

  List<int> get abonelikIds => mahalleAbonelikleri.map((e) => e.mahalleId).toList();
}
