import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';

const _saatler = [
  '08:30', '09:00', '09:30', '10:00', '10:30', '11:00', '11:30',
  '13:00', '13:30', '14:00', '14:30', '15:00', '15:30', '16:00', '16:30',
];

const _durumRenkler = {
  'bekliyor': Color(0xFFF59E0B),
  'onaylandi': Color(0xFF22C55E),
  'iptal': Color(0xFFEF4444),
  'tamamlandi': Color(0xFF3B82F6),
};

const _durumAdlari = {
  'bekliyor': 'Bekliyor',
  'onaylandi': 'Onaylandı',
  'iptal': 'İptal',
  'tamamlandi': 'Tamamlandı',
};

class RandevuScreen extends StatefulWidget {
  const RandevuScreen({super.key});

  @override
  State<RandevuScreen> createState() => _RandevuScreenState();
}

class _RandevuScreenState extends State<RandevuScreen> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  List<Map<String, dynamic>> _randevularim = [];
  List<Map<String, dynamic>> _birimler = [];
  bool _yukleniyor = true;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _yukle();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  Future<void> _yukle() async {
    setState(() => _yukleniyor = true);
    try {
      final results = await Future.wait([
        ApiService().getBenimRandevular(),
        ApiService().getRandevuBirimleri(),
      ]);
      if (mounted) {
        setState(() {
          _randevularim = results[0] as List<Map<String, dynamic>>;
          _birimler = results[1] as List<Map<String, dynamic>>;
          _yukleniyor = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _yukleniyor = false);
    }
  }

  Future<void> _iptalEt(int id) async {
    final onay = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Randevu İptal'),
        content: const Text('Bu randevuyu iptal etmek istiyor musunuz?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hayır')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Evet', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (onay != true) return;
    try {
      await ApiService().randevuIptal(id);
      _yukle();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('İptal edilemedi')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Randevu Sistemi'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        bottom: TabBar(
          controller: _tabCtrl,
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.blue,
          tabs: const [
            Tab(text: 'Randevularım'),
            Tab(text: 'Randevu Al'),
          ],
        ),
      ),
      body: _yukleniyor
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabCtrl,
              children: [
                _RandevularimTab(
                  randevular: _randevularim,
                  onRefresh: _yukle,
                  onIptal: _iptalEt,
                ),
                _RandevuAlTab(
                  birimler: _birimler,
                  onSuccess: () { _yukle(); _tabCtrl.animateTo(0); },
                ),
              ],
            ),
    );
  }
}

class _RandevularimTab extends StatelessWidget {
  final List<Map<String, dynamic>> randevular;
  final Future<void> Function() onRefresh;
  final void Function(int) onIptal;

  const _RandevularimTab({required this.randevular, required this.onRefresh, required this.onIptal});

