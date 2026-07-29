class Eczane {
  final int id;
  final String ad;
  final String? adres;
  final String? telefon;
  final double? lat;
  final double? lng;
  final String tarih;
  final String? bitisTarihi;
  final bool aktif;

  Eczane({
    required this.id,
    required this.ad,
    this.adres,
    this.telefon,
    this.lat,
    this.lng,
    required this.tarih,
    this.bitisTarihi,
    required this.aktif,
  });

  factory Eczane.fromJson(Map<String, dynamic> j) => Eczane(
        id: j['id'],
        ad: j['ad'] ?? '',
        adres: j['adres'],
        telefon: j['telefon'],
        lat: j['lat'] != null ? double.tryParse(j['lat'].toString()) : null,
        lng: j['lng'] != null ? double.tryParse(j['lng'].toString()) : null,
        tarih: j['tarih'] ?? '',
        bitisTarihi: j['bitis_tarihi'],
        aktif: j['aktif'] ?? true,
      );
}
