import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/content_provider.dart';
import '../utils/theme.dart';
import 'content_detail_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});
  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  String _chip = 'tumu';
  final _df = DateFormat('dd MMMM yyyy • HH:mm', 'tr_TR');

  static const _chips = [
    {'key': 'tumu', 'label': 'Tümü'},
    {'key': 'acil', 'label': 'Acil'},
    {'key': 'duyuru', 'label': 'Duyurular'},
    {'key': 'etkinlik', 'label': 'Etkinlikler'},
    {'key': 'haber', 'label': 'Haberler'},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ContentProvider>().loadBildirimler();
    });
  }

  List<Map<String, dynamic>> _filtrele(List<Map<String, dynamic>> liste) {
    if (_chip == 'tumu') return liste;
    return liste.where((b) => (b['kategori'] ?? '').toString() == _chip).toList();
  }

  // Bildirimleri gruplara ayır
  Map<String, List<Map<String, dynamic>>> _grupla(List<Map<String, dynamic>> liste) {
    final onemli = <Map<String, dynamic>>[];
    final bugun = <Map<String, dynamic>>[];
    final dun = <Map<String, dynamic>>[];
    final hafta = <Map<String, dynamic>>[];
    final eski = <Map<String, dynamic>>[];

    final now = DateTime.now();
    final bugunBaslangic = DateTime(now.year, now.month, now.day);
    final dunBaslangic = bugunBaslangic.subtract(const Duration(days: 1));
    final haftaBaslangic = bugunBaslangic.subtract(const Duration(days: 7));

    for (final b in liste) {
      if (b['okundu'] == false && (b['acil'] == true || b['kategori'] == 'acil')) {
        onemli.add(b);
        continue;
      }
      final t = DateTime.tryParse(b['created_at'] ?? '');
      if (t == null) { eski.add(b); continue; }
      if (t.isAfter(bugunBaslangic)) {
        bugun.add(b);
      } else if (t.isAfter(dunBaslangic)) {
        dun.add(b);
      } else if (t.isAfter(haftaBaslangic)) {
        hafta.add(b);
      } else {
        eski.add(b);
      }
    }

    final result = <String, List<Map<String, dynamic>>>{};
    if (onemli.isNotEmpty) result['ÖNEMLİ BİLDİRİMLER'] = onemli;
    if (bugun.isNotEmpty) result['BUGÜN'] = bugun;
    if (dun.isNotEmpty) result['DÜN'] = dun;
    if (hafta.isNotEmpty) result['BU HAFTA'] = hafta;
    if (eski.isNotEmpty) result['DAHA ESKİ'] = eski;
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final cp = context.watch<ContentProvider>();
    final filtrelendi = _filtrele(cp.bildirimler);
    final gruplar = _grupla(filtrelendi);

    return Scaffold(
      backgroundColor: AppColors.arkaplan,
      body: SafeArea(
        child: Column(
          children: [
            // ─── HEADER ─────────────────────────────────────────────────
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(20, 16, 16, 12),
              child: Row(
                children: [
                  const Expanded(
                    child: Text('Bildirimler',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.anaMetin)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.done_all_rounded, color: AppColors.anaMavi),
                    tooltip: 'Tümünü okundu yap',
                    onPressed: () => cp.bildirimlerTumunuOku(),
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings_outlined, color: AppColors.anaMetin),
                    onPressed: () => _ayarlarAc(context, cp),
                  ),
                ],
              ),
            ),
            // ─── FİLTRE CHİPLERİ ────────────────────────────────────────
            Container(
              color: Colors.white,
              child: Column(
                children: [
                  SizedBox(
                    height: 48,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      itemCount: _chips.length,
                      itemBuilder: (ctx, i) {
                        final c = _chips[i];
                        final sel = _chip == c['key'];
                        return GestureDetector(
                          onTap: () => setState(() => _chip = c['key']!),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            decoration: BoxDecoration(
                              color: sel ? AppColors.anaMavi : Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: sel ? AppColors.anaMavi : const Color(0xFFDDE4F0), width: 1.5),
                            ),
                            child: Text(c['label']!,
                                style: TextStyle(
                                    fontSize: 13, fontWeight: FontWeight.w600,
                                    color: sel ? Colors.white : AppColors.ikinciMetin)),
                          ),
                        );
                      },
                    ),
                  ),
                  const Divider(height: 1, color: Color(0xFFEAEFF6)),
                ],
              ),
            ),

            // ─── BİLDİRİM LİSTESİ ───────────────────────────────────────
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async => cp.loadBildirimler(),
                color: AppColors.anaMavi,
                child: cp.bildirimler.isEmpty
                    ? ListView(
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.5,
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.notifications_off_outlined, size: 64, color: Color(0xFFCDD9E8)),
                                SizedBox(height: 16),
                                Text('Bildirim Yok', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.anaMetin)),
                                SizedBox(height: 8),
                                Text('Yeni duyurular geldiğinde\nburada görünecek', textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 14, color: AppColors.ikinciMetin, height: 1.5)),
                              ],
                            ),
                          ),
                        ],
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(top: 8, bottom: 80),
                        itemCount: _toplamItem(gruplar),
                        itemBuilder: (ctx, globalIdx) => _buildItem(ctx, gruplar, globalIdx, cp),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _toplamItem(Map<String, List<Map<String, dynamic>>> gruplar) {
    int count = 0;
    for (final g in gruplar.entries) {
      count += 1 + g.value.length; // header + items
    }
    return count;
  }

  Widget _buildItem(BuildContext ctx, Map<String, List<Map<String, dynamic>>> gruplar, int globalIdx, ContentProvider cp) {
    int cursor = 0;
    for (final entry in gruplar.entries) {
      if (cursor == globalIdx) {
        // Section header
        return _SectionHeader(title: entry.key);
      }
      cursor++;
      for (int i = 0; i < entry.value.length; i++) {
        if (cursor == globalIdx) {
          final b = entry.value[i];
          return _BildirimKarti(
            bildirim: b,
            df: _df,
            onTap: () {
              cp.bildirimOku(b['id']);
              if (b['icerik_id'] != null) {
                Navigator.push(ctx, MaterialPageRoute(
                    builder: (_) => ContentDetailScreen(icerikId: b['icerik_id'])));
              } else {
                _detayGoster(ctx, b);
              }
            },
            onSil: () => cp.bildirimSil(b['id']),
          );
        }
        cursor++;
      }
    }
    return const SizedBox.shrink();
  }

  void _detayGoster(BuildContext ctx, Map<String, dynamic> b) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(color: AppColors.acikMavi, borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.notifications_rounded, color: AppColors.anaMavi),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(b['baslik'] ?? '', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16))),
                IconButton(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close)),
              ],
            ),
            const SizedBox(height: 14),
            Text(b['mesaj'] ?? '', style: const TextStyle(fontSize: 14, height: 1.65, color: AppColors.ikinciMetin)),
            if (b['created_at'] != null) ...[
              const SizedBox(height: 14),
              Text(_df.format(DateTime.parse(b['created_at'])),
                  style: const TextStyle(fontSize: 12, color: AppColors.ikinciMetin)),
            ],
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _ayarlarAc(BuildContext ctx, ContentProvider cp) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Bildirim Ayarları', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.anaMetin)),
            const SizedBox(height: 4),
            const Text('Bildirimleri almak istemediğiniz kategorileri engelleyin.',
                style: TextStyle(fontSize: 13, color: AppColors.ikinciMetin)),
            const SizedBox(height: 16),
            ...cp.kategoriler.map((k) {
              final engelli = cp.engelliKategoriIds.contains(k.id);
              return SwitchListTile.adaptive(
                dense: true,
                title: Text('${AppTheme.kategoriEmoji(k.slug)} ${k.ad}',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                value: !engelli,
                activeColor: AppColors.anaMavi,
                onChanged: (v) {
                  final set = Set<int>.from(cp.engelliKategoriIds);
                  if (!v) set.add(k.id); else set.remove(k.id);
                  cp.updateKategoriEngelleme(set);
                },
              );
            }),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ─── BÖLÜM BAŞLIĞI ───────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
      child: Text(title,
          style: const TextStyle(
              fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.ikinciMetin, letterSpacing: 0.8)),
    );
  }
}

