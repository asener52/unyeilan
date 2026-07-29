import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../services/api_service.dart';
import '../config/api_config.dart';

const _kategoriler = [
  ('', '🏙️', 'Tümü'),
  ('park', '🌳', 'Park'),
  ('spor', '⚽', 'Spor'),
  ('kultur', '🎭', 'Kültür'),
  ('saglik', '🏥', 'Sağlık'),
  ('egitim', '🏫', 'Eğitim'),
  ('belediye', '🏛️', 'Belediye'),
  ('diger', '📋', 'Diğer'),
];

class TesisScreen extends StatefulWidget {
  const TesisScreen({super.key});

  @override
  State<TesisScreen> createState() => _TesisScreenState();
}

class _TesisScreenState extends State<TesisScreen> {
  List<Map<String, dynamic>> _liste = [];
  bool _yukleniyor = true;
  String _seciliKat = '';
  bool _haritaGoster = false;

  @override
  void initState() {
    super.initState();
    _yukle();
  }

  Future<void> _yukle() async {
    setState(() => _yukleniyor = true);
    try {
      final data = await ApiService().getTesisler(kategori: _seciliKat.isEmpty ? null : _seciliKat);
      if (mounted) setState(() { _liste = data; _yukleniyor = false; });
    } catch (_) {
      if (mounted) setState(() => _yukleniyor = false);
    }
  }

  void _kategoriSec(String kat) {
    setState(() => _seciliKat = kat);
    _yukle();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Tesis & Mekan Rehberi'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_haritaGoster ? Icons.list : Icons.map),
            onPressed: () => setState(() => _haritaGoster = !_haritaGoster),
          ),
        ],
      ),
      body: Column(
        children: [
          // Kategori filtresi
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: _kategoriler.length,
              itemBuilder: (ctx, i) {
                final k = _kategoriler[i];
                final sel = _seciliKat == k.$1;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => _kategoriSec(k.$1),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: sel ? Colors.purple : Colors.white,
                        border: Border.all(color: sel ? Colors.purple : Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${k.$2} ${k.$3}',
                        style: TextStyle(fontSize: 12, color: sel ? Colors.white : Colors.black87, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // İçerik
          Expanded(
            child: _yukleniyor
                ? const Center(child: CircularProgressIndicator())
                : _haritaGoster
                    ? _HaritaView(tesisler: _liste)
                    : _ListeView(tesisler: _liste),
          ),
        ],
      ),
    );
  }
}

class _ListeView extends StatelessWidget {
  final List<Map<String, dynamic>> tesisler;
  const _ListeView({required this.tesisler});

  @override
  Widget build(BuildContext context) {
    if (tesisler.isEmpty) {
      return const Center(child: Text('Bu kategoride tesis bulunamadı', style: TextStyle(color: Colors.grey)));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tesisler.length,
      itemBuilder: (ctx, i) => _TesisKarti(tesis: tesisler[i]),
    );
  }
}

class _TesisKarti extends StatelessWidget {
  final Map<String, dynamic> tesis;
  const _TesisKarti({required this.tesis});

  @override
  Widget build(BuildContext context) {
    final kat = _kategoriler.firstWhere(
      (k) => k.$1 == tesis['kategori'],
      orElse: () => const ('diger', '📋', 'Diğer'),
    );
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => _TesisDetayScreen(tesis: tesis))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
              child: tesis['foto_url'] != null
                  ? Image.network(
                      '${ApiConfig.serverBase}${tesis['foto_url']}',
                      width: 100, height: 100, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _FotoYer(kat.$2),
                    )
                  : _FotoYer(kat.$2),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(tesis['ad'] as String,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    const SizedBox(height: 2),
                    Text(kat.$3, style: TextStyle(color: Colors.purple.shade300, fontSize: 11)),
                    if (tesis['adres'] != null) ...[
                      const SizedBox(height: 4),
                      Row(children: [
                        const Icon(Icons.location_on, size: 12, color: Colors.grey),
                        const SizedBox(width: 2),
                        Expanded(child: Text(tesis['adres'] as String,
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.grey, fontSize: 11))),
                      ]),
                    ],
                    if (tesis['calisma_saatleri'] != null) ...[
                      const SizedBox(height: 2),
                      Row(children: [
                        const Icon(Icons.access_time, size: 12, color: Colors.grey),
                        const SizedBox(width: 2),
                        Expanded(child: Text(tesis['calisma_saatleri'] as String,
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.grey, fontSize: 11))),
                      ]),
                    ],
                  ],
                ),
              ),
            ),
            const Padding(padding: EdgeInsets.only(right: 12), child: Icon(Icons.chevron_right, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

class _FotoYer extends StatelessWidget {
  final String icon;
  const _FotoYer(this.icon);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100, height: 100,
      color: Colors.grey.shade100,
      child: Center(child: Text(icon, style: const TextStyle(fontSize: 36))),
    );
  }
}

