import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/auth_provider.dart';
import '../providers/content_provider.dart';
import '../utils/theme.dart';
import '../models/icerik.dart';
import '../services/konum_service.dart';

import 'content_detail_screen.dart';
import 'notifications_screen.dart';
import 'profile_screen.dart';
import 'harita_screen.dart';
import 'duyurular_screen.dart';
import 'hizmetler_screen.dart';
import 'webview_ekrani.dart';
import 'eczane_screen.dart';
import 'vergi_screen.dart';
import 'randevu_screen.dart';
import 'muhtar_screen.dart';
import 'acil_screen.dart';
import 'iletisim_screen.dart';
import 'sikayet_screen.dart';
import 'tesis_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  int _navIndex = 0;
  static DateTime? _sonKonum;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ContentProvider>().loadKategoriEngelleme();
      _konumIzniBaslat();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _konumKontrol();
  }

  void _konumKontrol() {
    final now = DateTime.now();
    if (_sonKonum == null || now.difference(_sonKonum!) >= const Duration(minutes: 30)) {
      _sonKonum = now;
      KonumService().sessizKonumGuncelle();
    }
  }

  Future<void> _konumIzniBaslat() async {
    final soruldu = await KonumService().izinSorulduMu();
    if (soruldu) { _konumKontrol(); return; }
    if (!mounted) return;
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 76, height: 76,
                decoration: const BoxDecoration(color: AppColors.acikMavi, shape: BoxShape.circle),
                child: const Icon(Icons.location_on_rounded, size: 38, color: AppColors.anaMavi),
              ),
              const SizedBox(height: 20),
              const Text('Konum İzni', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),
              const Text(
                'Bulunduğunuz mahalleye özel haberleri ve bildirimleri almanız için konumunuza erişmek istiyoruz.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: AppColors.ikinciMetin, height: 1.6),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(ctx).pop(true),
                  child: const Text('İzin Ver'),
                ),
              ),
              const SizedBox(height: 6),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Şimdi Değil', style: TextStyle(color: AppColors.ikinciMetin)),
              ),
            ],
          ),
        ),
      ),
    );
    await KonumService().izinSorulduIsaretle();
    if (result == true) {
      final izin = await KonumService().izinKontrol();
      if (izin && mounted) KonumService().sessizKonumGuncelle();
    }
  }

  @override
  Widget build(BuildContext context) {
    final okunmamis = context.watch<ContentProvider>().okunmamisBildirimSayisi;

    final screens = [
      _AnaSayfa(onTabSwitch: (i) => setState(() => _navIndex = i)),
      const HaritaScreen(),
      const NotificationsScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: AppColors.arkaplan,
      body: IndexedStack(index: _navIndex, children: screens),
      bottomNavigationBar: _BottomNav(
        current: _navIndex,
        badge: okunmamis,
        onTap: (i) {
          setState(() => _navIndex = i);
          if (i == 2) context.read<ContentProvider>().loadBildirimler();
        },
      ),
    );
  }
}

// ─── BOTTOM NAV (4 SEKME) ────────────────────────────────────────────────────

class _BottomNav extends StatelessWidget {
  final int current;
  final int badge;
  final ValueChanged<int> onTap;

  const _BottomNav({required this.current, required this.badge, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFEAEFF6), width: 1)),
        boxShadow: [BoxShadow(color: Color(0x0A000000), blurRadius: 16, offset: Offset(0, -4))],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 62,
          child: Row(
            children: [
              _NavBtn(icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: 'Ana Sayfa', active: current == 0, onTap: () => onTap(0)),
              _NavBtn(icon: Icons.map_outlined, activeIcon: Icons.map_rounded, label: 'Harita', active: current == 1, onTap: () => onTap(1)),
              _NavBtn(icon: Icons.notifications_outlined, activeIcon: Icons.notifications_rounded, label: 'Bildirimler', active: current == 2, badge: badge > 0 ? '$badge' : null, onTap: () => onTap(2)),
              _NavBtn(icon: Icons.person_outline_rounded, activeIcon: Icons.person_rounded, label: 'Profil', active: current == 3, onTap: () => onTap(3)),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavBtn extends StatelessWidget {
  final IconData icon, activeIcon;
  final String label;
  final bool active;
  final String? badge;
  final VoidCallback onTap;

  const _NavBtn({required this.icon, required this.activeIcon, required this.label, required this.active, required this.onTap, this.badge});

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.anaMavi : const Color(0xFF94A3B8);
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.symmetric(horizontal: active ? 16 : 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: active ? AppColors.acikMavi : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(active ? activeIcon : icon, color: color, size: 24),
                ),
                if (badge != null)
                  Positioned(
                    right: -2, top: -2,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(color: AppColors.acil, shape: BoxShape.circle),
                      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                      child: Text(badge!, textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700)),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 10, color: color, fontWeight: active ? FontWeight.w600 : FontWeight.w400)),
          ],
        ),
      ),
    );
  }
}

// ─── ANA SAYFA ────────────────────────────────────────────────────────────────

class _AnaSayfa extends StatefulWidget {
  final ValueChanged<int> onTabSwitch;
  const _AnaSayfa({required this.onTabSwitch});
  @override
  State<_AnaSayfa> createState() => _AnaSayfaState();
}

