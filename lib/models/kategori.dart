class Kategori {
  final int id;
  final String ad;
  final String slug;
  final String renk;
  final String? ikon;

  Kategori({
    required this.id,
    required this.ad,
    required this.slug,
    required this.renk,
    this.ikon,
  });

  factory Kategori.fromJson(Map<String, dynamic> j) => Kategori(
        id: j['id'],
        ad: j['ad'],
        slug: j['slug'],
        renk: j['renk'] ?? '#1a56db',
        ikon: j['ikon'],
      );
}
