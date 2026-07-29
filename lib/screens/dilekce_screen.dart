import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/dilekce.dart';
import '../services/api_service.dart';
import '../providers/auth_provider.dart';
import 'package:provider/provider.dart';

class DilekceScreen extends StatefulWidget {
  const DilekceScreen({super.key});

  @override
  State<DilekceScreen> createState() => _DilekceScreenState();
}

class _DilekceScreenState extends State<DilekceScreen> {
  List<DileceSablon> _list = [];
  bool _loading = true;
  String _selectedKategori = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await ApiService().getDileceSablonlari();
      setState(() { _list = data; _loading = false; });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  List<String> get _kategoriler {
    final k = <String>{};
    for (final s in _list) k.add(s.kategori);
    return ['', ...k.toList()..sort()];
  }

  List<DileceSablon> get _filtered =>
      _selectedKategori.isEmpty ? _list : _list.where((s) => s.kategori == _selectedKategori).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Dilekçe Şablonları'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Kategori filtreleme
                if (_kategoriler.length > 1)
                  Container(
                    color: Colors.white,
                    height: 48,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      itemCount: _kategoriler.length,
                      itemBuilder: (ctx, i) {
                        final k = _kategoriler[i];
                        final sel = _selectedKategori == k;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(k.isEmpty ? 'Tümü' : k),
                            selected: sel,
                            onSelected: (_) => setState(() => _selectedKategori = k),
                            selectedColor: Colors.teal[100],
                            checkmarkColor: Colors.teal[800],
                          ),
                        );
                      },
                    ),
                  ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _load,
                    child: _filtered.isEmpty
                        ? const Center(child: Text('Şablon bulunamadı'))
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _filtered.length,
                            itemBuilder: (ctx, i) => _SablonCard(sablon: _filtered[i]),
                          ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _SablonCard extends StatelessWidget {
  final DileceSablon sablon;
  const _SablonCard({required this.sablon});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => _DilekceDetay(sablon: sablon))),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(color: Colors.teal[50], borderRadius: BorderRadius.circular(12)),
                child: const Center(child: Text('📄', style: TextStyle(fontSize: 22))),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(sablon.baslik, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
                      child: Text(sablon.kategori, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}

class _DilekceDetay extends StatefulWidget {
  final DileceSablon sablon;
  const _DilekceDetay({required this.sablon});

  @override
  State<_DilekceDetay> createState() => _DilekceDetayState();
}

class _DilekceDetayState extends State<_DilekceDetay> {
  late TextEditingController _ctrl;
  bool _editing = false;

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    final user = auth.user;
    String icerik = widget.sablon.icerik;
    // Otomatik doldur
    if (user != null) {
      icerik = icerik
          .replaceAll('{{AD_SOYAD}}', user.adSoyad)
          .replaceAll('{{TELEFON}}', user.telefon ?? '')
          .replaceAll('{{TARIH}}', DateFormat('dd/MM/yyyy').format(DateTime.now()));
    }
    _ctrl = TextEditingController(text: icerik);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  void _copy() {
    Clipboard.setData(ClipboardData(text: _ctrl.text));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Dilekçe kopyalandı!')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.sablon.baslik, style: const TextStyle(fontSize: 15)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          IconButton(icon: Icon(_editing ? Icons.done : Icons.edit), onPressed: () => setState(() => _editing = !_editing),
              tooltip: _editing ? 'Düzenlemeyi bitir' : 'Düzenle'),
          IconButton(icon: const Icon(Icons.copy), onPressed: _copy, tooltip: 'Kopyala'),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: _editing
                  ? TextField(
                      controller: _ctrl,
                      maxLines: null,
                      style: const TextStyle(fontSize: 14, height: 1.6, fontFamily: 'monospace'),
                      decoration: const InputDecoration(border: OutlineInputBorder()),
                    )
                  : Text(_ctrl.text, style: const TextStyle(fontSize: 14, height: 1.8)),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _copy,
                    icon: const Icon(Icons.copy),
                    label: const Text('Kopyala'),
                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Paylaş (share_plus eklenebilir)
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Paylaşmak için kopyalayın')));
                    },
                    icon: const Icon(Icons.share),
                    label: const Text('Paylaş'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal[600], foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
