import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'dart:io';
import '../models/takas.dart';
import '../services/api_service.dart';
import '../providers/auth_provider.dart';
import '../config/api_config.dart';
import '../services/storage_service.dart';

class TakasScreen extends StatefulWidget {
  const TakasScreen({super.key});

  @override
  State<TakasScreen> createState() => _TakasScreenState();
}

class _TakasScreenState extends State<TakasScreen> with SingleTickerProviderStateMixin {
  late TabController _tab;
  List<TakasIlan> _all = [];
  bool _loading = true;
  String _filterTip = '';

  final _tips = [
    {'val': '', 'label': 'Tümü', 'icon': Icons.grid_view},
    {'val': 'takas', 'label': 'Takas', 'icon': Icons.swap_horiz},
    {'val': 'ver', 'label': 'Veriyor', 'icon': Icons.volunteer_activism},
    {'val': 'ara', 'label': 'Arıyor', 'icon': Icons.search},
  ];

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 4, vsync: this);
    _tab.addListener(() {
      if (!_tab.indexIsChanging) {
        setState(() => _filterTip = _tips[_tab.index]['val'] as String);
      }
    });
    _load();
  }

  @override
  void dispose() { _tab.dispose(); super.dispose(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await ApiService().getTakasIlanlari();
      setState(() { _all = data; _loading = false; });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  List<TakasIlan> get _filtered => _filterTip.isEmpty ? _all : _all.where((t) => t.tip == _filterTip).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Takas & Yardımlaşma'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        bottom: TabBar(
          controller: _tab,
          labelColor: Colors.blue[700],
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.blue[700],
          tabs: _tips.map((t) => Tab(text: t['label'] as String)).toList(),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('İlan Ver'),
        backgroundColor: Colors.blue[700],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: _filtered.isEmpty
                  ? const Center(child: Text('İlan bulunamadı'))
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                      itemCount: _filtered.length,
                      itemBuilder: (ctx, i) => _TakasCard(ilan: _filtered[i], onDelete: _load),
                    ),
            ),
    );
  }

  void _showAddDialog(BuildContext context) {
    final auth = context.read<AuthProvider>();
    if (!auth.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('İlan vermek için giriş yapmalısınız')));
      return;
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _AddIlanSheet(onAdded: _load),
    );
  }
}

class _TakasCard extends StatelessWidget {
  final TakasIlan ilan;
  final VoidCallback onDelete;
  const _TakasCard({required this.ilan, required this.onDelete});

  Color get _tipRenk => ilan.tip == 'ver' ? Colors.green : ilan.tip == 'ara' ? Colors.orange : Colors.blue;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (ilan.fotoUrl != null)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.network(ilan.fotoUrl!, height: 160, width: double.infinity, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox()),
            ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: _tipRenk.withOpacity(0.1), borderRadius: BorderRadius.circular(10), border: Border.all(color: _tipRenk)),
                  child: Text(ilan.tipAd, style: TextStyle(color: _tipRenk, fontSize: 11, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(10)),
                  child: Text(ilan.kategori, style: const TextStyle(color: Colors.grey, fontSize: 11)),
                ),
              ]),
              const SizedBox(height: 8),
              Text(ilan.baslik, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              if (ilan.aciklama != null) ...[
                const SizedBox(height: 4),
                Text(ilan.aciklama!, style: const TextStyle(color: Colors.black54, fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
              ],
              const SizedBox(height: 10),
              Row(children: [
                const Icon(Icons.person_outline, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(ilan.kullaniciAd, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const Spacer(),
                if (ilan.iletisim != null)
                  GestureDetector(
                    onTap: () => launchPhone(ilan.iletisim!),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(20)),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.phone, size: 14, color: Colors.green[700]),
                        const SizedBox(width: 4),
                        Text('İletişim', style: TextStyle(color: Colors.green[700], fontSize: 12)),
                      ]),
                    ),
                  ),
              ]),
            ]),
          ),
        ],
      ),
    );
  }

  void launchPhone(String phone) {
    // url_launcher
  }
}

