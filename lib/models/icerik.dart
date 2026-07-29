class Icerik {
  final int id;
  final String baslik;
  final String? ozet;
  final String? icerik;
  final String? kapakResmi;
  final String? kategoriAd;
  final String? kategoriSlug;
  final String? kategoriRenk;
  final String? mahalleAd;
  final bool onemli;
  final bool oneCikan;
  final int goruntulenme;
  final DateTime? yayinTarihi;
  final DateTime createdAt;
  final List<dynamic> medyalar;
  final Map<String, dynamic>? detay;

  Icerik({
    required this.id,
    required this.baslik,
    this.ozet,
    this.icerik,
    this.kapakResmi,
    this.kategoriAd,
    this.kategoriSlug,
    this.kategoriRenk,
    this.mahalleAd,
    required this.onemli,
    required this.oneCikan,
    required this.goruntulenme,
    this.yayinTarihi,
    required this.createdAt,
    this.medyalar = const [],
    this.detay,
  });

  factory Icerik.fromJson(Map<String, dynamic> j) => Icerik(
        id: j['id'],
        baslik: j['baslik'] ?? '',
        ozet: j['ozet'],
        icerik: j['icerik'],
        kapakResmi: j['kapak_resmi'],
        kategoriAd: j['kategori_ad'],
        kategoriSlug: j['kategori_slug'],
        kategoriRenk: j['kategori_renk'],
        mahalleAd: j['mahalle_ad'],
        onemli: j['onemli'] ?? false,
        oneCikan: j['one_cikan'] ?? false,
        goruntulenme: j['goruntulenme'] ?? 0,
        yayinTarihi: j['yayin_tarihi'] != null
            ? DateTime.tryParse(j['yayin_tarihi'])
            : null,
        createdAt: DateTime.tryParse(j['created_at'] ?? '') ?? DateTime.now(),
        medyalar: j['medyalar'] ?? [],
        detay: j['detay'],
      );
}

class IcerikListResponse {
  final List<Icerik> data;
  final int toplam;
  final int sayfa;
  final int toplamSayfa;

  IcerikListResponse({
    required this.data,
    required this.toplam,
    required this.sayfa,
    required this.toplamSayfa,
  });

  factory IcerikListResponse.fromJson(Map<String, dynamic> j) {
    final meta = j['meta'] ?? {};
    return IcerikListResponse(
      data: (j['data'] as List? ?? [])
          .map((e) => Icerik.fromJson(e))
          .toList(),
      toplam: meta['toplam'] ?? 0,
      sayfa: meta['sayfa'] ?? 1,
      toplamSayfa: meta['toplam_sayfa'] ?? 1,
    );
  }
}
