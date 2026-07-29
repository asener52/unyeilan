import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:intl/intl.dart';
import '../models/icerik.dart';
import '../providers/content_provider.dart';
import '../utils/theme.dart';
import '../config/api_config.dart';
import 'package:provider/provider.dart';

class ContentDetailScreen extends StatefulWidget {
  final int icerikId;
  const ContentDetailScreen({super.key, required this.icerikId});

  @override
  State<ContentDetailScreen> createState() => _ContentDetailScreenState();
}

class _ContentDetailScreenState extends State<ContentDetailScreen> {
  Icerik? _icerik;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    final item = await context.read<ContentProvider>().getIcerikDetail(widget.icerikId);
    if (mounted) setState(() { _icerik = item; _loading = false; _error = item == null ? 'İçerik bulunamadı' : null; });
  }

  void _paylasimYap(Icerik i) {
    final baseUrl = ApiConfig.baseUrl.replaceAll('/api', '');
    final metin = '${i.baslik}\n\n${i.ozet ?? ''}\n\n$baseUrl/icerik/${i.id}';
    Clipboard.setData(ClipboardData(text: metin));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(children: [
          Icon(Icons.check_circle_rounded, color: Colors.white, size: 16),
          SizedBox(width: 8),
          Text('Bağlantı panoya kopyalandı'),
        ]),
        backgroundColor: AppColors.basarili,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return _LoadingScaffold();
    if (_error != null || _icerik == null) return _ErrorScaffold(error: _error ?? 'Hata', onRetry: _load);

    final i = _icerik!;
    final baseUrl = ApiConfig.baseUrl.replaceAll('/api', '');
    final renk = AppTheme.kategoriRenk(i.kategoriSlug);
    final df = DateFormat('dd MMMM yyyy, HH:mm', 'tr_TR');

    return Scaffold(
      backgroundColor: AppColors.arkaplan,
      body: CustomScrollView(
        slivers: [
          // ─── SLIVER APP BAR ─────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: i.kapakResmi != null ? 260 : 0,
            pinned: true,
            stretch: true,
            backgroundColor: AppColors.lacivermavi,
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                icon: const Icon(Icons.share_outlined),
                tooltip: 'Paylaş',
                onPressed: () => _paylasimYap(i),
              ),
            ],
            flexibleSpace: i.kapakResmi != null
                ? FlexibleSpaceBar(
                    stretchModes: const [StretchMode.zoomBackground, StretchMode.blurBackground],
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        CachedNetworkImage(
                          imageUrl: '$baseUrl${i.kapakResmi}',
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [renk.withValues(alpha: 0.6), renk],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                          ),
                          errorWidget: (_, __, ___) => Container(
                            color: renk.withValues(alpha: 0.15),
                            child: Center(child: Icon(AppTheme.kategoriIkon(i.kategoriSlug), size: 72, color: renk.withValues(alpha: 0.4))),
                          ),
                        ),
                        // Gradient overlay
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.black.withValues(alpha: 0.4), Colors.transparent, Colors.black.withValues(alpha: 0.15)],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                stops: const [0.0, 0.4, 1.0],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : null,
          ),

          // ─── İÇERİK ─────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              color: AppColors.arkaplan,
              child: Column(
                children: [
                  // Ana içerik kartı
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Kategori + önemli badge
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                              decoration: BoxDecoration(color: renk.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
                              child: Row(mainAxisSize: MainAxisSize.min, children: [
                                Icon(AppTheme.kategoriIkon(i.kategoriSlug), size: 13, color: renk),
                                const SizedBox(width: 5),
                                Text(i.kategoriAd ?? AppTheme.kategoriLabel(i.kategoriSlug),
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: renk)),
                              ]),
                            ),
                            if (i.onemli) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(color: AppColors.acil.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                                child: const Text('ÖNEMLİ',
                                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.acil, letterSpacing: 0.5)),
                              ),
                            ],
                            if (i.mahalleAd != null) ...[
                              const Spacer(),
                              Icon(Icons.location_on_rounded, size: 13, color: AppColors.ikinciMetin),
                              const SizedBox(width: 3),
                              Text(i.mahalleAd!, style: const TextStyle(fontSize: 12, color: AppColors.ikinciMetin)),
                            ],
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Başlık
                        Text(i.baslik,
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.anaMetin, height: 1.35, letterSpacing: -0.3)),
                        const SizedBox(height: 12),

                        // Tarih + görüntülenme
                        Row(
                          children: [
                            Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.ikinciMetin),
                            const SizedBox(width: 5),
                            Text(df.format((i.yayinTarihi ?? i.createdAt).toLocal()),
                                style: const TextStyle(fontSize: 12, color: AppColors.ikinciMetin)),
                            const SizedBox(width: 16),
                            Icon(Icons.remove_red_eye_outlined, size: 14, color: AppColors.ikinciMetin),
                            const SizedBox(width: 5),
                            Text('${i.goruntulenme} görüntülenme',
                                style: const TextStyle(fontSize: 12, color: AppColors.ikinciMetin)),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Özel detaylar
                  if (i.kategoriSlug == 'cenaze' && i.detay != null) ...[
                    _buildCenazeDetay(i.detay!),
                    const SizedBox(height: 8),
                  ],
                  if (i.kategoriSlug == 'imar' && i.detay != null) ...[
                    _buildImarDetay(i.detay!),
                    const SizedBox(height: 8),
                  ],

                  // İçerik metni
                  if (i.ozet != null && i.ozet!.isNotEmpty || i.icerik != null && i.icerik!.isNotEmpty)
                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Özet
                          if (i.ozet != null && i.ozet!.isNotEmpty) ...[
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: renk.withValues(alpha: 0.06),
                                borderRadius: BorderRadius.circular(12),
                                border: Border(left: BorderSide(color: renk, width: 3)),
                              ),
                              child: Text(i.ozet!,
                                  style: TextStyle(fontSize: 15, color: AppColors.anaMetin, height: 1.6, fontStyle: FontStyle.italic)),
                            ),
                            if (i.icerik != null && i.icerik!.isNotEmpty) const SizedBox(height: 20),
                          ],

                          // Ana içerik HTML
                          if (i.icerik != null && i.icerik!.isNotEmpty)
                            Html(
                              data: i.icerik!.contains('<') ? i.icerik! : '<p>${i.icerik!.replaceAll('\n', '<br>')}</p>',
                              style: {
                                'body': Style(margin: Margins.zero, padding: HtmlPaddings.zero),
                                'p': Style(fontSize: FontSize(15), lineHeight: LineHeight(1.75), color: AppColors.anaMetin),
                                'a': Style(color: AppColors.anaMavi),
                                'h1': Style(fontSize: FontSize(20), fontWeight: FontWeight.w700, color: AppColors.anaMetin),
                                'h2': Style(fontSize: FontSize(18), fontWeight: FontWeight.w700, color: AppColors.anaMetin),
                                'h3': Style(fontSize: FontSize(16), fontWeight: FontWeight.w600, color: AppColors.anaMetin),
                                'li': Style(fontSize: FontSize(15), lineHeight: LineHeight(1.65), color: AppColors.anaMetin),
                              },
                            ),
                        ],
                      ),
                    ),

                  // Medya galerisi
                  if (i.medyalar.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Icon(Icons.photo_library_outlined, size: 18, color: AppColors.anaMetin),
                            const SizedBox(width: 8),
                            const Text('Fotoğraflar', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.anaMetin)),
                          ]),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 130,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: i.medyalar.length,
                              itemBuilder: (_, idx) {
                                final m = i.medyalar[idx];
                                if (m['dosya_tipi'] == 'resim') {
                                  return GestureDetector(
                                    onTap: () => _showFullImage(context, '$baseUrl${m['dosya_url']}'),
                                    child: Hero(
                                      tag: 'medya_$idx',
                                      child: Container(
                                        width: 130,
                                        margin: const EdgeInsets.only(right: 10),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(12),
                                          boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 6)],
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(12),
                                          child: CachedNetworkImage(imageUrl: '$baseUrl${m['dosya_url']}', fit: BoxFit.cover),
                                        ),
                                      ),
                                    ),
                                  );
                                }
                                return Container(
                                  width: 110, margin: const EdgeInsets.only(right: 10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF5F8FC),
                                    borderRadius: BorderRadius.circular(12),
                                    border: const Border.fromBorderSide(BorderSide(color: AppColors.cizgi)),
                                  ),
                                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                                    const Icon(Icons.picture_as_pdf, color: AppColors.acil, size: 36),
                                    const SizedBox(height: 6),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 6),
                                      child: Text(m['orijinal_ad'] ?? 'Dosya',
                                          style: const TextStyle(fontSize: 10, color: AppColors.ikinciMetin),
                                          textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
                                    ),
                                  ]),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCenazeDetay(Map<String, dynamic> d) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.cizgi),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(color: AppColors.ikinciMetin.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.church_outlined, color: AppColors.ikinciMetin, size: 20),
              ),
              const SizedBox(width: 10),
              const Text('Cenaze Bilgileri', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.anaMetin)),
            ]),
            const SizedBox(height: 12),
            if (d['vefat_eden'] != null) _row(Icons.person_outline, 'Vefat Eden', d['vefat_eden']),
            if (d['vefat_tarihi'] != null) _row(Icons.calendar_today_outlined, 'Vefat Tarihi', d['vefat_tarihi'].toString().substring(0, 10)),
            if (d['cenaze_namazi_yeri'] != null) _row(Icons.mosque_outlined, 'Namaz Yeri', d['cenaze_namazi_yeri']),
            if (d['defin_yeri'] != null) _row(Icons.place_outlined, 'Defin Yeri', d['defin_yeri']),
            if (d['yakinlari'] != null) _row(Icons.group_outlined, 'Yakınları', d['yakinlari']),
          ],
        ),
      ),
    );
  }

  Widget _buildImarDetay(Map<String, dynamic> d) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.etkinlik.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.etkinlik.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(color: AppColors.etkinlik.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
                child: Icon(Icons.map_outlined, color: AppColors.etkinlik, size: 20),
              ),
              const SizedBox(width: 10),
              const Text('İmar Bilgileri', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.anaMetin)),
            ]),
            const SizedBox(height: 12),
            if (d['imar_turu'] != null) _row(Icons.map_outlined, 'İmar Türü', d['imar_turu']),
            if (d['ada_parsel'] != null) _row(Icons.grid_on_outlined, 'Ada/Parsel', d['ada_parsel']),
            if (d['son_itiraz_tarihi'] != null) _row(Icons.event_outlined, 'Son İtiraz Tarihi', d['son_itiraz_tarihi'].toString().substring(0, 10)),
          ],
        ),
      ),
    );
  }

  Widget _row(IconData icon, String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, size: 15, color: AppColors.ikinciMetin),
      const SizedBox(width: 8),
      Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.anaMetin)),
      Expanded(child: Text(value, style: const TextStyle(fontSize: 13, color: AppColors.ikinciMetin))),
    ]),
  );

  void _showFullImage(BuildContext context, String url) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: url));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Bağlantı kopyalandı'), behavior: SnackBarBehavior.floating),
              );
            },
          ),
        ],
      ),
      body: Center(child: InteractiveViewer(child: CachedNetworkImage(imageUrl: url))),
    )));
  }
}

