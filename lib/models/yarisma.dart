class Yarisma {
  final int id;
  final String baslik;
  final String? tema;
  final String? aciklama;
  final DateTime bitisTarihi;
  final bool aktif;

  Yarisma({
    required this.id,
    required this.baslik,
    this.tema,
    this.aciklama,
    required this.bitisTarihi,
    required this.aktif,
  });

  factory Yarisma.fromJson(Map<String, dynamic> j) => Yarisma(
        id: j['id'],
        baslik: j['baslik'] ?? '',
        tema: j['tema'],
        aciklama: j['aciklama'],
        bitisTarihi: DateTime.tryParse(j['bitis_tarihi'] ?? '') ?? DateTime.now(),
        aktif: j['aktif'] ?? true,
      );

  bool get bitti => bitisTarihi.isBefore(DateTime.now());
}

class YarismaFotograf {
  final int id;
  final int yarismaId;
  final int kullaniciId;
  final String kullaniciAd;
  final String fotoUrl;
  final String? aciklama;
  final int begeniSayisi;

  YarismaFotograf({
    required this.id,
    required this.yarismaId,
    required this.kullaniciId,
    required this.kullaniciAd,
    required this.fotoUrl,
    this.aciklama,
    required this.begeniSayisi,
  });

  factory YarismaFotograf.fromJson(Map<String, dynamic> j) => YarismaFotograf(
        id: j['id'],
        yarismaId: j['yarisma_id'],
        kullaniciId: j['kullanici_id'],
        kullaniciAd: j['kullanici_ad'] ?? '',
        fotoUrl: j['foto_url'] ?? '',
        aciklama: j['aciklama'],
        begeniSayisi: j['begeni_sayisi'] ?? 0,
      );
}