// ─── BİLDİRİM KARTI ──────────────────────────────────────────────────────────

class _BildirimKarti extends StatelessWidget {
  final Map<String, dynamic> bildirim;
  final DateFormat df;
  final VoidCallback onTap;
  final VoidCallback onSil;

  const _BildirimKarti({required this.bildirim, required this.df, required this.onTap, required this.onSil});

  @override
  Widget build(BuildContext context) {
    final okundu = bildirim['okundu'] == true;
    final acil = bildirim['acil'] == true || bildirim['kategori'] == 'acil';
    final DateTime? tarih = DateTime.tryParse(bildirim['created_at'] ?? '');
    final String tarihStr = tarih != null ? df.format(tarih.toLocal()) : '';

    // Kategori rengini belirle
    final kategori = bildirim['kategori']?.toString();
    final renk = acil ? AppColors.acil : AppTheme.kategoriRenk(kategori);
    final ikon = acil ? Icons.notifications_active_rounded : AppTheme.kategoriIkon(kategori);

    return Dismissible(
      key: Key('bildirim_${bildirim['id']}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        decoration: BoxDecoration(color: AppColors.acil, borderRadius: BorderRadius.circular(16)),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete_outline_rounded, color: Colors.white, size: 24),
            SizedBox(height: 2),
            Text('Sil', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
      onDismissed: (_) => onSil(),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: okundu ? Colors.white : AppColors.acikMavi,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: okundu ? const Color(0xFFEAEFF6) : AppColors.anaMavi.withValues(alpha: 0.15),
            ),
            boxShadow: const [BoxShadow(color: Color(0x08000000), blurRadius: 6, offset: Offset(0, 2))],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // İkon
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: renk.withValues(alpha: okundu ? 0.10 : 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(ikon, color: renk, size: 22),
                  ),
                  if (!okundu)
                    Positioned(
                      right: 0, top: 0,
                      child: Container(
                        width: 10, height: 10,
                        decoration: BoxDecoration(
                          color: acil ? AppColors.acil : AppColors.anaMavi,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              // İçerik
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(bildirim['baslik'] ?? '',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: okundu ? FontWeight.w500 : FontWeight.w700,
                            color: AppColors.anaMetin,
                            height: 1.3)),
                    if (tarihStr.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(tarihStr, style: const TextStyle(fontSize: 11, color: AppColors.ikinciMetin)),
                    ],
                    if ((bildirim['mesaj'] ?? '').toString().isNotEmpty) ...[
                      const SizedBox(height: 5),
                      Text(bildirim['mesaj'] ?? '', maxLines: 2, overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 12.5, height: 1.45,
                              color: okundu ? AppColors.ikinciMetin : const Color(0xFF4A5568))),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.chevron_right_rounded, size: 20, color: Color(0xFFCDD9E8)),
            ],
          ),
        ),
      ),
    );
  }
}