class _AnaSayfaState extends State<_AnaSayfa> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _init());
  }

  Future<void> _init() async {
    final cp = context.read<ContentProvider>();
    if (cp.kategoriler.isEmpty) await cp.loadKategoriler();
    if (cp.icerikler.isEmpty) await cp.loadIcerikler(refresh: true);
  }

  Future<void> _refresh() => context.read<ContentProvider>().loadIcerikler(refresh: true);

  @override
  Widget build(BuildContext context) {
    final cp = context.watch<ContentProvider>();
    final user = context.watch<AuthProvider>().user;
    final okunmamis = cp.okunmamisBildirimSayisi;
    final konum = user?.mahalleAd ?? 'Ünye, Ordu';

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.arkaplan,
      endDrawer: _AppDrawer(),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          color: AppColors.anaMavi,
          child: Stack(
            children: [
              ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  // ─── APP BAR ──────────────────────────────────────────
                  _AppBarWidget(
                    konum: konum,
                    okunmamis: okunmamis,
                    onNotifTap: () => widget.onTabSwitch(2),
                    onMenuTap: () => _scaffoldKey.currentState?.openEndDrawer(),
                  ),

                  // ─── 3 HIZLI BUTON ────────────────────────────────────
                  _UcHizliButon(),

                  // ─── HOŞ GELDİNİZ BANNER ─────────────────────────────
                  _KarsilamaBanner(),

                  const SizedBox(height: 20),

                  // ─── SENİN BELEDİYEN ─────────────────────────────────
                  _SeninBelediyen(),

                  const SizedBox(height: 20),

                  // ─── SON İÇERİKLER (card slider) ─────────────────────
                  _IcerikSlider(icerikler: cp.icerikler.take(6).toList(), loading: cp.loading),

                  const SizedBox(height: 20),

                  // ─── HAVA DURUMU ──────────────────────────────────────
                  _HavaDurumuKart(),

                  const SizedBox(height: 20),

                  // ─── HIZLI İŞLEMLER ───────────────────────────────────
                  _HizliIslemler(),

                  const SizedBox(height: 20),

                  // ─── DUYURULAR ────────────────────────────────────────
                  _AnaSayfaListeBolum(
                    baslik: 'Duyurular',
                    ikon: Icons.campaign_rounded,
                    renkTonu: AppColors.turkuaz,
                    slugFiltre: 'duyuru',
                    tumunuGorRoute: '/home',
                    icerikler: cp.icerikler,
                    loading: cp.loading,
                  ),

                  const SizedBox(height: 20),

                  // ─── HABERLER ─────────────────────────────────────────
                  _AnaSayfaListeBolum(
                    baslik: 'Haberler',
                    ikon: Icons.newspaper_rounded,
                    renkTonu: AppColors.anaMavi,
                    slugFiltre: 'haber',
                    tumunuGorRoute: '/home',
                    icerikler: cp.icerikler,
                    loading: cp.loading,
                  ),

                  const SizedBox(height: 100),
                ],
              ),

              // ─── YÜZEN 153 BUTONU ────────────────────────────────────
              Positioned(
                bottom: 24,
                right: 16,
                child: _Alo153Fab(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── APP BAR ─────────────────────────────────────────────────────────────────

class _AppBarWidget extends StatelessWidget {
  final String konum;
  final int okunmamis;
  final VoidCallback onNotifTap;
  final VoidCallback onMenuTap;

  const _AppBarWidget({required this.konum, required this.okunmamis, required this.onNotifTap, required this.onMenuTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          // Logo
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              'assets/images/logo.jpg',
              width: 44, height: 44,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 10),
          // Başlık + Konum
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Ünye Belediyesi',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.anaMetin, height: 1.1)),
                Row(
                  children: [
                    const Icon(Icons.location_on_rounded, size: 11, color: AppColors.acil),
                    const SizedBox(width: 2),
                    Text(konum, style: const TextStyle(fontSize: 11, color: AppColors.ikinciMetin, fontWeight: FontWeight.w500)),
                  ],
                ),
              ],
            ),
          ),
          // Arama
          GestureDetector(
            onTap: () {},
            child: Container(
              width: 38, height: 38,
              decoration: BoxDecoration(color: AppColors.arkaplan, borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.search_rounded, color: AppColors.anaMetin, size: 20),
            ),
          ),
          const SizedBox(width: 8),
          // Bildirim
          GestureDetector(
            onTap: onNotifTap,
            child: Stack(
              children: [
                Container(
                  width: 38, height: 38,
                  decoration: BoxDecoration(color: AppColors.arkaplan, borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.notifications_outlined, color: AppColors.anaMetin, size: 20),
                ),
                if (okunmamis > 0)
                  Positioned(
                    right: 6, top: 6,
                    child: Container(
                      width: 8, height: 8,
                      decoration: const BoxDecoration(color: AppColors.acil, shape: BoxShape.circle),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Hamburger menü
          GestureDetector(
            onTap: onMenuTap,
            child: Container(
              width: 38, height: 38,
              decoration: BoxDecoration(color: AppColors.arkaplan, borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.menu_rounded, color: AppColors.anaMetin, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── 3 HIZLI BUTON ───────────────────────────────────────────────────────────

class _UcHizliButon extends StatelessWidget {
  void _eBelediyePopup(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Tutaç
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40, height: 4,
                decoration: BoxDecoration(color: AppColors.cizgi, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            // Başlık
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
              child: Row(children: [
                Container(
                  width: 38, height: 38,
                  decoration: BoxDecoration(color: AppColors.acil.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.language_rounded, color: AppColors.acil, size: 20),
                ),
                const SizedBox(width: 12),
                const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('E-Belediye Hizmetleri', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.anaMetin)),
                  Text('Ünye Belediyesi online hizmetler', style: TextStyle(fontSize: 11, color: AppColors.ikinciMetin)),
                ]),
              ]),
            ),
            const Divider(color: AppColors.cizgi, height: 24),
            // Hizmet listesi
            ..._eHizmetler(context),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  List<Widget> _eHizmetler(BuildContext ctx) {
    final hizmetler = [
      _EHizmet(ikon: Icons.description_outlined, renk: const Color(0xFF0369A1), baslik: 'E-Dilekçe', aciklama: 'Online dilekçe ver', url: 'https://ebysweb.belediye.gov.tr/dilekce/login'),
      _EHizmet(ikon: Icons.credit_card_rounded, renk: AppColors.basarili, baslik: 'E-Ödeme (e-Devlet)', aciklama: 'turkiye.gov.tr üzerinden öde', url: 'https://turkiye.gov.tr/unye-belediyesi'),
      _EHizmet(ikon: Icons.payment_rounded, renk: AppColors.turkuaz, baslik: 'E-Ödeme (e-Belediye)', aciklama: 'Belediye ödeme portalı', url: 'https://canli.belediye.gov.tr/vpos/debt-inquiry/natural-type-person-form?token=2a69005b-16a7-47e4-ac56-e3e879380630'),
      _EHizmet(ikon: Icons.map_outlined, renk: AppColors.etkinlik, baslik: 'E-Plan Uygulamaları', aciklama: 'İmar planları ve sorgular', url: 'https://keos.unye.bel.tr/webaskiv2/'),
      _EHizmet(ikon: Icons.home_work_outlined, renk: AppColors.lacivermavi, baslik: 'E-İmar Başvuru', aciklama: 'İmar başvurusu yap', url: 'https://eimar.unye.bel.tr/'),
      _EHizmet(ikon: Icons.location_searching_rounded, renk: AppColors.uyari, baslik: 'İmar Durumu Sorgula', aciklama: 'Parsel imar durumu', url: 'https://keos.unye.bel.tr/imardurumu/index.aspx'),
      _EHizmet(ikon: Icons.explore_rounded, renk: AppColors.anaMavi, baslik: 'Kent Rehberi', aciklama: 'Şehir bilgi sistemi', url: 'https://keos.unye.bel.tr/keos/'),
    ];

    return hizmetler.map((h) => InkWell(
      onTap: () {
        Navigator.pop(ctx);
        WebViewEkrani.ac(ctx, url: h.url, baslik: h.baslik, ikon: h.ikon, ikonRenk: h.renk);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.cizgi, width: 0.5)),
          ),
          child: Row(children: [
            Container(
              width: 38, height: 38,
              decoration: BoxDecoration(color: h.renk.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
              child: Icon(h.ikon, color: h.renk, size: 19),
            ),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(h.baslik, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.anaMetin)),
              Text(h.aciklama, style: const TextStyle(fontSize: 11, color: AppColors.ikinciMetin)),
            ])),
            const Icon(Icons.open_in_new_rounded, size: 16, color: AppColors.ikinciMetin),
          ]),
        ),
      ),
    )).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: Row(
        children: [
          Expanded(
            child: _HizliBtn(
              renk: AppColors.acil,
              ikon: Icons.language_rounded,
              baslik: 'E-Belediye\nHizmetleri',
              onTap: () => _eBelediyePopup(context),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _HizliBtn(
              renk: AppColors.lacivermavi,
              ikon: Icons.credit_card_rounded,
              baslik: 'Borç\nSorgulama',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const VergiScreen())),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _HizliBtn(
              renk: AppColors.basarili,
              ikon: Icons.support_agent_rounded,
              baslik: 'Çağrı\nMerkezi',
              onTap: () async {
                final uri = Uri(scheme: 'tel', path: '04523231941');
                if (await canLaunchUrl(uri)) launchUrl(uri);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _EHizmet {
  final IconData ikon;
  final Color renk;
  final String baslik;
  final String aciklama;
  final String url;
  const _EHizmet({required this.ikon, required this.renk, required this.baslik, required this.aciklama, required this.url});
}

class _HizliBtn extends StatelessWidget {
  final Color renk;
  final IconData ikon;
  final String baslik;
  final VoidCallback onTap;

  const _HizliBtn({required this.renk, required this.ikon, required this.baslik, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: renk,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: renk.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 3))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(ikon, color: Colors.white, size: 26),
            const SizedBox(height: 6),
            Text(baslik,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700, height: 1.3)),
          ],
        ),
      ),
    );
  }
}

// ─── HOŞ GELDİNİZ BANNER ─────────────────────────────────────────────────────

class _KarsilamaBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.lacivermavi, AppColors.anaMavi],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: AppColors.lacivermavi.withValues(alpha: 0.25), blurRadius: 14, offset: const Offset(0, 4))],
        ),
        child: Stack(
          children: [
            // Dekoratif daire
            Positioned(
              right: -20, bottom: -30,
              child: Container(
                width: 130, height: 130,
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.06), shape: BoxShape.circle),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.location_on_rounded, size: 12, color: Colors.white70),
                      SizedBox(width: 4),
                      Text('Ünye • Ordu', style: TextStyle(fontSize: 12, color: Colors.white70, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Text('Hoş Geldiniz!',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.5, height: 1.1)),
                const SizedBox(height: 6),
                const Text('Ordu\'nun incisi, Karadeniz\'in şehri',
                    style: TextStyle(fontSize: 13, color: Colors.white70, height: 1.4)),
              ],
            ),
            // Sağ köşe emoji/ikon
            const Positioned(
              right: 0, top: 0,
              child: Text('🏖️', style: TextStyle(fontSize: 52)),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── SENİN BELEDİYEN ─────────────────────────────────────────────────────────

class _SeninBelediyen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 12),
            child: Text('Senin Belediyen',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.anaMetin)),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _DaireselIkon(
                ikon: Icons.newspaper_rounded,
                renk: AppColors.acil,
                label: 'Haberler',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DuyurularScreen())),
              ),
              _DaireselIkon(
                ikon: Icons.campaign_rounded,
                renk: AppColors.anaMavi,
                label: 'Duyurular',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DuyurularScreen())),
              ),
              _DaireselIkon(
                ikon: Icons.event_rounded,
                renk: AppColors.etkinlik,
                label: 'Etkinlikler',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DuyurularScreen())),
              ),
              _DaireselIkon(
                ikon: Icons.location_city_rounded,
                renk: AppColors.turkuaz,
                label: 'Tesislerimiz',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TesisScreen())),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DaireselIkon extends StatelessWidget {
  final IconData ikon;
  final Color renk;
  final String label;
  final VoidCallback onTap;

  const _DaireselIkon({required this.ikon, required this.renk, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 68, height: 68,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: renk.withValues(alpha: 0.25), width: 2),
              boxShadow: [BoxShadow(color: renk.withValues(alpha: 0.12), blurRadius: 10, offset: const Offset(0, 3))],
            ),
            child: Icon(ikon, color: renk, size: 32),
          ),
          const SizedBox(height: 8),
          Text(label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.anaMetin)),
        ],
      ),
    );
  }
}

