import 'package:flutter/material.dart';
import '../utils/theme.dart';
import 'webview_ekrani.dart';

// ─── VERİ MODELLERİ ──────────────────────────────────────────────────────────

class _PortalOge {
  final String ikon;
  final String baslik;
  final String? altBaslik;
  final String url;
  final IconData? matIcon;
  const _PortalOge({
    required this.ikon,
    required this.baslik,
    this.altBaslik,
    required this.url,
    this.matIcon,
  });
}

class _PortalBolum {
  final String baslik;
  final String ikon;
  final Color renk;
  final List<_PortalOge> ogeler;
  const _PortalBolum({
    required this.baslik,
    required this.ikon,
    required this.renk,
    required this.ogeler,
  });
}

// ─── TÜM BÖLÜMLER ─────────────────────────────────────────────────────────────

final _bolumler = <_PortalBolum>[
  _PortalBolum(
    baslik: 'E-Belediye Hizmetleri',
    ikon: '🌐',
    renk: const Color(0xFFCC2929),
    ogeler: [
      _PortalOge(
        ikon: '📄',
        baslik: 'E-Dilekçe',
        altBaslik: 'Online dilekçe ver',
        url: 'https://ebysweb.belediye.gov.tr/dilekce/login',
        matIcon: Icons.description_outlined,
      ),
      _PortalOge(
        ikon: '💳',
        baslik: 'Borç / Vergi Sorgulama',
        altBaslik: 'Emlak & çevre temizlik vergisi',
        url: 'https://canli.belediye.gov.tr/vpos/debt-inquiry/natural-type-person-form?token=2a69005b-16a7-47e4-ac56-e3e879380630',
        matIcon: Icons.account_balance_wallet_outlined,
      ),
      _PortalOge(
        ikon: '🏗️',
        baslik: 'İmar Durumu Sorgula',
        altBaslik: 'Parsel imar durumu öğren',
        url: 'https://www.unye.bel.tr/imar-bilgi-sistemi/',
        matIcon: Icons.map_outlined,
      ),
      _PortalOge(
        ikon: '💍',
        baslik: 'Evlilik İşlemleri',
        altBaslik: 'Nikâh randevusu & belgeler',
        url: 'https://www.unye.bel.tr/hizmetler/evlilik-islemleri/',
        matIcon: Icons.favorite_outline,
      ),
      _PortalOge(
        ikon: '🗺️',
        baslik: 'Parsel Sorgulama',
        altBaslik: 'Tapu & kadastro bilgisi',
        url: 'https://parselsorgu.tkgm.gov.tr',
        matIcon: Icons.search_outlined,
      ),
      _PortalOge(
        ikon: '📋',
        baslik: 'İstek & Öneri Formu',
        altBaslik: 'Geri bildirim gönder',
        url: 'https://www.unye.bel.tr/iletisim/',
        matIcon: Icons.feedback_outlined,
      ),
      _PortalOge(
        ikon: '🏛️',
        baslik: 'e-Devlet Hizmetleri',
        altBaslik: 'Devlet kapısı entegrasyonu',
        url: 'https://www.turkiye.gov.tr',
        matIcon: Icons.account_balance_outlined,
      ),
    ],
  ),

  _PortalBolum(
    baslik: 'Kurumsal',
    ikon: '🏛️',
    renk: const Color(0xFF1A56DB),
    ogeler: [
      _PortalOge(
        ikon: '__baskan__',
        baslik: 'Başkanın Mesajı',
        altBaslik: 'Belediye başkanından mesaj',
        url: 'https://www.unye.bel.tr/kurumsal/baskanin-mesaji/',
      ),
      _PortalOge(
        ikon: '🏛️',
        baslik: 'Belediye Meclisi',
        altBaslik: 'Meclis üyeleri ve kararları',
        url: 'https://www.unye.bel.tr/yonetim/belediye-meclisi/',
      ),
      _PortalOge(
        ikon: '📜',
        baslik: 'Belediye Encümeni',
        altBaslik: 'Encümen üyeleri',
        url: 'https://www.unye.bel.tr/kurul/belediye-encumeni/',
      ),
      _PortalOge(
        ikon: '👥',
        baslik: 'Başkan Yardımcıları',
        altBaslik: 'Başkan yardımcıları listesi',
        url: 'https://www.unye.bel.tr/kurul/baskan-yardimcilari/',
      ),
      _PortalOge(
        ikon: '🗂️',
        baslik: 'Müdürlükler',
        altBaslik: 'Tüm birimler ve müdürlükler',
        url: 'https://www.unye.bel.tr/birim/',
      ),
      _PortalOge(
        ikon: '⚖️',
        baslik: 'Etik Komisyonu',
        altBaslik: 'Etik ilkeler ve komisyon',
        url: 'https://www.unye.bel.tr/kurul/etik-komisyonu/',
      ),
      _PortalOge(
        ikon: '🤝',
        baslik: 'Muhtarlarımız',
        altBaslik: 'Mahalle muhtarları listesi',
        url: 'https://www.unye.bel.tr/kurul/muhtarlarimiz/',
      ),
      _PortalOge(
        ikon: '🎯',
        baslik: 'Vizyon & Misyon',
        altBaslik: 'Stratejik hedefler',
        url: 'https://www.unye.bel.tr/kurumsal/vizyon-misyonumuz/',
      ),
      _PortalOge(
        ikon: '📊',
        baslik: 'Teşkilat Şeması',
        altBaslik: 'Organizasyon yapısı',
        url: 'https://www.unye.bel.tr/kurul/teskilat-semasi/',
      ),
      _PortalOge(
        ikon: '🔍',
        baslik: 'İç Kontrol',
        altBaslik: 'Stratejik yönetim ve raporlar',
        url: 'https://www.unye.bel.tr/duyurular/ic-kontrol/',
      ),
      _PortalOge(
        ikon: '📈',
        baslik: 'Stratejik Plan',
        altBaslik: 'Faaliyet raporları & performans',
        url: 'https://www.unye.bel.tr/duyurular/stratejik-yonetim/',
      ),
    ],
  ),

  _PortalBolum(
    baslik: 'Birimler / Müdürlükler',
    ikon: '🗂️',
    renk: const Color(0xFF7C3AED),
    ogeler: [
      _PortalOge(ikon: '💻', baslik: 'Bilgi İşlem Müdürlüğü', url: 'https://www.unye.bel.tr/birim/bilgi-islem-mudurlugu/'),
      _PortalOge(ikon: '⚖️', baslik: 'Hukuk İşleri Müdürlüğü', url: 'https://www.unye.bel.tr/birim/hukuk-isleri-mudurlugu/'),
      _PortalOge(ikon: '🏗️', baslik: 'İmar ve Şehircilik Müdürlüğü', url: 'https://www.unye.bel.tr/birim/imar-ve-sehircilik-mudurlugu/'),
      _PortalOge(ikon: '🌳', baslik: 'Park ve Bahçeler Müdürlüğü', url: 'https://www.unye.bel.tr/birim/park-ve-bahceler-mudurlugu/'),
      _PortalOge(ikon: '🧹', baslik: 'Temizlik İşleri Müdürlüğü', url: 'https://www.unye.bel.tr/birim/temizlik-isleri-mudurlugu/'),
      _PortalOge(ikon: '💰', baslik: 'Mali Hizmetler Müdürlüğü', url: 'https://www.unye.bel.tr/birim/mali-hizmetler-mudurlugu/'),
      _PortalOge(ikon: '👤', baslik: 'İnsan Kaynakları Müdürlüğü', url: 'https://www.unye.bel.tr/birim/insan-kaynaklari-mudurlugu/'),
      _PortalOge(ikon: '📣', baslik: 'Basın Yayın ve Halkla İlişkiler', url: 'https://www.unye.bel.tr/birim/basin-yayin-ve-halkla-iliskiler-mudurlugu/'),
      _PortalOge(ikon: '🔧', baslik: 'Fen İşleri Müdürlüğü', url: 'https://www.unye.bel.tr/birim/fen-isleri-mudurlugu/'),
      _PortalOge(ikon: '🚒', baslik: 'İtfaiye Müdürlüğü', url: 'https://www.unye.bel.tr/birim/itfaiye-mudurlugu/'),
      _PortalOge(ikon: '🌊', baslik: 'Su ve Kanalizasyon Müdürlüğü', url: 'https://www.unye.bel.tr/birim/su-ve-kanalizasyon-mudurlugu/'),
      _PortalOge(ikon: '📐', baslik: 'Yapı Kontrol Müdürlüğü', url: 'https://www.unye.bel.tr/birim/yapi-kontrol-mudurlugu/'),
      _PortalOge(ikon: '🚦', baslik: 'Zabıta Müdürlüğü', url: 'https://www.unye.bel.tr/birim/zabita-mudurlugu/'),
      _PortalOge(ikon: '🎭', baslik: 'Kültür ve Sosyal İşler Müdürlüğü', url: 'https://www.unye.bel.tr/birim/kultur-ve-sosyal-isler-mudurlugu/'),
      _PortalOge(ikon: '📦', baslik: 'Destek Hizmetleri Müdürlüğü', url: 'https://www.unye.bel.tr/birim/destek-hizmetleri-mudurlugu/'),
      _PortalOge(ikon: '📋', baslik: 'Yazı İşleri Müdürlüğü', url: 'https://www.unye.bel.tr/birim/yazi-isleri-mudurlugu/'),
      _PortalOge(ikon: '🏛️', baslik: 'Tüm Birimler', url: 'https://www.unye.bel.tr/birim/'),
    ],
  ),

  _PortalBolum(
    baslik: 'Güncel',
    ikon: '📰',
    renk: const Color(0xFF059669),
    ogeler: [
      _PortalOge(
        ikon: '📰',
        baslik: 'Haberler',
        altBaslik: 'Belediye haberleri',
        url: 'https://www.unye.bel.tr/haberler/',
      ),
      _PortalOge(
        ikon: '📢',
        baslik: 'Duyurular',
        altBaslik: 'Resmi duyurular',
        url: 'https://www.unye.bel.tr/duyurular/',
      ),
      _PortalOge(
        ikon: '📅',
        baslik: 'Meclis Gündemi',
        altBaslik: 'Meclis toplantı gündemi',
        url: 'https://www.unye.bel.tr/yonetim/meclis-gundemi/',
      ),
      _PortalOge(
        ikon: '🕊️',
        baslik: 'Cenaze İlanları',
        altBaslik: 'Vefat haberleri',
        url: 'https://www.unye.bel.tr/cenaze-ilanlari/',
      ),
      _PortalOge(
        ikon: '📋',
        baslik: 'Meclis Kararları',
        altBaslik: 'Alınan meclis kararları',
        url: 'https://www.unye.bel.tr/yonetim/meclis-kararlari/',
      ),
    ],
  ),

  _PortalBolum(
    baslik: 'Projeler',
    ikon: '🏗️',
    renk: const Color(0xFFD97706),
    ogeler: [
      _PortalOge(
        ikon: '🚧',
        baslik: 'Devam Eden Projeler',
        altBaslik: 'Süren projeler',
        url: 'https://www.unye.bel.tr/proje/devam-eden/',
      ),
      _PortalOge(
        ikon: '📐',
        baslik: 'Planlanan Projeler',
        altBaslik: 'Yakında başlayacak projeler',
        url: 'https://www.unye.bel.tr/proje/planlanan/',
      ),
      _PortalOge(
        ikon: '✅',
        baslik: 'Tamamlanan Projeler',
        altBaslik: 'Biten projeler',
        url: 'https://www.unye.bel.tr/proje/tamamlanan/',
      ),
      _PortalOge(
        ikon: '🏗️',
        baslik: 'Tüm Projeler',
        altBaslik: 'Tüm projeleri listele',
        url: 'https://www.unye.bel.tr/proje/',
      ),
    ],
  ),

  _PortalBolum(
    baslik: 'İhaleler',
    ikon: '📑',
    renk: const Color(0xFF0891B2),
    ogeler: [
      _PortalOge(
        ikon: '🟢',
        baslik: 'Aktif İhaleler',
        altBaslik: 'Devam eden ihaleler',
        url: 'https://www.unye.bel.tr/ihale/',
      ),
      _PortalOge(
        ikon: '✅',
        baslik: 'Tamamlanan İhaleler',
        altBaslik: 'Sonuçlanan ihaleler',
        url: 'https://www.unye.bel.tr/ihale/tamamlanan/',
      ),
      _PortalOge(
        ikon: '📄',
        baslik: 'Doğrudan Temin',
        altBaslik: 'Doğrudan temin ilanları',
        url: 'https://www.unye.bel.tr/ihale/dogrudan-temin/',
      ),
      _PortalOge(
        ikon: '🏛️',
        baslik: 'Kamu İhale Kurumu',
        altBaslik: 'ekap.kik.gov.tr',
        url: 'https://ekap.kik.gov.tr',
      ),
    ],
  ),

  _PortalBolum(
    baslik: 'Ünyemiz',
    ikon: '🌊',
    renk: const Color(0xFF0369A1),
    ogeler: [
      _PortalOge(
        ikon: '🗺️',
        baslik: 'Şehir Rehberi',
        altBaslik: 'Ünye hakkında her şey',
        url: 'https://www.unye.bel.tr/sehir-rehberi/',
      ),
      _PortalOge(
        ikon: '📹',
        baslik: 'Canlı Kameralar',
        altBaslik: 'Şehir kameralarını izle',
        url: 'https://www.unye.bel.tr/canli-kamera/',
      ),
      _PortalOge(
        ikon: '🏛️',
        baslik: 'Kültürel Alanlar',
        altBaslik: 'Tarihi ve kültürel mekanlar',
        url: 'https://www.unye.bel.tr/kultur/',
      ),
      _PortalOge(
        ikon: '🧀',
        baslik: 'Yöresel Ürünler',
        altBaslik: 'Ünye\'nin özgün lezzetleri',
        url: 'https://www.unye.bel.tr/yoresel-urunler/',
      ),
      _PortalOge(
        ikon: '🏖️',
        baslik: 'Plajlar',
        altBaslik: 'Ünye\'nin sahilleri',
        url: 'https://www.unye.bel.tr/plajlar/',
      ),
      _PortalOge(
        ikon: '🏨',
        baslik: 'Konaklama',
        altBaslik: 'Otel ve pansiyon listesi',
        url: 'https://www.unye.bel.tr/konaklama/',
      ),
      _PortalOge(
        ikon: '🚶',
        baslik: 'Turistik Rotalar',
        altBaslik: 'Gezilecek yerler',
        url: 'https://www.unye.bel.tr/turistik-rotalar/',
      ),
      _PortalOge(
        ikon: '🎪',
        baslik: 'Etkinlikler',
        altBaslik: 'Festival ve etkinlikler',
        url: 'https://www.unye.bel.tr/etkinlikler/',
      ),
    ],
  ),

  _PortalBolum(
    baslik: 'Sosyal Medya & Basın',
    ikon: '📱',
    renk: const Color(0xFFDB2777),
    ogeler: [
      _PortalOge(
        ikon: '📘',
        baslik: 'Facebook',
        altBaslik: 'Ünye Belediyesi sayfası',
        url: 'https://www.facebook.com/unyebelediyesi',
        matIcon: Icons.facebook,
      ),
      _PortalOge(
        ikon: '📸',
        baslik: 'Instagram',
        altBaslik: '@unyebelediyesi',
        url: 'https://www.instagram.com/unyebelediyesi',
        matIcon: Icons.camera_alt_outlined,
      ),
      _PortalOge(
        ikon: '🐦',
        baslik: 'X (Twitter)',
        altBaslik: '@unyebelediyesi',
        url: 'https://twitter.com/unyebelediyesi',
        matIcon: Icons.alternate_email,
      ),
      _PortalOge(
        ikon: '▶️',
        baslik: 'YouTube',
        altBaslik: 'Video ve etkinlikler',
        url: 'https://www.youtube.com/@unyebelediyesi',
        matIcon: Icons.play_circle_outline,
      ),
      _PortalOge(
        ikon: '🌐',
        baslik: 'Resmi Web Sitesi',
        altBaslik: 'www.unye.bel.tr',
        url: 'https://www.unye.bel.tr',
        matIcon: Icons.language,
      ),
    ],
  ),
];

