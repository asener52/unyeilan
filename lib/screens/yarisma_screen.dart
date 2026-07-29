import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'dart:io';
import '../models/yarisma.dart';
import '../services/api_service.dart';
import '../providers/auth_provider.dart';
import '../config/api_config.dart';
import '../services/storage_service.dart';

class YarismaScreen extends StatefulWidget {
  const YarismaScreen({super.key});

  @override
  State<YarismaScreen> createState() => _YarismaScreenState();
}

class _YarismaScreenState extends State<YarismaScreen> {
  List<Yarisma> _yarismallar = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await ApiService().getYarismallar();
      setState(() { _yarismallar = data; _loading = false; });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Fotoğraf Yarışması'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: _yarismallar.isEmpty
                  ? const Center(child: Text('Aktif yarışma bulunamadı'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _yarismallar.length,
                      itemBuilder: (ctx, i) => _YarismaCard(
                        yarisma: _yarismallar[i],
                        onRefresh: _load,
                      ),
                    ),
            ),
    );
  }
}

class _YarismaCard extends StatelessWidget {
  final Yarisma yarisma;
  final VoidCallback onRefresh;
  const _YarismaCard({required this.yarisma, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final kalan = yarisma.bitisTarihi.difference(DateTime.now());
    final bitti = kalan.isNegative;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => _YarismaDetay(yarisma: yarisma))),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Text('📸', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(yarisma.baslik, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                if (yarisma.tema != null) Text('Tema: ${yarisma.tema}', style: const TextStyle(color: Colors.grey, fontSize: 13)),
              ])),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: bitti ? Colors.grey[100] : Colors.purple[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  bitti ? 'Bitti' : '${kalan.inDays}g ${kalan.inHours % 24}s',
                  style: TextStyle(color: bitti ? Colors.grey : Colors.purple[700], fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ]),
            if (yarisma.aciklama != null) ...[
              const SizedBox(height: 8),
              Text(yarisma.aciklama!, style: const TextStyle(color: Colors.black54, fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
            ],
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: OutlinedButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => _YarismaDetay(yarisma: yarisma))),
                child: const Text('Fotoğrafları Gör'),
              )),
              if (!bitti) ...[
                const SizedBox(width: 8),
                Expanded(child: ElevatedButton(
                  onPressed: () {
                    final auth = context.read<AuthProvider>();
                    if (!auth.isLoggedIn) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Katılmak için giriş yapın')));
                      return;
                    }
                    showModalBottomSheet(context: context, isScrollControlled: true,
                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                      builder: (_) => _KatilimSheet(yarismaId: yarisma.id, onUploaded: onRefresh));
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.purple[600], foregroundColor: Colors.white),
                  child: const Text('Katıl'),
                )),
              ],
            ]),
          ]),
        ),
      ),
    );
  }
}

class _YarismaDetay extends StatefulWidget {
  final Yarisma yarisma;
  const _YarismaDetay({required this.yarisma});

  @override
  State<_YarismaDetay> createState() => _YarismaDetayState();
}

class _YarismaDetayState extends State<_YarismaDetay> {
  List<YarismaFotograf> _fotograflar = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await ApiService().getYarismaFotograflar(widget.yarisma.id);
      setState(() { _fotograflar = data; _loading = false; });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  Future<void> _begen(int fotoId) async {
    try {
      await ApiService().begenYarismaFoto(fotoId);
      _load();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.yarisma.baslik), backgroundColor: Colors.white, foregroundColor: Colors.black87, elevation: 0),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _fotograflar.isEmpty
              ? const Center(child: Text('Henüz fotoğraf yok'))
              : GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 8, mainAxisSpacing: 8, childAspectRatio: 0.8),
                  itemCount: _fotograflar.length,
                  itemBuilder: (ctx, i) {
                    final f = _fotograflar[i];
                    return Card(
                      clipBehavior: Clip.antiAlias,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: Image.network(f.fotoUrl, fit: BoxFit.cover, width: double.infinity,
                              errorBuilder: (_, __, ___) => Container(color: Colors.grey[200], child: const Icon(Icons.image, size: 40, color: Colors.grey)))),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                            child: Row(children: [
                              Expanded(child: Text(f.kullaniciAd, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis)),
                              GestureDetector(
                                onTap: () => _begen(f.id),
                                child: Row(mainAxisSize: MainAxisSize.min, children: [
                                  const Icon(Icons.favorite_border, size: 14, color: Colors.red),
                                  const SizedBox(width: 2),
                                  Text('${f.begeniSayisi}', style: const TextStyle(fontSize: 12)),
                                ]),
                              ),
                            ]),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}

class _KatilimSheet extends StatefulWidget {
  final int yarismaId;
  final VoidCallback onUploaded;
  const _KatilimSheet({required this.yarismaId, required this.onUploaded});

  @override
  State<_KatilimSheet> createState() => _KatilimSheetState();
}

class _KatilimSheetState extends State<_KatilimSheet> {
  File? _foto;
  final _aciklama = TextEditingController();
  bool _uploading = false;
  String? _error;

  @override
  void dispose() { _aciklama.dispose(); super.dispose(); }

  Future<void> _pick() async {
    final img = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (img != null) setState(() => _foto = File(img.path));
  }

  Future<void> _upload() async {
    if (_foto == null) { setState(() => _error = 'Fotoğraf seçin'); return; }
    setState(() { _uploading = true; _error = null; });
    try {
      final token = await StorageService.getToken();
      final dio = Dio(BaseOptions(baseUrl: ApiConfig.baseUrl));
      final form = FormData.fromMap({
        'foto': await MultipartFile.fromFile(_foto!.path),
        if (_aciklama.text.isNotEmpty) 'aciklama': _aciklama.text.trim(),
      });
      final res = await dio.post('/yarisma/${widget.yarismaId}/fotograflar', data: form,
          options: Options(headers: {'Authorization': 'Bearer $token'}));
      if (res.data['success'] == true) {
        Navigator.pop(context);
        widget.onUploaded();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fotoğrafınız yüklendi! +20 puan kazandınız 🎉')));
      } else {
        setState(() { _error = res.data['message'] ?? 'Hata'; _uploading = false; });
      }
    } catch (e) {
      setState(() { _error = e.toString(); _uploading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Fotoğraf Yükle', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          if (_error != null) Container(margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(8)),
              child: Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 13))),
          GestureDetector(
            onTap: _pick,
            child: Container(
              height: _foto != null ? 200 : 100,
              decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)),
              child: _foto != null
                  ? ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.file(_foto!, fit: BoxFit.cover, width: double.infinity))
                  : const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.add_a_photo, size: 36, color: Colors.grey),
                      SizedBox(height: 8),
                      Text('Galeride fotoğraf seç', style: TextStyle(color: Colors.grey)),
                    ])),
            ),
          ),
          const SizedBox(height: 12),
          TextField(controller: _aciklama, decoration: InputDecoration(labelText: 'Açıklama (isteğe bağlı)', filled: true, fillColor: Colors.grey[50], border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _uploading ? null : _upload,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.purple[600], foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: _uploading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Yükle', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            ),
          ),
        ]),
      ),
    );
  }
}
