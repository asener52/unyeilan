import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/content_provider.dart';
import '../utils/theme.dart';
import '../models/icerik.dart';
import 'content_detail_screen.dart';

class DuyurularScreen extends StatefulWidget {
  const DuyurularScreen({super.key});

  @override
  State<DuyurularScreen> createState() => _DuyurularScreenState();
}

class _DuyurularScreenState extends State<DuyurularScreen> {
  String? _seciliSlug;
  bool _aramaAcik = false;
  String _arama = '';
  final _aramaCtrl = TextEditingController();

  static const _chips = [
    {'slug': null, 'label': 'Tümü'},
    {'slug': 'altyapi', 'label': 'Altyapı'},
    {'slug': 'ulasim', 'label': 'Ulaşım'},
    {'slug': 'cevre', 'label': 'Çevre'},
    {'slug': 'kultur', 'label': 'Kültür'},
    {'slug': 'spor', 'label': 'Spor'},
    {'slug': 'saglik', 'label': 'Sağlık'},
    {'slug': 'egitim', 'label': 'Eğitim'},
    {'slug': 'ihale', 'label': 'İhale'},
    {'slug': 'duyuru', 'label': 'Diğer'},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _yukle());
  }

  @override
  void dispose() {
    _aramaCtrl.dispose();
    super.dispose();
  }

  Future<void> _yukle() async {
    final cp = context.read<ContentProvider>();
    if (cp.kategoriler.isEmpty) await cp.loadKategoriler();
    await cp.loadIcerikler(refresh: true);
  }

  Future<void> _refresh() => context.read<ContentProvider>().loadIcerikler(refresh: true);

  List<Icerik> _filtrele(List<Icerik> liste) {
    var r = liste.toList();
    if (_seciliSlug != null) r = r.where((i) => i.kategoriSlug == _seciliSlug).toList();
    if (_arama.length >= 2) {
      r = r.where((i) =>
        i.baslik.toLowerCase().contains(_arama.toLowerCase()) ||
        (i.ozet?.toLowerCase().contains(_arama.toLowerCase()) ?? false)
      ).toList();
    }
    return r;
  }

  @override
  Widget build(BuildContext context) {
    final cp = context.watch<ContentProvider>();
    final liste = _filtrele(cp.icerikler);

    return Scaffold(
      backgroundColor: AppColors.arkaplan,
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          // ─── APP BAR ─────────────────────────────────────────────────
          SliverAppBar(
            pinned: true,
            backgroundColor: Colors.white,
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            leading: IconButton(
              tooltip: _aramaAcik ? 'Aramayı kapat' : 'Ana sayfaya dön',
              icon: Icon(_aramaAcik ? Icons.close_rounded : Icons.arrow_back_rounded, color: AppColors.anaMetin),
              onPressed: () {
                if (_aramaAcik) {
                  setState(() { _aramaAcik = false; _arama = ''; _aramaCtrl.clear(); });
                } else {
                  Navigator.of(context).maybePop();
                }
              },
            ),
            leadingWidth: 56,
            title: _aramaAcik
                ? TextField(
                    controller: _aramaCtrl,
                    autofocus: true,
                    style: const TextStyle(fontSize: 16, color: AppColors.anaMetin),
                    cursorColor: AppColors.anaMavi,
                    decoration: const InputDecoration(
                      hintText: 'Duyuru ara...',
                      hintStyle: TextStyle(color: AppColors.ikinciMetin),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      fillColor: Colors.transparent,
                      filled: false,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onChanged: (v) => setState(() => _arama = v),
                  )
                : const Text('Duyurular',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.anaMetin)),
            centerTitle: true,
            actions: [
              IconButton(
                icon: Icon(_aramaAcik ? Icons.close : Icons.search, color: AppColors.anaMetin),
                onPressed: () {
                  setState(() {
                    _aramaAcik = !_aramaAcik;
                    if (!_aramaAcik) { _arama = ''; _aramaCtrl.clear(); }
                  });
                },
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(height: 1, color: const Color(0xFFEAEFF6)),
            ),
          ),
          // ─── KATEGORİ CHİPLERİ ───────────────────────────────────────
          SliverPersistentHeader(
            pinned: true,
            delegate: _ChipBarDelegate(
              kategoriler: _chips,
              secili: _seciliSlug,
              onSec: (slug) => setState(() => _seciliSlug = slug),
            ),
          ),
        ],
        body: RefreshIndicator(
          onRefresh: _refresh,
          color: AppColors.anaMavi,
          child: _buildBody(cp, liste),
        ),
      ),
    );
  }

  Widget _buildBody(ContentProvider cp, List<Icerik> liste) {
    // Loading
    if (cp.loading && liste.isEmpty) {
      return ListView(
        padding: const EdgeInsets.only(top: 8),
        children: List.generate(5, (_) => _DuyuruSkeletonItem()),
      );
    }

    // Boş
    if (liste.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(color: AppColors.acikMavi, shape: BoxShape.circle),
                child: const Icon(Icons.campaign_outlined, size: 40, color: AppColors.anaMavi),
              ),
              const SizedBox(height: 20),
              const Text('Duyuru Bulunamadı', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.anaMetin)),
              const SizedBox(height: 8),
              const Text('Seçili kategoride henüz duyuru yayınlanmamış.', textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: AppColors.ikinciMetin, height: 1.5)),
              const SizedBox(height: 24),
              SizedBox(
                width: 140,
                child: ElevatedButton.icon(
                  onPressed: _refresh,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Yenile'),
                  style: ElevatedButton.styleFrom(minimumSize: const Size(0, 44)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Hata
    if (cp.error != null && liste.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 56, color: AppColors.ikinciMetin),
            const SizedBox(height: 16),
            const Text('İçeriklere ulaşılamıyor', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            const Text('İnternet bağlantınızı kontrol ederek tekrar deneyin.',
                textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: AppColors.ikinciMetin)),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _refresh, child: const Text('Tekrar Dene')),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 80),
      itemCount: liste.length + (cp.loadingMore ? 1 : 0),
      itemBuilder: (ctx, i) {
        if (i == liste.length) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator(color: AppColors.anaMavi, strokeWidth: 2)),
          );
        }
        return _DuyuruListeKarti(
          icerik: liste[i],
          onTap: () => Navigator.push(ctx, MaterialPageRoute(builder: (_) => ContentDetailScreen(icerikId: liste[i].id))),
        );
      },
    );
  }
}