// ─── İÇERİK SLIDER (kart + sayfa göstergesi) ─────────────────────────────────

class _IcerikSlider extends StatefulWidget {
  final List<Icerik> icerikler;
  final bool loading;
  const _IcerikSlider({required this.icerikler, required this.loading});
  @override
  State<_IcerikSlider> createState() => _IcerikSliderState();
}

class _IcerikSliderState extends State<_IcerikSlider> {
  final _ctrl = PageController();
  int _idx = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted || widget.icerikler.isEmpty) return;
      final next = (_idx + 1) % widget.icerikler.length;
      _ctrl.animateToPage(next, duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.loading && widget.icerikler.isEmpty)
            _SkeletonIcerikKart()
          else if (widget.icerikler.isEmpty)
            const SizedBox.shrink()
          else ...[
            SizedBox(
              height: 130,
              child: PageView.builder(
                controller: _ctrl,
                itemCount: widget.icerikler.length,
                onPageChanged: (i) => setState(() => _idx = i),
                itemBuilder: (ctx, i) => GestureDetector(
                  onTap: () => Navigator.push(ctx, MaterialPageRoute(
                      builder: (_) => ContentDetailScreen(icerikId: widget.icerikler[i].id))),
                  child: _IcerikKarti(icerik: widget.icerikler[i]),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Sayfa göstergesi
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: _idx > 0 ? () => _ctrl.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut) : null,
                  child: Icon(Icons.chevron_left_rounded, size: 22, color: _idx > 0 ? AppColors.anaMavi : AppColors.cizgi),
                ),
                const SizedBox(width: 8),
                Text('${_idx + 1} / ${widget.icerikler.length}',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.ikinciMetin)),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _idx < widget.icerikler.length - 1 ? () => _ctrl.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut) : null,
                  child: Icon(Icons.chevron_right_rounded, size: 22, color: _idx < widget.icerikler.length - 1 ? AppColors.anaMavi : AppColors.cizgi),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _IcerikKarti extends StatelessWidget {
  final Icerik icerik;
  const _IcerikKarti({required this.icerik});

  @override
  Widget build(BuildContext context) {
    final renk = AppTheme.kategoriRenk(icerik.kategoriSlug);
    final ikon = AppTheme.kategoriIkon(icerik.kategoriSlug);
    final tarih = icerik.yayinTarihi ?? icerik.createdAt;
    final fark = DateTime.now().difference(tarih);
    final farkStr = fark.inDays > 0 ? '${fark.inDays} gün önce' : fark.inHours > 0 ? '${fark.inHours} saat önce' : 'Az önce';

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sol ikon
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(color: renk.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(ikon, color: renk, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: renk.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                      child: Text(AppTheme.kategoriLabel(icerik.kategoriSlug),
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: renk)),
                    ),
                    const Spacer(),
                    Text(farkStr, style: const TextStyle(fontSize: 10, color: AppColors.ikinciMetin)),
                  ],
                ),
                const SizedBox(height: 6),
                Text(icerik.baslik, maxLines: 2, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.anaMetin, height: 1.3)),
                if (icerik.ozet != null && icerik.ozet!.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(icerik.ozet!, maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11, color: AppColors.ikinciMetin)),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.ikinciMetin),
              const SizedBox(height: 24),
              Row(children: [
                const Icon(Icons.remove_red_eye_outlined, size: 12, color: AppColors.ikinciMetin),
                const SizedBox(width: 3),
                Text('${icerik.goruntulenme}', style: const TextStyle(fontSize: 10, color: AppColors.ikinciMetin)),
              ]),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── HAVA DURUMU KARTI ────────────────────────────────────────────────────────

