class TakasIlan {
  final int id;
  final int kullaniciId;
  final String kullaniciAd;
  final String baslik;
  final String? aciklama;
  final String? fotoUrl;
  final String kategori;
  final String tip; // takas | ver | ara
  final String? iletisim;
  final bool aktif;
  final DateTime createdAt;

  TakasIlan({
    required this.id,
    required this.kullaniciId,
    required this.kullaniciAd,
    required this.baslik,
    this.aciklama,
    this.fotoUrl,
    required this.kategori,
    required this.tip,
    this.iletisim,
    required this.aktif,
    required this.createdAt,
  });

  factory TakasIlan.fromJson(Map<String, dynamic> j) => TakasIlan(
        id: j['id'],
        kullaniciId: j['kullanici_id'],
        kullaniciAd: j['kullanici_ad'] ?? '',
        baslik: j['baslik'] ?? '',
        aciklama: j['aciklama'],
        fotoUrl: j['foto_url'],
        kategori: j['kategori'] ?? 'Diğer',
        tip: j['tip'] ?? 'takas',
        iletisim: j['iletisim'],
        aktif: j['aktif'] ?? true,
        createdAt: DateTime.tryParse(j['created_at'] ?? '') ?? DateTime.now(),
      );

  String get tipAd {
    switch (tip) {
      case 'ver': return 'Veriyor';
      case 'ara': return 'Arıyor';
      default: return 'Takas';
    }
  }
}