// ─── KATEGORİ CHİP BARI ──────────────────────────────────────────────────────

class _ChipBarDelegate extends SliverPersistentHeaderDelegate {
  final List<Map<String, dynamic>> kategoriler;
  final String? secili;
  final ValueChanged<String?> onSec;

  const _ChipBarDelegate({required this.kategoriler, required this.secili, required this.onSec});

  @override double get minExtent => 52;
  @override double get maxExtent => 52;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        itemCount: kategoriler.length,
        itemBuilder: (ctx, i) {
          final kat = kategoriler[i];
          final slug = kat['slug'] as String?;
          final label = kat['label'] as String;
          final selected = secili == slug;
          final color = slug == null ? AppColors.anaMavi : AppTheme.kategoriRenk(slug);

          return GestureDetector(
            onTap: () => onSec(slug),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: selected ? color : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: selected ? color : const Color(0xFFDDE4F0), width: 1.5),
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : AppColors.ikinciMetin,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _ChipBarDelegate old) => old.secili != secili;
}

// ─── DUYURU LİSTE KARTI (Mockup'a birebir) ───────────────────────────────────

class _DuyuruListeKarti extends StatelessWidget {
  final Icerik icerik;
  final VoidCallback onTap;
  const _DuyuruListeKarti({required this.icerik, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final renk = AppTheme.kategoriRenk(icerik.kategoriSlug);
    final ikon = AppTheme.kategoriIkon(icerik.kategoriSlug);
    final tarih = icerik.yayinTarihi ?? icerik.createdAt;
    final tarihStr = '${tarih.day} ${_ay(tarih.month)} ${tarih.year}';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFEAEFF6), width: 1),
          boxShadow: const [BoxShadow(color: Color(0x08000000), blurRadius: 6, offset: Offset(0, 2))],
        ),
        child: Row(
          children: [
            // Sol ikon şeridi
            Container(
              width: 70,
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: renk.withValues(alpha: 0.09),
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(15)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: renk.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(ikon, color: renk, size: 20),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    AppTheme.kategoriLabel(icerik.kategoriSlug).toUpperCase(),
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 8, fontWeight: FontWeight.w800, color: renk, letterSpacing: 0.3),
                  ),
                ],
              ),
            ),
            // İçerik
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 14, 8, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (icerik.onemli)
                      Container(
                        margin: const EdgeInsets.only(bottom: 5),
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.acil.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: const Text('ÖNEMLİ',
                            style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.acil, letterSpacing: 0.5)),
                      ),
                    Text(icerik.baslik, maxLines: 2, overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.anaMetin, height: 1.35)),
                    const SizedBox(height: 3),
                    Text(tarihStr, style: const TextStyle(fontSize: 11, color: AppColors.ikinciMetin)),
                    if (icerik.ozet != null && icerik.ozet!.isNotEmpty) ...[
                      const SizedBox(height: 5),
                      Text(icerik.ozet!, maxLines: 2, overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12.5, color: AppColors.ikinciMetin, height: 1.45)),
                    ],
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: Icon(Icons.chevron_right_rounded, size: 20, color: Color(0xFFCDD9E8)),
            ),
          ],
        ),
      ),
    );
  }

  static String _ay(int m) => const ['', 'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran', 'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'][m];
}

// ─── SKELETON ────────────────────────────────────────────────────────────────

class _DuyuruSkeletonItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      height: 90,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEAEFF6)),
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            decoration: const BoxDecoration(
              color: Color(0xFFF5F8FC),
              borderRadius: BorderRadius.horizontal(left: Radius.circular(15)),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(height: 13, width: double.infinity, decoration: BoxDecoration(color: const Color(0xFFF0F4FB), borderRadius: BorderRadius.circular(6))),
                  const SizedBox(height: 8),
                  Container(height: 10, width: 90, decoration: BoxDecoration(color: const Color(0xFFF0F4FB), borderRadius: BorderRadius.circular(6))),
                  const SizedBox(height: 7),
                  Container(height: 10, width: 220, decoration: BoxDecoration(color: const Color(0xFFF0F4FB), borderRadius: BorderRadius.circular(6))),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
