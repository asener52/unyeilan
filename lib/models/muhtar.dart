class Muhtar {
  final int id;
  final int? mahalleId;
  final String? mahalleAd;
  final String adSoyad;
  final String? fotoUrl;
  final String? telefon;
  final String? ofisSaatleri;
  final String? gorevBaslangic;
  final bool aktif;

  Muhtar({
    required this.id,
    this.mahalleId,
    this.mahalleAd,
    required this.adSoyad,
    this.fotoUrl,
    this.telefon,
    this.ofisSaatleri,
    this.gorevBaslangic,
    required this.aktif,
  });

  factory Muhtar.fromJson(Map<String, dynamic> j) => Muhtar(
        id: j['id'],
        mahalleId: j['mahalle_id'],
        mahalleAd: j['mahalle_ad'],
        adSoyad: j['ad_soyad'] ?? '',
        fotoUrl: j['foto_url'],
        telefon: j['telefon'],
        ofisSaatleri: j['ofis_saatleri'],
        gorevBaslangic: j['gorev_baslangic'],
        aktif: j['aktif'] ?? true,
      );
}