class _HaritaView extends StatelessWidget {
  final List<Map<String, dynamic>> tesisler;
  const _HaritaView({required this.tesisler});

  @override
  Widget build(BuildContext context) {
    final noktalar = tesisler.where((t) => t['lat'] != null && t['lng'] != null).toList();
    const merkez = LatLng(41.2818, 36.9888); // Ünye

    return FlutterMap(
      options: const MapOptions(initialCenter: merkez, initialZoom: 13),
      children: [
        TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png'),
        MarkerLayer(
          markers: noktalar.map((t) {
            final lat = double.tryParse(t['lat'].toString()) ?? 0;
            final lng = double.tryParse(t['lng'].toString()) ?? 0;
            final kat = _kategoriler.firstWhere(
              (k) => k.$1 == t['kategori'],
              orElse: () => const ('diger', '📋', 'Diğer'),
            );
            return Marker(
              point: LatLng(lat, lng),
              child: GestureDetector(
                onTap: () => showModalBottomSheet(
                  context: context,
                  builder: (_) => _TesisOzetSheet(tesis: t),
                ),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.purple,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.purple.withOpacity(0.3), blurRadius: 8)],
                  ),
                  child: Text(kat.$2, style: const TextStyle(fontSize: 18)),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _TesisOzetSheet extends StatelessWidget {
  final Map<String, dynamic> tesis;
  const _TesisOzetSheet({required this.tesis});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(tesis['ad'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          if (tesis['adres'] != null) Text(tesis['adres'] as String, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => _TesisDetayScreen(tesis: tesis)));
            },
            child: const Text('Detayı Gör'),
          ),
        ],
      ),
    );
  }
}

class _TesisDetayScreen extends StatelessWidget {
  final Map<String, dynamic> tesis;
  const _TesisDetayScreen({required this.tesis});

  Future<void> _ara(String tel) async {
    final uri = Uri(scheme: 'tel', path: tel.replaceAll(' ', ''));
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _haritaAc(double lat, double lng) async {
    final uri = Uri.parse('geo:$lat,$lng?q=$lat,$lng(${tesis['ad']})');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      final webUri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final kat = _kategoriler.firstWhere(
      (k) => k.$1 == tesis['kategori'],
      orElse: () => const ('diger', '📋', 'Diğer'),
    );
    final lat = tesis['lat'] != null ? double.tryParse(tesis['lat'].toString()) : null;
    final lng = tesis['lng'] != null ? double.tryParse(tesis['lng'].toString()) : null;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: Colors.purple,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(tesis['ad'] as String, style: const TextStyle(color: Colors.white, fontSize: 16)),
              background: tesis['foto_url'] != null
                  ? Image.network('${ApiConfig.serverBase}${tesis['foto_url']}', fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(color: Colors.purple.shade200,
                          child: Center(child: Text(kat.$2, style: const TextStyle(fontSize: 64)))))
                  : Container(color: Colors.purple.shade200,
                      child: Center(child: Text(kat.$2, style: const TextStyle(fontSize: 80)))),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.purple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('${kat.$2} ${kat.$3}', style: const TextStyle(color: Colors.purple, fontWeight: FontWeight.w600)),
                  ),
                  if (tesis['aciklama'] != null && (tesis['aciklama'] as String).isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(tesis['aciklama'] as String, style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.6)),
                  ],
                  const SizedBox(height: 20),
                  _InfoBox(children: [
                    if (tesis['adres'] != null) _InfoRow(Icons.location_on, 'Adres', tesis['adres'] as String),
                    if (tesis['calisma_saatleri'] != null) _InfoRow(Icons.access_time, 'Çalışma Saatleri', tesis['calisma_saatleri'] as String),
                    if (tesis['telefon'] != null) _InfoRow(Icons.phone, 'Telefon', tesis['telefon'] as String),
                    if (tesis['website'] != null) _InfoRow(Icons.language, 'Website', tesis['website'] as String),
                  ]),
                  const SizedBox(height: 20),
                  if (tesis['telefon'] != null)
                    ElevatedButton.icon(
                      onPressed: () => _ara(tesis['telefon'] as String),
                      icon: const Icon(Icons.phone),
                      label: Text('Ara — ${tesis['telefon']}'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    ),
                  if (lat != null && lng != null) ...[
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () => _haritaAc(lat, lng),
                      icon: const Icon(Icons.directions),
                      label: const Text('Yol Tarifi Al'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  final List<Widget> children;
  const _InfoBox({required this.children});

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return const SizedBox();
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
      ),
      child: Column(
        children: children.asMap().entries.map((e) => Column(
          children: [
            e.value,
            if (e.key < children.length - 1) const Divider(height: 1),
          ],
        )).toList(),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.purple),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }
}