class _AddIlanSheet extends StatefulWidget {
  final VoidCallback onAdded;
  const _AddIlanSheet({required this.onAdded});

  @override
  State<_AddIlanSheet> createState() => _AddIlanSheetState();
}

class _AddIlanSheetState extends State<_AddIlanSheet> {
  final _baslik = TextEditingController();
  final _aciklama = TextEditingController();
  final _iletisim = TextEditingController();
  String _tip = 'takas';
  String _kategori = 'Elektronik';
  File? _foto;
  bool _saving = false;
  String? _error;

  static const _kategoriler = ['Elektronik', 'Giyim', 'Mobilya', 'Kitap', 'Oyuncak', 'Bahçe', 'Spor', 'Diğer'];
  static const _tipler = [
    {'val': 'takas', 'label': 'Takas ediyorum'},
    {'val': 'ver', 'label': 'Veriyorum (ücretsiz)'},
    {'val': 'ara', 'label': 'Arıyorum'},
  ];

  @override
  void dispose() {
    _baslik.dispose(); _aciklama.dispose(); _iletisim.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final img = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (img != null) setState(() => _foto = File(img.path));
  }

  Future<void> _submit() async {
    if (_baslik.text.isEmpty) { setState(() => _error = 'Başlık zorunlu'); return; }
    setState(() { _saving = true; _error = null; });
    try {
      final token = await StorageService.getToken();
      final dio = Dio(BaseOptions(baseUrl: ApiConfig.baseUrl));
      final form = FormData.fromMap({
        'baslik': _baslik.text.trim(),
        'aciklama': _aciklama.text.trim(),
        'tip': _tip,
        'kategori': _kategori,
        'iletisim': _iletisim.text.trim(),
        if (_foto != null) 'foto': await MultipartFile.fromFile(_foto!.path),
      });
      final res = await dio.post('/takas', data: form, options: Options(headers: {'Authorization': 'Bearer $token'}));
      if (res.data['success'] == true) {
        Navigator.pop(context);
        widget.onAdded();
      } else {
        setState(() { _error = res.data['message'] ?? 'Hata'; _saving = false; });
      }
    } catch (e) {
      setState(() { _error = e.toString(); _saving = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Text('İlan Ver', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Spacer(),
            IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
          ]),
          if (_error != null) Container(margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(8)),
            child: Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 13))),
          // Tip seçimi
          const Text('İlan Türü', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(spacing: 8, children: _tipler.map((t) {
            final sel = _tip == t['val'];
            return ChoiceChip(label: Text(t['label']!), selected: sel, onSelected: (_) => setState(() => _tip = t['val']!));
          }).toList()),
          const SizedBox(height: 14),
          TextField(controller: _baslik, decoration: _dec('Başlık *')),
          const SizedBox(height: 10),
          TextField(controller: _aciklama, decoration: _dec('Açıklama'), maxLines: 3),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: _kategori,
            decoration: _dec('Kategori'),
            items: _kategoriler.map((k) => DropdownMenuItem(value: k, child: Text(k))).toList(),
            onChanged: (v) => setState(() => _kategori = v!),
          ),
          const SizedBox(height: 10),
          TextField(controller: _iletisim, decoration: _dec('İletişim no'), keyboardType: TextInputType.phone),
          const SizedBox(height: 14),
          // Fotoğraf
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              height: _foto != null ? 150 : 60,
              decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid)),
              child: _foto != null
                  ? ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.file(_foto!, fit: BoxFit.cover, width: double.infinity))
                  : const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(Icons.add_photo_alternate_outlined, color: Colors.grey),
                      SizedBox(width: 8),
                      Text('Fotoğraf Ekle', style: TextStyle(color: Colors.grey)),
                    ]),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saving ? null : _submit,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[700], foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: _saving ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('İlan Yayınla', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            ),
          ),
        ]),
      ),
    );
  }

  InputDecoration _dec(String label) => InputDecoration(
    labelText: label, filled: true, fillColor: Colors.grey[50],
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
  );
}
