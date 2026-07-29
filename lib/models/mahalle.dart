class Mahalle {
  final int id;
  final String ad;

  Mahalle({required this.id, required this.ad});

  factory Mahalle.fromJson(Map<String, dynamic> j) =>
      Mahalle(id: j['id'], ad: j['ad']);
}
