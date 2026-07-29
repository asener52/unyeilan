class DileceSablon {
  final int id;
  final String baslik;
  final String kategori;
  final String icerik;
  final bool aktif;

  DileceSablon({
    required this.id,
    required this.baslik,
    required this.kategori,
    required this.icerik,
    required this.aktif,
  });

  factory DileceSablon.fromJson(Map<String, dynamic> j) => DileceSablon(
        id: j['id'],
        baslik: j['baslik'] ?? '',
        kategori: j['kategori'] ?? 'Genel',
        icerik: j['icerik'] ?? '',
        aktif: j['aktif'] ?? true,
      );
}