class _HavaDurumuKart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.anaMavi, AppColors.turkuaz],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: AppColors.anaMavi.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            const Icon(Icons.wb_sunny_rounded, color: Color(0xFFFDE68A), size: 44),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Ünye Hava Durumu', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500)),
                  SizedBox(height: 3),
                  Text('20°C  Parçalı Bulutlu', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: const [
                Row(children: [
                  Icon(Icons.air_rounded, color: Colors.white60, size: 14),
                  SizedBox(width: 4),
                  Text('6 km/s', style: TextStyle(color: Colors.white70, fontSize: 12)),
                ]),
                SizedBox(height: 4),
                Text('Ünye, Ordu', style: TextStyle(color: Colors.white54, fontSize: 11)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── HIZLI İŞLEMLER ──────────────────────────────────────────────────────────

class _HizliIslemler extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Satır 1
    final satir1 = [
      _HIVeri(ikon: Icons.map_rounded,             renk: AppColors.anaMavi,    baslik: 'Kent\nHaritası',     onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HaritaScreen()))),
      _HIVeri(ikon: Icons.local_pharmacy_rounded,  renk: AppColors.acil,       baslik: 'Nöbetçi\nEczane',   onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EczaneScreen()))),
      _HIVeri(ikon: Icons.report_problem_rounded,  renk: AppColors.uyari,      baslik: 'Şikayet\n& Talep',  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SikayetScreen()))),
      _HIVeri(ikon: Icons.calendar_month_rounded,  renk: AppColors.turkuaz,    baslik: 'Randevu\nAl',       onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RandevuScreen()))),
    ];
    // Satır 2
    final satir2 = [
      _HIVeri(ikon: Icons.person_pin_rounded,      renk: AppColors.etkinlik,   baslik: 'Muhtar\nRehberi',   onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MuhtarScreen()))),
      _HIVeri(ikon: Icons.emergency_rounded,       renk: AppColors.acil,       baslik: 'Acil\nNumaralar',   onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AcilScreen()))),
      _HIVeri(ikon: Icons.contact_phone_rounded,   renk: AppColors.lacivermavi,baslik: 'İletişim',          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const IletisimScreen()))),
      _HIVeri(ikon: Icons.apps_rounded,            renk: AppColors.anaMetin,   baslik: 'Tüm\nHizmetler',   onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HizmetlerScreen()))),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Başlık
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
            child: Row(children: [
              Container(width: 4, height: 18, decoration: BoxDecoration(color: AppColors.anaMavi, borderRadius: BorderRadius.circular(2))),
              const SizedBox(width: 8),
              const Text('Hızlı İşlemler', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.anaMetin)),
            ]),
          ),
          // Satır 1
          _HIRow(items: satir1),
          const SizedBox(height: 10),
          // Satır 2
          _HIRow(items: satir2),
        ],
      ),
    );
  }
}

