import 'package:flutter/material.dart';
import '../utils/theme.dart';
import 'belediye_portal_screen.dart';
import 'webview_ekrani.dart';
import 'muhtar_screen.dart';
import 'kayip_screen.dart';
import 'sohbet_screen.dart';
import 'takas_screen.dart';
import 'yarisma_screen.dart';
import 'dilekce_screen.dart';
import 'vergi_screen.dart';
import 'sikayet_screen.dart';
import 'acil_screen.dart';
import 'randevu_screen.dart';
import 'anket_screen.dart';
import 'tesis_screen.dart';
import 'iletisim_screen.dart';
import 'eczane_screen.dart';
import 'harita_screen.dart';

class HizmetlerScreen extends StatelessWidget {
  const HizmetlerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.arkaplan,
      body: CustomScrollView(
        slivers: [
          // ─── HEADER ─────────────────────────────────────────────────────
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.lacivermavi,
            foregroundColor: Colors.white,
            leadingWidth: 0,
            leading: const SizedBox.shrink(),
            title: const Text('Hizmetler',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(height: 1, color: Colors.white.withValues(alpha: 0.1)),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ─── BELEDİYE HİZMETLERİ ────────────────────────────────
                  _GrupBaslik(baslik: 'Belediye Hizmetleri', icon: Icons.account_balance_rounded, renk: AppColors.lacivermavi),
                  const SizedBox(height: 12),
                  _HizmetGrid(hizmetler: [
                    _Hizmet(ikon: Icons.receipt_long_outlined, baslik: 'Vergi Sorgula', aciklama: 'Borç öğren', renk: AppColors.lacivermavi,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const VergiScreen()))),
                    _Hizmet(ikon: Icons.description_outlined, baslik: 'Dilekçe Şablonları', aciklama: 'Hazır şablon', renk: AppColors.basarili,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DilekceScreen()))),
                    _Hizmet(ikon: Icons.feedback_outlined, baslik: 'Şikayet & Talep', aciklama: 'Görüş bildir', renk: AppColors.uyari,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SikayetScreen()))),
                    _Hizmet(ikon: Icons.calendar_month_outlined, baslik: 'Randevu Al', aciklama: 'Belediye randevu', renk: AppColors.anaMavi,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RandevuScreen()))),
                    _Hizmet(ikon: Icons.poll_outlined, baslik: 'Anket & Oylama', aciklama: 'Fikir paylaş', renk: AppColors.etkinlik,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AnketScreen()))),
                  ]),

                  const SizedBox(height: 24),

                  // ─── SOSYAL HİZMETLER ────────────────────────────────────
                  _GrupBaslik(baslik: 'Sosyal Hizmetler', icon: Icons.people_rounded, renk: AppColors.turkuaz),
                  const SizedBox(height: 12),
                  _HizmetGrid(hizmetler: [
                    _Hizmet(ikon: Icons.supervisor_account_outlined, baslik: 'Mahalle Muhtarları', aciklama: 'İletişim kur', renk: AppColors.anaMavi,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MuhtarScreen()))),
                    _Hizmet(ikon: Icons.forum_outlined, baslik: 'Mahalle Sohbet', aciklama: 'Komşularla konuş', renk: AppColors.turkuaz,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SohbetScreen()))),
                    _Hizmet(ikon: Icons.swap_horiz_rounded, baslik: 'Takas & Yardım', aciklama: 'Komşuya yardım', renk: AppColors.uyari,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TakasScreen()))),
                    _Hizmet(ikon: Icons.photo_camera_outlined, baslik: 'Fotoğraf Yarışması', aciklama: 'Ünye\'yi fotoğrafla', renk: AppColors.etkinlik,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const YarismaScreen()))),
                    _Hizmet(ikon: Icons.search_rounded, baslik: 'Kayıp Kişiler', aciklama: 'Yardım çağrıları', renk: AppColors.acil,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const KayipScreen()))),
                  ]),

                  const SizedBox(height: 24),

                  // ─── REHBER & BİLGİ ─────────────────────────────────────
                  _GrupBaslik(baslik: 'Rehber & Bilgi', icon: Icons.explore_outlined, renk: AppColors.etkinlik),
                  const SizedBox(height: 12),
                  _HizmetGrid(hizmetler: [
                    _Hizmet(ikon: Icons.location_city_outlined, baslik: 'Tesis Rehberi', aciklama: 'Park, spor, kültür', renk: AppColors.etkinlik,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TesisScreen()))),
                    _Hizmet(ikon: Icons.local_pharmacy_outlined, baslik: 'Nöbetçi Eczane', aciklama: 'Güncel nöbetçi', renk: AppColors.basarili,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EczaneScreen()))),
                    _Hizmet(ikon: Icons.map_outlined, baslik: 'Harita', aciklama: 'Belediye noktaları', renk: AppColors.turkuaz,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HaritaScreen()))),
                    _Hizmet(ikon: Icons.emergency_outlined, baslik: 'Acil Numaralar', aciklama: 'Acil çağrı hatları', renk: AppColors.acil,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AcilScreen()))),
                    _Hizmet(ikon: Icons.contact_phone_outlined, baslik: 'İletişim', aciklama: 'Belediye iletişim', renk: AppColors.anaMavi,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const IletisimScreen()))),
                  ]),

                  const SizedBox(height: 24),

                  // ─── BAŞKANDAN MESAJ ─────────────────────────────────────
                  _BaskandanMesajKart(context: context),

                  const SizedBox(height: 16),

                  // ─── BELEDİYE PORTALI ────────────────────────────────────
                  _BelediyePortalKart(context: context),

                  const SizedBox(height: 16),

                  // ─── HIZLI WEB ERİŞİM ────────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: _WebHizmetBtn(
                          ikon: Icons.videocam_outlined,
                          baslik: 'Canlı\nKameralar',
                          renk: const Color(0xFF0369A1),
                          onTap: () => WebViewEkrani.ac(context,
                              url: 'https://www.unye.bel.tr/canli-kamera/',
                              baslik: 'Canlı Kameralar',
                              ikon: Icons.videocam,
                              ikonRenk: const Color(0xFF0369A1)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _WebHizmetBtn(
                          ikon: Icons.gavel_outlined,
                          baslik: 'Aktif\nİhaleler',
                          renk: const Color(0xFF0891B2),
                          onTap: () => WebViewEkrani.ac(context,
                              url: 'https://www.unye.bel.tr/ihale/',
                              baslik: 'İhaleler',
                              ikon: Icons.description,
                              ikonRenk: const Color(0xFF0891B2)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _WebHizmetBtn(
                          ikon: Icons.location_city_outlined,
                          baslik: 'Şehir\nRehberi',
                          renk: const Color(0xFF059669),
                          onTap: () => WebViewEkrani.ac(context,
                              url: 'https://www.unye.bel.tr/sehir-rehberi/',
                              baslik: 'Şehir Rehberi',
                              ikon: Icons.location_city,
                              ikonRenk: const Color(0xFF059669)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── YARDIMCI WİDGETLER ───────────────────────────────────────────────────────

class _GrupBaslik extends StatelessWidget {
  final String baslik;
  final IconData icon;
  final Color renk;
  const _GrupBaslik({required this.baslik, required this.icon, required this.renk});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 30, height: 30,
          decoration: BoxDecoration(color: renk.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: renk, size: 17),
        ),
        const SizedBox(width: 10),
        Text(baslik, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.anaMetin)),
      ],
    );
  }
}

