import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import '../providers/content_provider.dart';
import '../models/eczane.dart';
import '../utils/theme.dart';

class EczaneScreen extends StatefulWidget {
  const EczaneScreen({super.key});

  @override
  State<EczaneScreen> createState() => _EczaneScreenState();
}

class _EczaneScreenState extends State<EczaneScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ContentProvider>().loadEczaneler();
    });
  }

  Future<void> _refresh() async {
    await context.read<ContentProvider>().loadEczaneler();
  }

  @override
  Widget build(BuildContext context) {
    final cp = context.watch<ContentProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverAppBar(
              expandedHeight: 130,
              floating: false,
              pinned: true,
              backgroundColor: AppTheme.primary,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF1A56DB), Color(0xFF0E3A9E)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 44, height: 44,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.local_pharmacy, color: Colors.white, size: 24),
                              ),
                              const SizedBox(width: 12),
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Nöbetçi Eczane', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                                  Text('Şu an nöbetçi eczaneler', style: TextStyle(color: Colors.white70, fontSize: 12)),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            cp.eczaneler.isEmpty
                ? SliverFillRemaining(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('🏥', style: TextStyle(fontSize: 56)),
                        const SizedBox(height: 16),
                        const Text('Şu an nöbetçi eczane\nbilgisi bulunmuyor',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppTheme.textSecondary, fontSize: 15)),
                        const SizedBox(height: 12),
                        TextButton.icon(
                          onPressed: _refresh,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Yenile'),
                        ),
                      ],
                    ),
                  )
                : SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (_, i) => _EczaneCard(eczane: cp.eczaneler[i]),
                        childCount: cp.eczaneler.length,
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

class _EczaneCard extends StatelessWidget {
  final Eczane eczane;
  const _EczaneCard({required this.eczane});

  String _formatTarih(String? val) {
    if (val == null || val.isEmpty) return '';
    final dt = DateTime.tryParse(val);
    if (dt == null) return val;
    return DateFormat('dd.MM.yyyy HH:mm', 'tr').format(dt.toLocal());
  }

  @override
  Widget build(BuildContext context) {
    final baslangic = _formatTarih(eczane.tarih);
    final bitis = _formatTarih(eczane.bitisTarihi);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A56DB).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.local_pharmacy, color: Color(0xFF1A56DB), size: 26),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(eczane.ad, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: Text('Şu An Nöbetçi', style: TextStyle(fontSize: 11, color: Colors.green.shade700, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Nöbet saatleri
            if (baslangic.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(Icons.access_time, size: 14, color: Colors.blue.shade700),
                    const SizedBox(width: 6),
                    Text(
                      bitis.isNotEmpty ? '$baslangic – $bitis' : 'Başlangıç: $baslangic',
                      style: TextStyle(fontSize: 12, color: Colors.blue.shade700, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ],

            if (eczane.adres != null && eczane.adres!.isNotEmpty) ...[
              const SizedBox(height: 10),
              const Divider(height: 1),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.location_on_outlined, size: 16, color: Colors.grey.shade500),
                  const SizedBox(width: 6),
                  Expanded(child: Text(eczane.adres!, style: TextStyle(fontSize: 13, color: Colors.grey.shade600))),
                ],
              ),
            ],
            if (eczane.telefon != null && eczane.telefon!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.phone_outlined, size: 16, color: Colors.grey.shade500),
                  const SizedBox(width: 6),
                  Text(eczane.telefon!, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                ],
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                if (eczane.telefon != null && eczane.telefon!.isNotEmpty)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => launchUrl(Uri.parse('tel:${eczane.telefon}')),
                      icon: const Icon(Icons.phone, size: 16),
                      label: const Text('Ara', style: TextStyle(fontSize: 13)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.primary,
                        side: const BorderSide(color: AppTheme.primary),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                if (eczane.telefon != null && eczane.lat != null) const SizedBox(width: 8),
                if (eczane.lat != null && eczane.lng != null)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => launchUrl(Uri.parse('https://maps.google.com/?q=${eczane.lat},${eczane.lng}')),
                      icon: const Icon(Icons.directions, size: 16),
                      label: const Text('Yol Tarifi', style: TextStyle(fontSize: 13)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