class _HIVeri {
  final IconData ikon;
  final Color renk;
  final String baslik;
  final VoidCallback onTap;
  const _HIVeri({required this.ikon, required this.renk, required this.baslik, required this.onTap});
}

class _HIRow extends StatelessWidget {
  final List<_HIVeri> items;
  const _HIRow({required this.items});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: items.map((item) => Expanded(
        child: Padding(
          padding: EdgeInsets.only(right: item == items.last ? 0 : 10),
          child: _HizliIslemKutu(ikon: item.ikon, renk: item.renk, baslik: item.baslik, onTap: item.onTap),
        ),
      )).toList(),
    );
  }
}

class _HizliIslemKutu extends StatelessWidget {
  final IconData ikon;
  final Color renk;
  final String baslik;
  final VoidCallback onTap;

  const _HizliIslemKutu({required this.ikon, required this.renk, required this.baslik, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 8, offset: Offset(0, 2))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(color: renk.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
              child: Icon(ikon, color: renk, size: 22),
            ),
            const SizedBox(height: 8),
            Text(baslik,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.anaMetin, height: 1.2)),
          ],
        ),
      ),
    );
  }
}

// ─── ANA SAYFA LİSTE BÖLÜMÜ (duyurular / haberler) ───────────────────────────

class _AnaSayfaListeBolum extends StatelessWidget {
  final String baslik;
  final IconData ikon;
  final Color renkTonu;
  final String slugFiltre;
  final String tumunuGorRoute;
  final List<Icerik> icerikler;
  final bool loading;