// ─── LOADING SCAFFOLD ─────────────────────────────────────────────────────────

class _LoadingScaffold extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.arkaplan,
      appBar: AppBar(backgroundColor: AppColors.lacivermavi),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _shimmer(height: 240, width: double.infinity),
            const SizedBox(height: 20),
            _shimmer(height: 24, width: 100),
            const SizedBox(height: 12),
            _shimmer(height: 28, width: double.infinity),
            const SizedBox(height: 8),
            _shimmer(height: 20, width: 200),
            const SizedBox(height: 20),
            _shimmer(height: 16, width: double.infinity),
            const SizedBox(height: 8),
            _shimmer(height: 16, width: double.infinity),
            const SizedBox(height: 8),
            _shimmer(height: 16, width: 280),
          ],
        ),
      ),
    );
  }

  Widget _shimmer({required double height, required double width}) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: const Color(0xFFEAEFF6),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}

// ─── ERROR SCAFFOLD ───────────────────────────────────────────────────────────

class _ErrorScaffold extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  const _ErrorScaffold({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.arkaplan,
      appBar: AppBar(backgroundColor: AppColors.lacivermavi),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80, height: 80,
                decoration: const BoxDecoration(color: Color(0xFFFEE2E2), shape: BoxShape.circle),
                child: const Icon(Icons.wifi_off_rounded, size: 40, color: AppColors.acil),
              ),
              const SizedBox(height: 20),
              const Text('İçeriğe ulaşılamıyor',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.anaMetin)),
              const SizedBox(height: 8),
              const Text('İnternet bağlantınızı kontrol ederek tekrar deneyebilirsiniz.',
                  textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: AppColors.ikinciMetin, height: 1.5)),
              const SizedBox(height: 28),
              SizedBox(
                width: 160,
                child: ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('Tekrar Dene'),
                  style: ElevatedButton.styleFrom(minimumSize: const Size(0, 48)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
