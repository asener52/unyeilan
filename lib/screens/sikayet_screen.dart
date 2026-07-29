import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import '../services/api_service.dart';
import '../config/api_config.dart';
import '../services/storage_service.dart';

const _kategoriler = [
  ('yol', '🛣️', 'Yol & Kaldırım'),
  ('aydinlatma', '💡', 'Aydınlatma'),
  ('cop', '🗑️', 'Çöp & Temizlik'),
  ('su', '💧', 'Su & Kanalizasyon'),
  ('cevre', '🌳', 'Çevre & Yeşil Alan'),
  ('gurultu', '🔊', 'Gürültü'),
  ('diger', '📋', 'Diğer'),
];

const _durumRenkler = {
  'bekliyor': Color(0xFFF59E0B),
  'inceleniyor': Color(0xFF3B82F6),
  'islemde': Color(0xFFF97316),
  'cozuldu': Color(0xFF22C55E),
  'reddedildi': Color(0xFFEF4444),
};

const _durumAdlari = {
  'bekliyor': 'Bekliyor',
  'inceleniyor': 'İnceleniyor',
  'islemde': 'İşlemde',
  'cozuldu': 'Çözüldü',
  'reddedildi': 'Reddedildi',
};

class SikayetScreen extends StatefulWidget {
  const SikayetScreen({super.key});

  @override
  State<SikayetScreen> createState() => _SikayetScreenState();
}

class _SikayetScreenState extends State<SikayetScreen> {
  List<Map<String, dynamic>> _liste = [];
  bool _yukleniyor = true;

  @override
  void initState() {
    super.initState();
    _yukle();
  }

  Future<void> _yukle() async {
    setState(() => _yukleniyor = true);
    try {
      final data = await ApiService().getBenimSikayetler();
      if (mounted) setState(() { _liste = data; _yukleniyor = false; });
    } catch (_) {
      if (mounted) setState(() => _yukleniyor = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Şikayet & Taleplerim'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _yukle,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final sonuc = await Navigator.push<bool>(
            context, MaterialPageRoute(builder: (_) => const SikayetFormScreen()),
          );
          if (sonuc == true) _yukle();
        },
        label: const Text('Yeni Şikayet'),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.orange,
      ),
      body: _yukleniyor
          ? const Center(child: CircularProgressIndicator())
          : _liste.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('📋', style: TextStyle(fontSize: 56)),
                      const SizedBox(height: 16),
                      const Text('Henüz şikayetiniz yok', style: TextStyle(fontSize: 16, color: Colors.grey)),
                      const SizedBox(height: 8),
                      const Text('Çevrenizdeki sorunları bildirin', style: TextStyle(color: Colors.grey)),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () async {
                          final sonuc = await Navigator.push<bool>(
                            context, MaterialPageRoute(builder: (_) => const SikayetFormScreen()),
                          );
                          if (sonuc == true) _yukle();
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Şikayet Bildir'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _yukle,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _liste.length,
                    itemBuilder: (ctx, i) {
                      final s = _liste[i];
                      final durum = s['durum'] as String? ?? 'bekliyor';
                      final kat = _kategoriler.firstWhere(
                        (k) => k.$1 == s['kategori'],
                        orElse: () => const ('diger', '📋', 'Diğer'),
                      );
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
                                  Text(kat.$2, style: const TextStyle(fontSize: 20)),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(s['baslik'] as String? ?? '',
                                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: (_durumRenkler[durum] ?? Colors.grey).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      _durumAdlari[durum] ?? durum,
                                      style: TextStyle(
                                        color: _durumRenkler[durum] ?? Colors.grey,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (s['aciklama'] != null && (s['aciklama'] as String).isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text(s['aciklama'] as String,
                                    maxLines: 2, overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(color: Colors.grey, fontSize: 13)),
                              ],
                              if (s['admin_notu'] != null && (s['admin_notu'] as String).isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.info_outline, size: 16, color: Colors.blue),
                                      const SizedBox(width: 8),
                                      Expanded(child: Text(s['admin_notu'] as String,
                                          style: const TextStyle(color: Colors.blue, fontSize: 12))),
                                    ],
                                  ),
                                ),
                              ],
                              const SizedBox(height: 8),
                              Text(
                                _tarihFormat(s['created_at'] as String?),
                                style: const TextStyle(color: Colors.grey, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  String _tarihFormat(String? iso) {
    if (iso == null) return '';
    try {
      final dt = DateTime.parse(iso).toLocal();
      return '${dt.day.toString().padLeft(2,'0')}.${dt.month.toString().padLeft(2,'0')}.${dt.year}';
    } catch (_) { return iso; }
  }
}

// ------- Form Ekranı -------

class SikayetFormScreen extends StatefulWidget {
  const SikayetFormScreen({super.key});

  @override
  State<SikayetFormScreen> createState() => _SikayetFormScreenState();
}

class _SikayetFormScreenState extends State<SikayetFormScreen> {
  final _baslikCtrl = TextEditingController();
  final _aciklamaCtrl = TextEditingController();
  final _adresCtrl = TextEditingController();
  String _kategori = 'diger';
  File? _foto;
  bool _gonderiliyor = false;

  Future<void> _foto_sec() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70, maxWidth: 1280);
    if (picked != null) setState(() => _foto = File(picked.path));
  }