  const _AnaSayfaListeBolum({
    required this.baslik,
    required this.ikon,
    required this.renkTonu,
    required this.slugFiltre,
    required this.tumunuGorRoute,
    required this.icerikler,
    required this.loading,
  });

  @override
  Widget build(BuildContext context) {
    final filtrelenmis = icerikler.where((i) => i.kategoriSlug == slugFiltre).take(4).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Başlık satırı
          Row(
            children: [
              Container(
                width: 4, height: 18,
                decoration: BoxDecoration(color: renkTonu, borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(width: 8),
              Icon(ikon, color: renkTonu, size: 18),
              const SizedBox(width: 6),
              Text(baslik,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.anaMetin)),
              const Spacer(),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: const Size(44, 32),
                ),
                child: Text('Tümünü Gör',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: renkTonu)),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // İçerik listesi
          if (loading && filtrelenmis.isEmpty)
            ...List.generate(2, (_) => const _SkeletonSatir())
          else if (filtrelenmis.isEmpty)
            _BosKart(mesaj: '$baslik bulunamadı.', renk: renkTonu)
          else
            ...filtrelenmis.map((i) => _AnaSayfaSatiri(icerik: i, renk: renkTonu)).toList(),
        ],
      ),
    );
  }
}

class _AnaSayfaSatiri extends StatelessWidget {
  final Icerik icerik;
  final Color renk;
  const _AnaSayfaSatiri({required this.icerik, required this.renk});

  @override
  Widget build(BuildContext context) {
    final tarih = icerik.yayinTarihi ?? icerik.createdAt;
    final fark = DateTime.now().difference(tarih);
    final farkStr = fark.inDays > 0
        ? '${fark.inDays} gün önce'
        : fark.inHours > 0
            ? '${fark.inHours} saat önce'
            : 'Az önce';

    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/content-detail', arguments: icerik.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 2))],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: renk.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
              child: Icon(AppTheme.kategoriIkon(icerik.kategoriSlug), color: renk, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(icerik.baslik,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.anaMetin, height: 1.35)),
                if (icerik.ozet != null && icerik.ozet!.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(icerik.ozet!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11, color: AppColors.ikinciMetin)),
                ],
                const SizedBox(height: 5),
                Text(farkStr, style: const TextStyle(fontSize: 10, color: AppColors.ikinciMetin)),
              ]),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_ios_rounded, size: 13, color: AppColors.ikinciMetin),
          ],
        ),
      ),
    );
  }
}

class _SkeletonSatir extends StatelessWidget {
  const _SkeletonSatir();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(children: [
        Container(width: 40, height: 40, decoration: BoxDecoration(color: AppColors.cizgi, borderRadius: BorderRadius.circular(10))),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(height: 12, width: double.infinity, decoration: BoxDecoration(color: AppColors.cizgi, borderRadius: BorderRadius.circular(4))),
          const SizedBox(height: 6),
          Container(height: 10, width: 180, decoration: BoxDecoration(color: AppColors.cizgi, borderRadius: BorderRadius.circular(4))),
        ])),
      ]),
    );
  }
}

class _BosKart extends StatelessWidget {
  final String mesaj;
  final Color renk;
  const _BosKart({required this.mesaj, required this.renk});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(children: [
        Icon(Icons.inbox_rounded, color: renk.withValues(alpha: 0.4), size: 36),
        const SizedBox(height: 8),
        Text(mesaj, style: const TextStyle(color: AppColors.ikinciMetin, fontSize: 13)),
      ]),
    );
  }
}

// ─── YÜZEN 153 BUTONU ─────────────────────────────────────────────────────────

class _Alo153Fab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final uri = Uri(scheme: 'tel', path: '153');
        if (await canLaunchUrl(uri)) launchUrl(uri);
      },
      child: Container(
        width: 62, height: 62,
        decoration: BoxDecoration(
          color: AppColors.anaMavi,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: AppColors.anaMavi.withValues(alpha: 0.45), blurRadius: 16, offset: const Offset(0, 4))],
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.phone_rounded, color: Colors.white, size: 22),
            Text('153', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    );
  }
}

// ─── SKELETON ─────────────────────────────────────────────────────────────────

class _SkeletonIcerikKart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 2))],
      ),
    );
  }
}

// ─── PROJELER BOTTOM SHEET ────────────────────────────────────────────────────

