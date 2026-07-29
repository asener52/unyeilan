import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_service.dart';

class AcilScreen extends StatefulWidget {
  const AcilScreen({super.key});

  @override
  State<AcilScreen> createState() => _AcilScreenState();
}

class _AcilScreenState extends State<AcilScreen> {
  List<Map<String, dynamic>> _liste = [];
  bool _yukleniyor = true;

  @override
  void initState() {
    super.initState();
    _yukle();
  }

  Future<void> _yukle() async {
    try {
      final list = await ApiService().getAcilNumaralar();
      if (mounted) setState(() { _liste = list; _yukleniyor = false; });
    } catch (e) {
      if (mounted) setState(() => _yukleniyor = false);
    }
  }

  Future<void> _ara(String numara) async {
    final uri = Uri(scheme: 'tel', path: numara.replaceAll(' ', ''));
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Map<String, List<Map<String, dynamic>>> _grupla() {
    final Map<String, List<Map<String, dynamic>>> gruplar = {};
    for (final n in _liste) {
      final kat = n['kategori'] as String? ?? 'genel';
      gruplar.putIfAbsent(kat, () => []).add(n);
    }
    return gruplar;
  }

  String _kategoriAdi(String kat) {
    const adlar = {
      'acil': '🚨 Acil Servisler',
      'belediye': '🏛️ Belediye',
      'saglik': '🏥 Sağlık',
      'altyapi': '🔧 Altyapı',
      'genel': '📋 Genel',
      'guvenlik': '👮 Güvenlik',
    };
    return adlar[kat] ?? kat;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Acil & Önemli Numaralar'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: _yukleniyor
          ? const Center(child: CircularProgressIndicator())
          : _liste.isEmpty
              ? const Center(child: Text('Numara bulunamadı'))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Acil 112 büyük kart
                    _BuyukAcilKart(onTap: () => _ara('112')),
                    const SizedBox(height: 16),
                    ..._grupla().entries.map((entry) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8, top: 8),
                          child: Text(
                            _kategoriAdi(entry.key),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black54),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
                          ),
                          child: Column(
                            children: entry.value.asMap().entries.map((e) {
                              final n = e.value;
                              final isLast = e.key == entry.value.length - 1;
                              return Column(
                                children: [
                                  _NumaraKarti(
                                    icon: n['icon'] as String? ?? '📞',
                                    ad: n['ad'] as String,
                                    numara: n['numara'] as String,
                                    renk: _parseColor(n['renk'] as String? ?? '#e74c3c'),
                                    onTap: () => _ara(n['numara'] as String),
                                  ),
                                  if (!isLast) const Divider(height: 1, indent: 64),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    )),
                  ],
                ),
    );
  }

  Color _parseColor(String hex) {
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return Colors.red;
    }
  }
}

class _BuyukAcilKart extends StatelessWidget {
  final VoidCallback onTap;
  const _BuyukAcilKart({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFe74c3c), Color(0xFFc0392b)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.red.withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 4)),
          ],
        ),
        child: const Row(
          children: [
            Text('🚑', style: TextStyle(fontSize: 48)),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ACİL YARDIM', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text('112', style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900, letterSpacing: 2)),
                  Text('Ambulans · İtfaiye · Polis', style: TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.phone, color: Colors.white, size: 32),
          ],
        ),
      ),
    );
  }
}

class _NumaraKarti extends StatelessWidget {
  final String icon;
  final String ad;
  final String numara;
  final Color renk;
  final VoidCallback onTap;

  const _NumaraKarti({
    required this.icon,
    required this.ad,
    required this.numara,
    required this.renk,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 44, height: 44,
        decoration: BoxDecoration(
          color: renk.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(child: Text(icon, style: const TextStyle(fontSize: 22))),
      ),
      title: Text(ad, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      subtitle: Text(numara, style: TextStyle(color: renk, fontWeight: FontWeight.bold, fontSize: 15)),
      trailing: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: renk.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.phone, color: renk, size: 20),
        ),
      ),
      onTap: onTap,
    );
  }
}