// ─── ANA EKRAN ────────────────────────────────────────────────────────────────

class BelediyePortalScreen extends StatefulWidget {
  const BelediyePortalScreen({super.key});

  @override
  State<BelediyePortalScreen> createState() => _BelediyePortalScreenState();
}

class _BelediyePortalScreenState extends State<BelediyePortalScreen> {
  String _aramaMetni = '';
  final _aramaCtrl = TextEditingController();

  @override
  void dispose() {
    _aramaCtrl.dispose();
    super.dispose();
  }

  void _webAc(_PortalOge oge) {
    WebViewEkrani.ac(
      context,
      url: oge.url,
      baslik: oge.baslik,
      altBaslik: oge.altBaslik ?? 'unye.bel.tr',
      ikon: oge.matIcon ?? Icons.language,
      ikonRenk: AppTheme.primary,
    );
  }

  List<_PortalBolum> _filtreliBolumler() {
    if (_aramaMetni.trim().isEmpty) return _bolumler;
    final q = _aramaMetni.toLowerCase();
    return _bolumler
        .map((b) {
          final filtreli = b.ogeler
              .where((o) =>
                  o.baslik.toLowerCase().contains(q) ||
                  (o.altBaslik?.toLowerCase().contains(q) ?? false))
              .toList();
          if (filtreli.isEmpty &&
              !b.baslik.toLowerCase().contains(q)) return null;
          return _PortalBolum(
            baslik: b.baslik,
            ikon: b.ikon,
            renk: b.renk,
            ogeler: filtreli.isEmpty ? b.ogeler : filtreli,
          );
        })
        .whereType<_PortalBolum>()
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtreliBolumler = _filtreliBolumler();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Belediye Portalı', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text('unye.bel.tr', style: TextStyle(fontSize: 11, color: Colors.white70)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            tooltip: 'Web sitesini aç',
            onPressed: () => WebViewEkrani.ac(
              context,
              url: 'https://www.unye.bel.tr',
              baslik: 'Ünye Belediyesi',
              altBaslik: 'www.unye.bel.tr',
              ikon: Icons.language,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // ─── ARAMA ───
          Container(
            color: AppTheme.primary,
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: TextField(
              controller: _aramaCtrl,
              onChanged: (v) => setState(() => _aramaMetni = v),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Hizmet veya sayfa ara...',
                hintStyle: const TextStyle(color: Colors.white60),
                prefixIcon: const Icon(Icons.search, color: Colors.white70),
                suffixIcon: _aramaMetni.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.white70),
                        onPressed: () {
                          _aramaCtrl.clear();
                          setState(() => _aramaMetni = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.15),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
            ),
          ),

          // ─── HIZLI ERİŞİM ───
          if (_aramaMetni.isEmpty)
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 4, bottom: 8),
                    child: Text('Hızlı Erişim',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black54)),
                  ),
                  Row(
                    children: [
                      _HizliBtn(
                        renk: const Color(0xFFCC2929),
                        ikon: '🌐',
                        label: 'E-Belediye',
                        onTap: () => WebViewEkrani.ac(context,
                            url: 'https://ebysweb.belediye.gov.tr/dilekce/login',
                            baslik: 'E-Belediye',
                            ikon: Icons.language,
                            ikonRenk: const Color(0xFFCC2929)),
                      ),
                      const SizedBox(width: 8),
                      _HizliBtn(
                        renk: const Color(0xFF1A3A6B),
                        ikon: '💳',
                        label: 'Borç Sorgula',
                        onTap: () => WebViewEkrani.ac(context,
                            url: 'https://canli.belediye.gov.tr/vpos/debt-inquiry/natural-type-person-form?token=2a69005b-16a7-47e4-ac56-e3e879380630',
                            baslik: 'Vergi / Borç Sorgulama',
                            ikon: Icons.credit_card,
                            ikonRenk: const Color(0xFF1A3A6B)),
                      ),
                      const SizedBox(width: 8),
                      _HizliBtn(
                        renk: const Color(0xFF059669),
                        ikon: '📰',
                        label: 'Haberler',
                        onTap: () => WebViewEkrani.ac(context,
                            url: 'https://www.unye.bel.tr/haberler/',
                            baslik: 'Haberler',
                            ikon: Icons.newspaper,
                            ikonRenk: const Color(0xFF059669)),
                      ),
                      const SizedBox(width: 8),
                      _HizliBtn(
                        renk: const Color(0xFF0369A1),
                        ikon: '🌊',
                        label: 'Ünyemiz',
                        onTap: () => WebViewEkrani.ac(context,
                            url: 'https://www.unye.bel.tr/sehir-rehberi/',
                            baslik: 'Ünyemiz - Şehir Rehberi',
                            ikon: Icons.location_city,
                            ikonRenk: const Color(0xFF0369A1)),
                      ),
                    ],
                  ),
                ],
              ),
            ),

          // ─── BÖLÜM LİSTESİ ───
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: filtreliBolumler.length,
              itemBuilder: (ctx, i) => _BolumKarti(
                bolum: filtreliBolumler[i],
                onOgeTap: _webAc,
                baslangicdaAcik: _aramaMetni.isNotEmpty || i == 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── BÖLÜM KARTI ──────────────────────────────────────────────────────────────

class _BolumKarti extends StatefulWidget {
  final _PortalBolum bolum;
  final void Function(_PortalOge) onOgeTap;
  final bool baslangicdaAcik;

  const _BolumKarti({
    required this.bolum,
    required this.onOgeTap,
    this.baslangicdaAcik = false,
  });

  @override
  State<_BolumKarti> createState() => _BolumKartiState();
}

class _BolumKartiState extends State<_BolumKarti> {
  late bool _acik;

  @override
  void initState() {
    super.initState();
    _acik = widget.baslangicdaAcik;
  }

  @override
  Widget build(BuildContext context) {
    final b = widget.bolum;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          // Başlık
          InkWell(
            onTap: () => setState(() => _acik = !_acik),
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 10, 14),
              child: Row(
                children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: b.renk.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(child: Text(b.ikon, style: const TextStyle(fontSize: 20))),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(b.baslik,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87)),
                        Text('${b.ogeler.length} öğe',
                            style: TextStyle(fontSize: 11, color: b.renk)),
                      ],
                    ),
                  ),
                  Container(
                    width: 28, height: 28,
                    decoration: BoxDecoration(
                      color: b.renk.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _acik ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      color: b.renk,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Öğeler
          if (_acik) ...[
            Divider(height: 1, color: Colors.grey.shade100),
            ...b.ogeler.asMap().entries.map((e) {
              final oge = e.value;
              final isLast = e.key == b.ogeler.length - 1;
              return Column(
                children: [
                  ListTile(
                    onTap: () => widget.onOgeTap(oge),
                    dense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                    leading: oge.ikon == '__baskan__'
                        ? Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.10),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: Image.asset(
                                'assets/images/ht.jpeg',
                                width: 36,
                                height: 36,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(
                                  Icons.person_rounded,
                                  size: 22,
                                  color: Color(0xFF075EAF),
                                ),
                              ),
                            ),
                          )
                        : Container(
                            width: 36, height: 36,
                            decoration: BoxDecoration(
                              color: b.renk.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(child: Text(oge.ikon, style: const TextStyle(fontSize: 16))),
                          ),
                    title: Text(
                      oge.baslik,
                      style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w500, color: Colors.black87),
                    ),
                    subtitle: oge.altBaslik != null
                        ? Text(oge.altBaslik!,
                            style: TextStyle(fontSize: 11, color: Colors.grey.shade500))
                        : null,
                    trailing: Icon(Icons.arrow_forward_ios, size: 13, color: b.renk.withValues(alpha: 0.5)),
                  ),
                  if (!isLast) Divider(height: 1, indent: 68, color: Colors.grey.shade100),
                ],
              );
            }),
          ],
        ],
      ),
    );
  }
}

// ─── HIZLI ERİŞİM BUTONU ─────────────────────────────────────────────────────

class _HizliBtn extends StatelessWidget {
  final Color renk;
  final String ikon;
  final String label;
  final VoidCallback onTap;

  const _HizliBtn({required this.renk, required this.ikon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: renk.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: renk.withValues(alpha: 0.2)),
          ),
          child: Column(
            children: [
              Text(ikon, style: const TextStyle(fontSize: 20)),
              const SizedBox(height: 3),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 10, color: renk, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