void _projelerBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) => Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40, height: 4,
              decoration: BoxDecoration(color: AppColors.cizgi, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
            child: Row(children: [
              Container(
                width: 38, height: 38,
                decoration: BoxDecoration(color: AppColors.anaMavi.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.construction_rounded, color: AppColors.anaMavi, size: 20),
              ),
              const SizedBox(width: 12),
              const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Projeler', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.anaMetin)),
                Text('Ünye Belediyesi proje kategorileri', style: TextStyle(fontSize: 11, color: AppColors.ikinciMetin)),
              ]),
            ]),
          ),
          const Divider(color: AppColors.cizgi, height: 24),
          _ProjeSatiri(
            ikon: Icons.engineering_rounded,
            renk: AppColors.anaMavi,
            baslik: 'Devam Eden Projeler',
            aciklama: 'Şu an sürmekte olan projeler',
            url: 'https://www.unye.bel.tr/projeler/devam-eden-projeler/',
          ),
          _ProjeSatiri(
            ikon: Icons.schedule_rounded,
            renk: AppColors.etkinlik,
            baslik: 'Planlanan Projeler',
            aciklama: 'Yakında başlayacak projeler',
            url: 'https://www.unye.bel.tr/projeler/planlanan-projeler/',
          ),
          _ProjeSatiri(
            ikon: Icons.check_circle_outline_rounded,
            renk: AppColors.basarili,
            baslik: 'Tamamlanan Projeler',
            aciklama: 'Hayata geçirilen projeler',
            url: 'https://www.unye.bel.tr/projeler/tamamlanan-projeler/',
          ),
          const SizedBox(height: 16),
        ],
      ),
    ),
  );
}

class _ProjeSatiri extends StatelessWidget {
  final IconData ikon;
  final Color renk;
  final String baslik;
  final String aciklama;
  final String url;

  const _ProjeSatiri({required this.ikon, required this.renk, required this.baslik, required this.aciklama, required this.url});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        WebViewEkrani.ac(context, url: url, baslik: baslik, ikon: ikon, ikonRenk: renk);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.cizgi, width: 0.5)),
          ),
          child: Row(children: [
            Container(
              width: 38, height: 38,
              decoration: BoxDecoration(color: renk.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
              child: Icon(ikon, color: renk, size: 19),
            ),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(baslik, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.anaMetin)),
              Text(aciklama, style: const TextStyle(fontSize: 11, color: AppColors.ikinciMetin)),
            ])),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.ikinciMetin),
          ]),
        ),
      ),
    );
  }
}

// ─── DRAWER (SAĞ MENÜ) ───────────────────────────────────────────────────────

