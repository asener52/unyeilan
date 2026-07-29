import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import '../models/kayip.dart';
import '../services/api_service.dart';

class KayipScreen extends StatefulWidget {
  const KayipScreen({super.key});

  @override
  State<KayipScreen> createState() => _KayipScreenState();
}

class _KayipScreenState extends State<KayipScreen> {
  List<KayipKisi> _list = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await ApiService().getKayipKisiler();
      setState(() { _list = data; _loading = false; });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Kayıp Kişiler'),
        backgroundColor: Colors.red[600],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: Colors.red[600],
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: const Text(
              '🚨 Kayıp kişi görürseniz lütfen ilan üzerindeki iletişim numarasını arayın.',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _load,
                    child: _list.isEmpty
                        ? const Center(child: Text('Aktif kayıp kişi ilanı bulunmuyor'))
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _list.length,
                            itemBuilder: (ctx, i) => _KayipCard(kisi: _list[i]),
                          ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _KayipCard extends StatelessWidget {
  final KayipKisi kisi;
  const _KayipCard({required this.kisi});

  @override
  Widget build(BuildContext context) {
    final durumRenk = kisi.durum == 'Aranıyor' ? Colors.red : kisi.durum == 'Bulundu' ? Colors.green : Colors.grey;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (kisi.fotoUrl != null)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: CachedNetworkImage(
                imageUrl: kisi.fotoUrl!,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => Container(height: 120, color: Colors.grey[200], child: const Icon(Icons.person, size: 48, color: Colors.grey)),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text(kisi.adSoyad, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: durumRenk.withOpacity(0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: durumRenk)),
                      child: Text(kisi.durum, style: TextStyle(color: durumRenk, fontSize: 12, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (kisi.dogumYili != null)
                  _InfoRow(icon: Icons.cake_outlined, text: 'Doğum yılı: ${kisi.dogumYili}'),
                if (kisi.cinsiyet != null)
                  _InfoRow(icon: Icons.person_outline, text: kisi.cinsiyet!),
                if (kisi.sonGorulmeYeri != null)
                  _InfoRow(icon: Icons.location_on_outlined, text: 'Son görülme: ${kisi.sonGorulmeYeri}'),
                if (kisi.sonGorulmeTarihi != null)
                  _InfoRow(icon: Icons.calendar_today_outlined, text: 'Tarih: ${kisi.sonGorulmeTarihi!.substring(0, 10)}'),
                if (kisi.aciklama != null) ...[
                  const SizedBox(height: 8),
                  Text(kisi.aciklama!, style: const TextStyle(color: Colors.black87, fontSize: 14)),
                ],
                if (kisi.iletisimNo != null) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => launchUrl(Uri.parse('tel:${kisi.iletisimNo}')),
                      icon: const Icon(Icons.phone),
                      label: Text('Ara: ${kisi.iletisimNo}'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[600],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13, color: Colors.black87))),
        ],
      ),
    );
  }
}