  Future<void> _kameraAc() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.camera, imageQuality: 70, maxWidth: 1280);
    if (picked != null) setState(() => _foto = File(picked.path));
  }

  Future<void> _gonder() async {
    if (_baslikCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Başlık zorunlu')));
      return;
    }
    setState(() => _gonderiliyor = true);
    try {
      final token = await StorageService.getToken();
      final dio = Dio(BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        headers: {'Authorization': 'Bearer $token'},
      ));
      final fd = FormData.fromMap({
        'kategori': _kategori,
        'baslik': _baslikCtrl.text.trim(),
        'aciklama': _aciklamaCtrl.text.trim(),
        'adres': _adresCtrl.text.trim(),
        if (_foto != null) 'foto': await MultipartFile.fromFile(_foto!.path),
      });
      await dio.post('/sikayet', data: fd);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Şikayetiniz iletildi'), backgroundColor: Colors.green),
        );
        Navigator.pop(context, true);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gönderme başarısız, tekrar deneyin'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _gonderiliyor = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Şikayet Bildir'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Kategori
            const Text('Kategori', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.black54)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: _kategoriler.map((k) {
                final sel = _kategori == k.$1;
                return GestureDetector(
                  onTap: () => setState(() => _kategori = k.$1),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: sel ? Colors.orange : Colors.white,
                      border: Border.all(color: sel ? Colors.orange : Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('${k.$2} ${k.$3}',
                        style: TextStyle(fontSize: 12, color: sel ? Colors.white : Colors.black87, fontWeight: FontWeight.w500)),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Başlık
            _Label('Başlık *'),
            TextField(
              controller: _baslikCtrl,
              decoration: _dec('Sorunun kısa özeti'),
              maxLength: 200,
            ),
            const SizedBox(height: 12),

            // Açıklama
            _Label('Açıklama'),
            TextField(
              controller: _aciklamaCtrl,
              decoration: _dec('Sorunu detaylı anlatın'),
              maxLines: 4,
            ),
            const SizedBox(height: 12),

            // Adres
            _Label('Adres / Konum'),
            TextField(
              controller: _adresCtrl,
              decoration: _dec('Sorunun olduğu yer'),
            ),
            const SizedBox(height: 20),

            // Fotoğraf
            _Label('Fotoğraf (İsteğe bağlı)'),
            const SizedBox(height: 8),
            if (_foto != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(_foto!, height: 180, width: double.infinity, fit: BoxFit.cover),
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () => setState(() => _foto = null),
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                label: const Text('Fotoğrafı Kaldır', style: TextStyle(color: Colors.red)),
              ),
            ] else ...[
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _foto_sec,
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Galeriden Seç'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _kameraAc,
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Fotoğraf Çek'),
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _gonderiliyor ? null : _gonder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: _gonderiliyor
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Şikayeti Gönder', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _Label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.black54)),
  );

  InputDecoration _dec(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: Colors.grey),
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.orange)),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
  );

  @override
  void dispose() {
    _baslikCtrl.dispose();
    _aciklamaCtrl.dispose();
    _adresCtrl.dispose();
    super.dispose();
  }
}