class _AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.88,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(left: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // ─── DRAWER HEADER ────────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 8, 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: AppColors.cizgi)),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      'assets/images/logo.jpg',
                      width: 44, height: 44,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Ünye Belediyesi', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.anaMetin)),
                        Text('Senin Belediyen', style: TextStyle(fontSize: 12, color: AppColors.ikinciMetin)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppColors.anaMetin),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  const SizedBox(height: 12),

                  // ─── HAVA + NÖBETÇİ ECZANE ───────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.acikMavi,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.wb_sunny_rounded, color: Color(0xFFF59E0B), size: 26),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Hava Durumu', style: TextStyle(fontSize: 9, color: AppColors.ikinciMetin)),
                                      Text('Ünye', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.anaMetin)),
                                      Text('20°C  Açık', style: TextStyle(fontSize: 11, color: AppColors.anaMavi, fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const EczaneScreen()));
                            },
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppColors.acil,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.local_pharmacy_rounded, color: Colors.white, size: 26),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Nöbetçi', style: TextStyle(fontSize: 11, color: Colors.white70, fontWeight: FontWeight.w500)),
                                        Text('Eczane', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ─── BAŞKANDAN MESAJ BANNER ───────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        WebViewEkrani.ac(context,
                            url: 'https://www.unye.bel.tr/kurumsal/baskanin-mesaji/',
                            baslik: 'Başkanın Mesajı',
                            ikon: Icons.person_rounded,
                            ikonRenk: AppColors.anaMavi);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.lacivermavi, AppColors.anaMavi],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 46, height: 46,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: ClipOval(
                                child: Image.asset(
                                  'assets/images/ht.jpeg',
                                  width: 46, height: 46,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Icon(Icons.person_rounded, size: 28, color: Colors.white70),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Ünye Belediye Başkanı', style: TextStyle(color: Colors.white60, fontSize: 10, fontWeight: FontWeight.w500)),
                                  SizedBox(height: 2),
                                  Text('Başkandan Mesaj', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white54, size: 14),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ─── 3 ANA BÖLÜM İKONU ───────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Row(
                      children: [
                        Expanded(child: _DrawerIkon(ikon: Icons.construction_rounded, label: 'Projeler', renk: AppColors.anaMavi,
                            onTap: () { Navigator.pop(context); _projelerBottomSheet(context); })),
                        const SizedBox(width: 8),
                        Expanded(child: _DrawerIkon(ikon: Icons.event_rounded, label: 'Etkinlikler', renk: AppColors.etkinlik,
                            onTap: () { Navigator.pop(context); WebViewEkrani.ac(context, url: 'https://www.unye.bel.tr/etkinlik/', baslik: 'Etkinlikler', ikon: Icons.event_rounded, ikonRenk: AppColors.etkinlik); })),
                        const SizedBox(width: 8),
                        Expanded(child: _DrawerIkon(ikon: Icons.newspaper_rounded, label: 'Haberler', renk: AppColors.acil,
                            onTap: () { Navigator.pop(context); WebViewEkrani.ac(context, url: 'https://www.unye.bel.tr/haberler/', baslik: 'Haberler', ikon: Icons.newspaper_rounded, ikonRenk: AppColors.acil); })),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ─── BELEDİYE PORTALI ─────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: GestureDetector(
                      onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const HizmetlerScreen())); },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: AppColors.acikMavi,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.anaMavi.withValues(alpha: 0.15)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 34, height: 34,
                              decoration: BoxDecoration(color: AppColors.anaMavi.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(9)),
                              child: const Icon(Icons.language_rounded, color: AppColors.anaMavi, size: 18),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Belediye Portalı', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.anaMavi)),
                                  Text('Tüm hizmetler ve sayfalar', style: TextStyle(fontSize: 11, color: AppColors.ikinciMetin)),
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.anaMavi),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ─── KURUMSAL BAŞLIK ──────────────────────────────────
                  const Padding(
                    padding: EdgeInsets.fromLTRB(18, 0, 18, 8),
                    child: Text('KURUMSAL',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.ikinciMetin, letterSpacing: 1.0)),
                  ),

                  // ─── KURUMSAL MENÜ ────────────────────────────────────
                  _DrawerMenuItem(ikon: Icons.groups_rounded, label: 'Belediye Meclisi', renk: AppColors.anaMavi,
                      onTap: () { Navigator.pop(context); WebViewEkrani.ac(context, url: 'https://www.unye.bel.tr/kurumsal/meclis-uyeleri/', baslik: 'Belediye Meclisi', ikon: Icons.groups_rounded, ikonRenk: AppColors.anaMavi); }),
                  _DrawerMenuItem(ikon: Icons.account_balance_rounded, label: 'Müdürlükler', renk: AppColors.turkuaz,
                      onTap: () { Navigator.pop(context); WebViewEkrani.ac(context, url: 'https://www.unye.bel.tr/kurumsal/mudurlukleri/', baslik: 'Müdürlükler', ikon: Icons.account_balance_rounded, ikonRenk: AppColors.turkuaz); }),
                  _DrawerMenuItem(ikon: Icons.flag_rounded, label: 'Vizyon & Misyon', renk: AppColors.etkinlik,
                      onTap: () { Navigator.pop(context); WebViewEkrani.ac(context, url: 'https://www.unye.bel.tr/kurumsal/vizyon-misyon/', baslik: 'Vizyon & Misyon', ikon: Icons.flag_rounded, ikonRenk: AppColors.etkinlik); }),
                  _DrawerMenuItem(ikon: Icons.assignment_rounded, label: 'Meclis Gündemi', renk: AppColors.uyari,
                      onTap: () { Navigator.pop(context); WebViewEkrani.ac(context, url: 'https://www.unye.bel.tr/kurumsal/meclis-gundem/', baslik: 'Meclis Gündemi', ikon: Icons.assignment_rounded, ikonRenk: AppColors.uyari); }),
                  _DrawerMenuItem(ikon: Icons.gavel_rounded, label: 'İhaleler', renk: AppColors.lacivermavi,
                      onTap: () { Navigator.pop(context); WebViewEkrani.ac(context, url: 'https://www.unye.bel.tr/ihale/', baslik: 'İhaleler', ikon: Icons.gavel_rounded, ikonRenk: AppColors.lacivermavi); }),

                  const SizedBox(height: 20),

                  // ─── HİZMETLER BAŞLIK ─────────────────────────────────
                  const Padding(
                    padding: EdgeInsets.fromLTRB(18, 0, 18, 8),
                    child: Text('HİZMETLER',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.ikinciMetin, letterSpacing: 1.0)),
                  ),
                  _DrawerMenuItem(ikon: Icons.menu_book_rounded, label: 'Tüm Hizmetler', renk: AppColors.anaMavi,
                      onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const HizmetlerScreen())); }),
                  _DrawerMenuItem(ikon: Icons.campaign_rounded, label: 'Duyurular', renk: AppColors.acil,
                      onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const DuyurularScreen())); }),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerIkon extends StatelessWidget {
  final IconData ikon;
  final String label;
  final Color renk;
  final VoidCallback onTap;

  const _DrawerIkon({required this.ikon, required this.label, required this.renk, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.cizgi),
          boxShadow: const [BoxShadow(color: Color(0x08000000), blurRadius: 4)],
        ),
        child: Column(
          children: [
            Icon(ikon, color: renk, size: 28),
            const SizedBox(height: 6),
            Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: renk)),
          ],
        ),
      ),
    );
  }
}

class _DrawerMenuItem extends StatelessWidget {
  final IconData ikon;
  final String label;
  final Color renk;
  final VoidCallback onTap;

  const _DrawerMenuItem({required this.ikon, required this.label, required this.renk, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.cizgi, width: 0.5)),
          ),
          child: Row(
            children: [
              Container(
                width: 34, height: 34,
                decoration: BoxDecoration(color: renk.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(9)),
                child: Icon(ikon, color: renk, size: 18),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.anaMetin)),
              ),
              const Icon(Icons.chevron_right_rounded, size: 20, color: AppColors.ikinciMetin),
            ],
          ),
        ),
      ),
    );
  }
}