class _HizmetGrid extends StatelessWidget {
  final List<_Hizmet> hizmetler;
  const _HizmetGrid({required this.hizmetler});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.9,
      ),
      itemCount: hizmetler.length,
      itemBuilder: (ctx, i) {
        final h = hizmetler[i];
        return GestureDetector(
          onTap: h.onTap,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 2))],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    color: h.renk.withValues(alpha: 0.11),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(h.ikon, color: h.renk, size: 24),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    h.baslik,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.anaMetin, height: 1.3),
                  ),
                ),
                if (h.aciklama != null) ...[
                  const SizedBox(height: 2),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      h.aciklama!,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 9.5, color: AppColors.ikinciMetin),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _BaskandanMesajKart extends StatelessWidget {
  final BuildContext context;
  const _BaskandanMesajKart({required this.context});

  @override
  Widget build(BuildContext ctx) {
    return GestureDetector(
      onTap: () => WebViewEkrani.ac(
        context,
        url: 'https://www.unye.bel.tr/kurumsal/baskanin-mesaji/',
        baslik: 'Başkanın Mesajı',
        altBaslik: 'unye.bel.tr',
        ikon: Icons.person_rounded,
        ikonRenk: AppColors.anaMavi,
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.lacivermavi, AppColors.anaMavi],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: AppColors.anaMavi.withValues(alpha: 0.30), blurRadius: 14, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            Container(
              width: 64, height: 64,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 8, offset: const Offset(0, 2))],
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/ht.jpeg',
                  width: 64, height: 64,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(Icons.person_rounded, size: 36, color: AppColors.anaMavi),
                ),
              ),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Ünye Belediye Başkanı', style: TextStyle(color: Colors.white60, fontSize: 11, fontWeight: FontWeight.w500)),
                  SizedBox(height: 3),
                  Text('Başkandan Mesaj', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700)),
                  SizedBox(height: 4),
                  Text('Belediye başkanımızın açıklamalarını okuyun', style: TextStyle(color: Colors.white70, fontSize: 11)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white54, size: 16),
          ],
        ),
      ),
    );
  }
}

