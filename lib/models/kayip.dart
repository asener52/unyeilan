class KayipKisi {
  final int id;
  final String adSoyad;
  final int? dogumYili;
  final String? cinsiyet;
  final String? sonGorulmeTarihi;
  final String? sonGorulmeYeri;
  final String? aciklama;
  final String? fotoUrl;
  final String? iletisimNo;
  final String durum;
  final bool aktif;
  final DateTime createdAt;

  KayipKisi({
    required this.id,
    required this.adSoyad,
    this.dogumYili,
    this.cinsiyet,
    this.sonGorulmeTarihi,
    this.sonGorulmeYeri,
    this.aciklama,
    this.fotoUrl,
    this.iletisimNo,
    required this.durum,
    required this.aktif,
    required this.createdAt,
  });

  factory KayipKisi.fromJson(Map<String, dynamic> j) => KayipKisi(
        id: j['id'],
        adSoyad: j['ad_soyad'] ?? '',
        dogumYili: j['dogum_yili'],
        cinsiyet: j['cinsiyet'],
        sonGorulmeTarihi: j['son_gorulme_tarihi'],
        sonGorulmeYeri: j['son_gorulme_yeri'],
        aciklama: j['aciklama'],
        fotoUrl: j['foto_url'],
        iletisimNo: j['iletisim_no'],
        durum: j['durum'] ?? 'Aranıyor',
        aktif: j['aktif'] ?? true,
        createdAt: DateTime.tryParse(j['created_at'] ?? '') ?? DateTime.now(),
      );
}