  @override
  Widget build(BuildContext context) {
    if (randevular.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('📅', style: TextStyle(fontSize: 56)),
            SizedBox(height: 16),
            Text('Randevunuz bulunmuyor', style: TextStyle(color: Colors.grey, fontSize: 16)),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: randevular.length,
        itemBuilder: (ctx, i) {
          final r = randevular[i];
          final durum = r['durum'] as String? ?? 'bekliyor';
          final tarih = r['tarih']?.toString().substring(0, 10) ?? '';
          final saat = r['saat']?.toString().substring(0, 5) ?? '';
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.business, color: Colors.blue, size: 18),
                      const SizedBox(width: 6),
                      Expanded(child: Text(r['birim_ad'] as String? ?? '-',
                          style: const TextStyle(fontWeight: FontWeight.w600))),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: (_durumRenkler[durum] ?? Colors.grey).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(_durumAdlari[durum] ?? durum,
                            style: TextStyle(color: _durumRenkler[durum] ?? Colors.grey, fontSize: 11, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text('$tarih — $saat', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(r['konu'] as String? ?? '', style: const TextStyle(fontSize: 13, color: Colors.black87)),
                  if (r['admin_notu'] != null && (r['admin_notu'] as String).isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
                      child: Text(r['admin_notu'] as String, style: const TextStyle(color: Colors.blue, fontSize: 12)),
                    ),
                  ],
                  if (durum == 'bekliyor') ...[
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => onIptal(r['id'] as int),
                        child: const Text('İptal Et', style: TextStyle(color: Colors.red)),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _RandevuAlTab extends StatefulWidget {
  final List<Map<String, dynamic>> birimler;
  final VoidCallback onSuccess;
  const _RandevuAlTab({required this.birimler, required this.onSuccess});

  @override
  State<_RandevuAlTab> createState() => _RandevuAlTabState();
}

class _RandevuAlTabState extends State<_RandevuAlTab> {
  Map<String, dynamic>? _seciliBirim;
  DateTime? _seciliTarih;
  String? _seciliSaat;
  final _konuCtrl = TextEditingController();
  List<String> _doluSaatler = [];
  bool _yukleniyor = false;
  bool _gonderiliyor = false;

  Future<void> _tarihSec() async {
    final dt = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 60)),
      locale: const Locale('tr', 'TR'),
    );
    if (dt == null) return;
    setState(() { _seciliTarih = dt; _seciliSaat = null; });
    if (_seciliBirim != null) await _doluSaatleriYukle();
  }

  Future<void> _doluSaatleriYukle() async {
    if (_seciliBirim == null || _seciliTarih == null) return;
    setState(() => _yukleniyor = true);
    try {
      final tarihStr = DateFormat('yyyy-MM-dd').format(_seciliTarih!);
      final data = await ApiService().getRandevuDoluSaatler(
        birimId: _seciliBirim!['id'] as int,
        tarih: tarihStr,
      );
      if (mounted) setState(() { _doluSaatler = data; _yukleniyor = false; });
    } catch (_) {
      if (mounted) setState(() => _yukleniyor = false);
    }
  }

  Future<void> _gonder() async {
    if (_seciliBirim == null || _seciliTarih == null || _seciliSaat == null || _konuCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tüm alanları doldurun')));
      return;
    }
    setState(() => _gonderiliyor = true);
    try {
      await ApiService().randevuAl(
        birimId: _seciliBirim!['id'] as int,
        tarih: DateFormat('yyyy-MM-dd').format(_seciliTarih!),
        saat: _seciliSaat!,
        konu: _konuCtrl.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Randevunuz alındı!'), backgroundColor: Colors.green));
        widget.onSuccess();
      }
    } catch (e) {
      if (mounted) {
        final msg = e.toString().contains('dolu') ? 'Bu saat dolu, başka saat seçin' : 'Randevu alınamadı';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _gonderiliyor = false);
    }
  }

  @override
  void dispose() {
    _konuCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Birim seçimi
          _Baslik('Birim Seçin'),
          ...widget.birimler.map((b) => RadioListTile<Map<String, dynamic>>(
            value: b,
            groupValue: _seciliBirim,
            onChanged: (v) async {
              setState(() { _seciliBirim = v; _seciliSaat = null; });
              if (_seciliTarih != null) await _doluSaatleriYukle();
            },
            title: Text(b['ad'] as String),
            subtitle: b['aciklama'] != null ? Text(b['aciklama'] as String, style: const TextStyle(fontSize: 12)) : null,
            activeColor: Colors.blue,
            contentPadding: EdgeInsets.zero,
          )),
          const SizedBox(height: 16),

          // Tarih
          _Baslik('Tarih Seçin'),
          GestureDetector(
            onTap: _tarihSec,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, color: Colors.blue, size: 20),
                  const SizedBox(width: 12),
                  Text(
                    _seciliTarih != null ? DateFormat('dd MMMM yyyy', 'tr').format(_seciliTarih!) : 'Tarih seçin',
                    style: TextStyle(color: _seciliTarih != null ? Colors.black87 : Colors.grey),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Saat
          if (_seciliTarih != null) ...[
            _Baslik('Saat Seçin'),
            if (_yukleniyor) const Center(child: CircularProgressIndicator()),
            if (!_yukleniyor) Wrap(
              spacing: 8, runSpacing: 8,
              children: _saatler.map((s) {
                final dolu = _doluSaatler.contains(s);
                final sel = _seciliSaat == s;
                return GestureDetector(
                  onTap: dolu ? null : () => setState(() => _seciliSaat = s),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: dolu ? Colors.grey.shade100 : sel ? Colors.blue : Colors.white,
                      border: Border.all(color: dolu ? Colors.grey.shade300 : sel ? Colors.blue : Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      s,
                      style: TextStyle(
                        color: dolu ? Colors.grey : sel ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w500,
                        decoration: dolu ? TextDecoration.lineThrough : null,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],

          // Konu
          _Baslik('Konu / Açıklama *'),
          TextField(
            controller: _konuCtrl,
            decoration: InputDecoration(
              hintText: 'Görüşme konusunu kısaca belirtin',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.blue)),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _gonderiliyor ? null : _gonder,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: _gonderiliyor
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Randevu Al', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _Baslik(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 8, top: 4),
    child: Text(t, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.black54)),
  );
}
