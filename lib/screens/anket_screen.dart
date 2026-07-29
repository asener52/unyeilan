import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AnketScreen extends StatefulWidget {
  const AnketScreen({super.key});

  @override
  State<AnketScreen> createState() => _AnketScreenState();
}

class _AnketScreenState extends State<AnketScreen> {
  List<Map<String, dynamic>> _anketler = [];
  List<Map<String, dynamic>> _benimOylarim = [];
  bool _yukleniyor = true;

  @override
  void initState() {
    super.initState();
    _yukle();
  }

  Future<void> _yukle() async {
    setState(() => _yukleniyor = true);
    try {
      final results = await Future.wait([
        ApiService().getAnketler(),
        ApiService().getBenimOylarim(),
      ]);
      if (mounted) {
        setState(() {
          _anketler = results[0] as List<Map<String, dynamic>>;
          _benimOylarim = results[1] as List<Map<String, dynamic>>;
          _yukleniyor = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _yukleniyor = false);
    }
  }

  int? _benimOyum(int anketId) {
    final oy = _benimOylarim.where((o) => o['anket_id'] == anketId).toList();
    return oy.isEmpty ? null : oy.first['secenek_id'] as int?;
  }

  Future<void> _oyVer(int anketId, int secenekId) async {
    try {
      await ApiService().anketOyVer(anketId: anketId, secenekId: secenekId);
      await _yukle();
    } catch (e) {
      if (mounted) {
        final msg = e.toString().contains('zaten') ? 'Bu ankete zaten oy verdiniz' : 'Oy verilemedi';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Anket & Oylama'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _yukle)],
      ),
      body: _yukleniyor
          ? const Center(child: CircularProgressIndicator())
          : _anketler.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('📊', style: TextStyle(fontSize: 56)),
                      SizedBox(height: 16),
                      Text('Aktif anket bulunmuyor', style: TextStyle(color: Colors.grey, fontSize: 16)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _yukle,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _anketler.length,
                    itemBuilder: (ctx, i) => _AnketKart(
                      anket: _anketler[i],
                      benimOyum: _benimOyum(_anketler[i]['id'] as int),
                      onOy: (secenekId) => _oyVer(_anketler[i]['id'] as int, secenekId),
                    ),
                  ),
                ),
    );
  }
}

class _AnketKart extends StatelessWidget {
  final Map<String, dynamic> anket;
  final int? benimOyum;
  final void Function(int) onOy;

  const _AnketKart({required this.anket, required this.benimOyum, required this.onOy});

  @override
  Widget build(BuildContext context) {
    final secenekler = (anket['secenekler'] as List<dynamic>?) ?? [];
    final toplamOy = int.tryParse(anket['toplam_oy']?.toString() ?? '0') ?? 0;
    final oyVerildi = benimOyum != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 2))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('📊', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Expanded(child: Text(anket['baslik'] as String,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
              ],
            ),
            if (anket['aciklama'] != null && (anket['aciklama'] as String).isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(anket['aciklama'] as String, style: const TextStyle(color: Colors.grey, fontSize: 13)),
            ],
            const SizedBox(height: 16),

            if (!oyVerildi) ...[
              const Text('Görüşünüz nedir?', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13, color: Colors.black54)),
              const SizedBox(height: 10),
              ...secenekler.map((s) {
                final sec = s as Map<String, dynamic>;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: GestureDetector(
                    onTap: () => onOy(sec['id'] as int),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.blue.withOpacity(0.3)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(sec['secenek'] as String,
                          style: const TextStyle(fontWeight: FontWeight.w500)),
                    ),
                  ),
                );
              }),
            ] else ...[
              Text('Toplam $toplamOy oy', style: const TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 12),
              ...secenekler.map((s) {
                final sec = s as Map<String, dynamic>;
                final oyS = sec['oy_sayisi'] as int? ?? 0;
                final oran = toplamOy > 0 ? oyS / toplamOy : 0.0;
                final benimki = sec['id'] == benimOyum;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (benimki) const Icon(Icons.check_circle, color: Colors.blue, size: 16),
                          if (!benimki) const SizedBox(width: 16),
                          const SizedBox(width: 6),
                          Expanded(child: Text(sec['secenek'] as String,
                              style: TextStyle(
                                fontWeight: benimki ? FontWeight.bold : FontWeight.normal,
                                color: benimki ? Colors.blue : Colors.black87,
                              ))),
                          Text('${(oran * 100).round()}%',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: benimki ? FontWeight.bold : FontWeight.normal,
                                color: benimki ? Colors.blue : Colors.grey,
                              )),
                        ],
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: oran,
                          backgroundColor: Colors.grey.shade100,
                          color: benimki ? Colors.blue : Colors.grey.shade300,
                          minHeight: 8,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],

            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  oyVerildi ? '✓ Oyunuz alındı' : 'Henüz oy vermediniz',
                  style: TextStyle(
                    fontSize: 11,
                    color: oyVerildi ? Colors.green : Colors.grey,
                    fontWeight: oyVerildi ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
                if (anket['bitis_tarihi'] != null) Text(
                  'Bitiş: ${_tarih(anket['bitis_tarihi'] as String)}',
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _tarih(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      return '${dt.day.toString().padLeft(2,'0')}.${dt.month.toString().padLeft(2,'0')}.${dt.year}';
    } catch (_) { return iso; }
  }
}
