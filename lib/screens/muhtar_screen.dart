import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/muhtar.dart';
import '../services/api_service.dart';

class MuhtarScreen extends StatefulWidget {
  const MuhtarScreen({super.key});

  @override
  State<MuhtarScreen> createState() => _MuhtarScreenState();
}

class _MuhtarScreenState extends State<MuhtarScreen> {
  List<Muhtar> _list = [];
  bool _loading = true;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await ApiService().getMuhtarlar();
      setState(() { _list = data; _loading = false; });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  List<Muhtar> get _filtered => _search.isEmpty
      ? _list
      : _list.where((m) =>
          (m.adSoyad.toLowerCase().contains(_search.toLowerCase())) ||
          (m.mahalleAd?.toLowerCase().contains(_search.toLowerCase()) ?? false)).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mahalle Muhtarları'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              onChanged: (v) => setState(() => _search = v),
              decoration: InputDecoration(
                hintText: 'Mahalle veya isim ara...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: _filtered.isEmpty
                  ? const Center(child: Text('Kayıt bulunamadı'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _filtered.length,
                      itemBuilder: (ctx, i) => _MuhtarCard(muhtar: _filtered[i]),
                    ),
            ),
    );
  }
}

class _MuhtarCard extends StatelessWidget {
  final Muhtar muhtar;
  const _MuhtarCard({required this.muhtar});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Fotoğraf
            CircleAvatar(
              radius: 32,
              backgroundColor: Colors.blue[50],
              backgroundImage: muhtar.fotoUrl != null
                  ? CachedNetworkImageProvider(muhtar.fotoUrl!)
                  : null,
              child: muhtar.fotoUrl == null ? const Icon(Icons.person, size: 32, color: Colors.blue) : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (muhtar.mahalleAd != null)
                    Text('${muhtar.mahalleAd} Mahallesi',
                        style: TextStyle(fontSize: 12, color: Colors.blue[700], fontWeight: FontWeight.w600)),
                  Text(muhtar.adSoyad, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  if (muhtar.ofisSaatleri != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(children: [
                        const Icon(Icons.access_time, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(muhtar.ofisSaatleri!, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ]),
                    ),
                  if (muhtar.telefon != null) ...[
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => launchUrl(Uri.parse('tel:${muhtar.telefon}')),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.phone, size: 14, color: Colors.green[700]),
                            const SizedBox(width: 6),
                            Text(muhtar.telefon!, style: TextStyle(color: Colors.green[700], fontSize: 13, fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
