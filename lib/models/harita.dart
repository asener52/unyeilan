class HaritaKategori {
  final int id;
  final String ad;
  final String ikon;
  final String renk;

  HaritaKategori({required this.id, required this.ad, required this.ikon, required this.renk});

  factory HaritaKategori.fromJson(Map<String, dynamic> j) => HaritaKategori(
        id: j['id'],
        ad: j['ad'] ?? '',
        ikon: j['ikon'] ?? 'place',
        renk: j['renk'] ?? '#1A56DB',
      );
}

class HaritaNokta {
  final int id;
  final int? kategoriId;
  final String ad;
  final String? aciklama;
  final String? adres;
  final double lat;
  final double lng;
  final String? telefon;
  final String? webSitesi;
  final String? kategoriAd;
  final String? kategoriIkon;
  final String? kategoriRenk;

  HaritaNokta({
    required this.id,
    this.kategoriId,
    required this.ad,
    this.aciklama,
    this.adres,
    required this.lat,
    required this.lng,
    this.telefon,
    this.webSitesi,
    this.kategoriAd,
    this.kategoriIkon,
    this.kategoriRenk,
  });

  factory HaritaNokta.fromJson(Map<String, dynamic> j) => HaritaNokta(
        id: j['id'],
        kategoriId: j['kategori_id'],
        ad: j['ad'] ?? '',
        aciklama: j['aciklama'],
        adres: j['adres'],
        lat: double.tryParse(j['lat'].toString()) ?? 0,
        lng: double.tryParse(j['lng'].toString()) ?? 0,
        telefon: j['telefon'],
        webSitesi: j['web_sitesi'],
        kategoriAd: j['kategori_ad'],
        kategoriIkon: j['kategori_ikon'],
        kategoriRenk: j['kategori_renk'],
      );
}