class _BelediyePortalKart extends StatelessWidget {
  final BuildContext context;
  const _BelediyePortalKart({required this.context});

  @override
  Widget build(BuildContext ctx) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BelediyePortalScreen())),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.cizgi),
          boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(color: AppColors.acikMavi, borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.language_rounded, color: AppColors.anaMavi, size: 20),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text('Belediye Portalı',
                      style: TextStyle(color: AppColors.anaMetin, fontWeight: FontWeight.w700, fontSize: 15)),
                ),
                const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.ikinciMetin, size: 14),
              ],
            ),
            const SizedBox(height: 8),
            const Text('unye.bel.tr sitesindeki tüm hizmetler ve sayfalar',
                style: TextStyle(color: AppColors.ikinciMetin, fontSize: 12)),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: const [
                _PortalChip(label: 'E-Dilekçe'),
                _PortalChip(label: 'Borç Sorgula'),
                _PortalChip(label: 'İmar Durumu'),
                _PortalChip(label: 'Projeler'),
                _PortalChip(label: 'İhaleler'),
                _PortalChip(label: 'Kurumsal'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PortalChip extends StatelessWidget {
  final String label;
  const _PortalChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.acikMavi,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: const TextStyle(color: AppColors.anaMavi, fontSize: 12, fontWeight: FontWeight.w500)),
    );
  }
}

class _WebHizmetBtn extends StatelessWidget {
  final IconData ikon;
  final String baslik;
  final Color renk;
  final VoidCallback onTap;
  const _WebHizmetBtn({required this.ikon, required this.baslik, required this.renk, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: renk.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: renk.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(ikon, size: 24, color: renk),
            const SizedBox(height: 6),
            Text(baslik, textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: renk, fontWeight: FontWeight.w600, height: 1.2)),
          ],
        ),
      ),
    );
  }
}

class _Hizmet {
  final IconData ikon;
  final String baslik;
  final String? aciklama;
  final Color renk;
  final VoidCallback onTap;
  const _Hizmet({required this.ikon, required this.baslik, this.aciklama, required this.renk, required this.onTap});
}
