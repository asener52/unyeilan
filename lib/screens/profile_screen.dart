import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/content_provider.dart';
import '../services/api_service.dart';
import '../services/konum_service.dart';
import '../utils/theme.dart';
import 'kvkk_metni_screen.dart';
import 'acik_riza_metni_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  List<int> _selectedMahalleIds = [];
  bool? _tumHaberler;
  bool _saving = false;

  String _mahalleMod = 'liste';
  bool _konumYukleniyor = false;
  String? _konumMahalleAd;

  Set<int> _engelliKategoriIds = {};
  bool _tumKategoriler = true;
  bool _kategoriYuklendi = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  Future<void> _loadData() async {
    final cp = context.read<ContentProvider>();
    await Future.wait([
      cp.loadMahalles(),
      cp.loadKategoriler(),
      cp.loadKategoriEngelleme(),
    ]);
    final user = context.read<AuthProvider>().user;
    final engelli = cp.engelliKategoriIds;
    setState(() {
      _selectedMahalleIds = user?.abonelikIds ?? [];
      _tumHaberler = user?.tumHaberler ?? true;
      _engelliKategoriIds = Set.from(engelli);
      _tumKategoriler = engelli.isEmpty;
      _kategoriYuklendi = true;
    });
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final cp = context.read<ContentProvider>();
    final engellenecek = _tumKategoriler ? <int>{} : _engelliKategoriIds;
    await cp.updateKategoriEngelleme(engellenecek);
    await context.read<AuthProvider>().updateProfile(
      tumHaberler: _tumHaberler,
      mahalleIds: (_tumHaberler ?? true) ? [] : _selectedMahalleIds,
    );
    setState(() => _saving = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(children: [
            Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text('Tercihler başarıyla kaydedildi'),
          ]),
          backgroundColor: AppColors.basarili,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;
    final mahalles = context.watch<ContentProvider>().mahalles;
    final tumHaberler = _tumHaberler ?? true;

    return Scaffold(
      backgroundColor: AppColors.arkaplan,
      body: user == null
          ? const Center(child: CircularProgressIndicator(color: AppColors.anaMavi))
          : RefreshIndicator(
              onRefresh: () async {
                await context.read<ContentProvider>().loadMahalles();
                await context.read<AuthProvider>().refreshProfile();
                final u = context.read<AuthProvider>().user;
                setState(() {
                  _selectedMahalleIds = u?.abonelikIds ?? [];
                  _tumHaberler = u?.tumHaberler ?? true;
                });
              },
              color: AppColors.anaMavi,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  // ─── HEADER ─────────────────────────────────────────────
                  SliverAppBar(
                    pinned: true,
                    expandedHeight: 180,
                    backgroundColor: AppColors.lacivermavi,
                    surfaceTintColor: Colors.transparent,
                    flexibleSpace: FlexibleSpaceBar(
                      background: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.lacivermavi, AppColors.anaMavi],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: SafeArea(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Profilim',
                                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.3)),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    // Avatar
                                    Container(
                                      width: 64, height: 64,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.2),
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 2),
                                      ),
                                      child: Center(
                                        child: Text(
                                          user.adSoyad.isNotEmpty ? user.adSoyad[0].toUpperCase() : 'U',
                                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(user.adSoyad,
                                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                                          const SizedBox(height: 2),
                                          Text(user.email,
                                              style: const TextStyle(color: Colors.white70, fontSize: 13)),
                                          if (user.telefon != null) ...[
                                            const SizedBox(height: 1),
                                            Text(user.telefon!,
                                                style: const TextStyle(color: Colors.white60, fontSize: 12)),
                                          ],
                                        ],
                                      ),
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

                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        const SizedBox(height: 16),

                        // ─── PUAN ROZET KARTI ──────────────────────────────
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: _PuanRozetKart(userId: user.id),
                        ),

                        const SizedBox(height: 24),

                        // ─── BİLDİRİM TERCİHLERİ ──────────────────────────
                        _SectionTitle(title: 'Bildirim Tercihleri', icon: Icons.notifications_outlined),
                        const SizedBox(height: 10),

                        _SettingsCard(children: [
                          SwitchListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            title: const Text('Tüm haberleri takip et',
                                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: AppColors.anaMetin)),
                            subtitle: Text(
                              tumHaberler
                                  ? 'Tüm mahallelerin haberlerini görürsünüz'
                                  : 'Seçtiğiniz mahallelerin haberlerini görürsünüz',
                              style: const TextStyle(fontSize: 12, color: AppColors.ikinciMetin),
                            ),
                            value: tumHaberler,
                            activeColor: AppColors.anaMavi,
                            onChanged: (v) => setState(() => _tumHaberler = v),
                          ),
                        ]),

                        // Mahalle seçimi
                        if (!tumHaberler) ...[
                          const SizedBox(height: 16),
                          _SectionTitle(title: 'Mahalle Seçim Yöntemi', icon: Icons.location_on_outlined),
                          const SizedBox(height: 10),

                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children: [
                                Expanded(
                                  child: _ModButon(
                                    label: 'Listeden Seç',
                                    icon: Icons.list_rounded,
                                    aktif: _mahalleMod == 'liste',
                                    onTap: () => setState(() => _mahalleMod = 'liste'),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _ModButon(
                                    label: 'Konumdan Tespit',
                                    icon: Icons.my_location_rounded,
                                    aktif: _mahalleMod == 'konum',
                                    onTap: () async {
                                      setState(() { _mahalleMod = 'konum'; _konumYukleniyor = true; });
                                      final sonuc = await KonumService().konumaGoreMahalleAbone();
                                      if (!mounted) return;
                                      if (sonuc.basarili && sonuc.mahalleId != null) {
                                        setState(() {
                                          _selectedMahalleIds = [sonuc.mahalleId!];
                                          _konumMahalleAd = sonuc.mahalleAd;
                                          _konumYukleniyor = false;
                                        });
                                        if (mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                            content: Text('${sonuc.mahalleAd} mahallesi tespit edildi'),
                                            backgroundColor: AppColors.basarili,
                                            behavior: SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                          ));
                                        }
                                      } else {
                                        setState(() { _mahalleMod = 'liste'; _konumYukleniyor = false; });
                                        if (mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                            content: Text(sonuc.mesaj),
                                            backgroundColor: AppColors.uyari,
                                            behavior: SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                          ));
                                        }
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),

                          if (_mahalleMod == 'konum') ...[
                            const SizedBox(height: 12),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: _konumYukleniyor ? AppColors.acikMavi : (_konumMahalleAd != null ? const Color(0xFFECFDF5) : const Color(0xFFFFF7ED)),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _konumYukleniyor ? AppColors.anaMavi.withValues(alpha: 0.3) : (_konumMahalleAd != null ? const Color(0xFF86EFAC) : const Color(0xFFFED7AA)),
                                  ),
                                ),
                                child: _konumYukleniyor
                                    ? const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                        SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.anaMavi)),
                                        SizedBox(width: 10),
                                        Text('Konum tespit ediliyor...', style: TextStyle(fontSize: 13, color: AppColors.anaMetin)),
                                      ])
                                    : Row(children: [
                                        Icon(_konumMahalleAd != null ? Icons.location_on_rounded : Icons.warning_amber_rounded,
                                            color: _konumMahalleAd != null ? AppColors.basarili : AppColors.uyari, size: 20),
                                        const SizedBox(width: 10),
                                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                          Text(_konumMahalleAd ?? 'Mahalle tespit edilemedi',
                                              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14,
                                                  color: _konumMahalleAd != null ? const Color(0xFF166534) : const Color(0xFF92400E))),
                                          if (_konumMahalleAd != null)
                                            const Text('Bu mahalle bildirimleri alacaksınız',
                                                style: TextStyle(fontSize: 11, color: AppColors.basarili)),
                                        ])),
                                      ]),
                              ),
                            ),
                          ],

                          if (_mahalleMod == 'liste') ...[
                            const SizedBox(height: 16),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Row(children: [
                                const Text('Takip Etmek İstediğiniz Mahalleler',
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.anaMetin)),
                                const Spacer(),
                                if (_selectedMahalleIds.isNotEmpty)
                                  Text('${_selectedMahalleIds.length} seçili',
                                      style: const TextStyle(fontSize: 12, color: AppColors.anaMavi, fontWeight: FontWeight.w600)),
                              ]),
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: _SettingsCard(children: [
                                mahalles.isEmpty
                                    ? const Padding(
                                        padding: EdgeInsets.all(16),
                                        child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.anaMavi)),
                                      )
                                    : ConstrainedBox(
                                        constraints: const BoxConstraints(maxHeight: 280),
                                        child: ListView.separated(
                                          shrinkWrap: true,
                                          physics: const ClampingScrollPhysics(),
                                          itemCount: mahalles.length,
                                          separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.cizgi),
                                          itemBuilder: (_, i) {
                                            final m = mahalles[i];
                                            final secili = _selectedMahalleIds.contains(m.id);
                                            return InkWell(
                                              onTap: () => setState(() {
                                                if (secili) _selectedMahalleIds.remove(m.id);
                                                else _selectedMahalleIds.add(m.id);
                                              }),
                                              child: Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                                child: Row(children: [
                                                  AnimatedContainer(
                                                    duration: const Duration(milliseconds: 150),
                                                    width: 22, height: 22,
                                                    decoration: BoxDecoration(
                                                      color: secili ? AppColors.anaMavi : Colors.transparent,
                                                      border: Border.all(color: secili ? AppColors.anaMavi : AppColors.ikinciMetin.withValues(alpha: 0.4), width: 2),
                                                      borderRadius: BorderRadius.circular(6),
                                                    ),
                                                    child: secili ? const Icon(Icons.check, color: Colors.white, size: 14) : null,
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Text(m.ad, style: TextStyle(fontSize: 14, color: secili ? AppColors.anaMetin : AppColors.ikinciMetin, fontWeight: secili ? FontWeight.w600 : FontWeight.w400)),
                                                ]),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                              ]),
                            ),
                            if (_selectedMahalleIds.isNotEmpty)
                              Align(
                                alignment: Alignment.centerRight,
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 16),
                                  child: TextButton.icon(
                                    onPressed: () => setState(() => _selectedMahalleIds.clear()),
                                    icon: const Icon(Icons.clear_all_rounded, size: 16, color: AppColors.acil),
                                    label: const Text('Seçimleri temizle', style: TextStyle(color: AppColors.acil, fontSize: 12)),
                                  ),
                                ),
                              ),
                          ],
                        ],

                        const SizedBox(height: 24),

                        // ─── KATEGORİ TERCİHLERİ ──────────────────────────
                        _SectionTitle(title: 'Haber Kategorisi Tercihleri', icon: Icons.category_outlined),
                        const SizedBox(height: 4),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text('Ana sayfada hangi kategorileri görmek istediğinizi seçin.',
                              style: const TextStyle(fontSize: 12, color: AppColors.ikinciMetin)),
                        ),
                        const SizedBox(height: 10),

                        _SettingsCard(children: [
                          SwitchListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            title: const Text('Tüm kategorileri göster',
                                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: AppColors.anaMetin)),
                            subtitle: Text(
                              _tumKategoriler ? 'Tüm haber türleri ana sayfada görünür' : 'Seçtiğiniz kategoriler görünür',
                              style: const TextStyle(fontSize: 12, color: AppColors.ikinciMetin),
                            ),
                            value: _tumKategoriler,
                            activeColor: AppColors.anaMavi,
                            onChanged: (v) => setState(() => _tumKategoriler = v),
                          ),
                        ]),

                        if (!_tumKategoriler && _kategoriYuklendi) ...[
                          const SizedBox(height: 12),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(children: [
                              const Text('Görmek İstediğiniz Kategoriler',
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.anaMetin)),
                              const Spacer(),
                              Builder(builder: (ctx) {
                                final cp = ctx.watch<ContentProvider>();
                                final seciliSayisi = cp.kategoriler.length - _engelliKategoriIds.length;
                                return Text('$seciliSayisi / ${cp.kategoriler.length}',
                                    style: const TextStyle(fontSize: 12, color: AppColors.anaMavi, fontWeight: FontWeight.w600));
                              }),
                            ]),
                          ),
                          const SizedBox(height: 8),
                          Builder(builder: (ctx) {
                            final cp = ctx.watch<ContentProvider>();
                            if (cp.kategoriler.isEmpty) return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                            return _SettingsCard(children: [
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: cp.kategoriler.length,
                                separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.cizgi),
                                itemBuilder: (_, i) {
                                  final kat = cp.kategoriler[i];
                                  final secili = !_engelliKategoriIds.contains(kat.id);
                                  final renk = AppTheme.kategoriRenk(kat.slug);
                                  final ikon = AppTheme.kategoriIkon(kat.slug);
                                  return InkWell(
                                    onTap: () => setState(() {
                                      if (secili) {
                                        if (_engelliKategoriIds.length < cp.kategoriler.length - 1) _engelliKategoriIds.add(kat.id);
                                      } else {
                                        _engelliKategoriIds.remove(kat.id);
                                      }
                                    }),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      child: Row(children: [
                                        AnimatedContainer(
                                          duration: const Duration(milliseconds: 150),
                                          width: 22, height: 22,
                                          decoration: BoxDecoration(
                                            color: secili ? AppColors.anaMavi : Colors.transparent,
                                            border: Border.all(color: secili ? AppColors.anaMavi : AppColors.ikinciMetin.withValues(alpha: 0.4), width: 2),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: secili ? const Icon(Icons.check, color: Colors.white, size: 14) : null,
                                        ),
                                        const SizedBox(width: 12),
                                        Container(
                                          width: 28, height: 28,
                                          decoration: BoxDecoration(color: renk.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
                                          child: Icon(ikon, color: renk, size: 14),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(kat.ad, style: TextStyle(fontSize: 14,
                                              color: secili ? AppColors.anaMetin : AppColors.ikinciMetin,
                                              fontWeight: secili ? FontWeight.w500 : FontWeight.normal)),
                                        ),
                                        if (!secili) const Icon(Icons.visibility_off_outlined, size: 16, color: AppColors.ikinciMetin),
                                      ]),
                                    ),
                                  );
                                },
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
                                child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                                  TextButton(
                                    onPressed: () => setState(() => _engelliKategoriIds.clear()),
                                    child: const Text('Tümünü seç', style: TextStyle(fontSize: 12, color: AppColors.anaMavi)),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      final cp = context.read<ContentProvider>();
                                      setState(() => _engelliKategoriIds = cp.kategoriler.map((k) => k.id).toSet()..remove(cp.kategoriler.first.id));
                                    },
                                    child: const Text('Tümünü kaldır', style: TextStyle(fontSize: 12, color: AppColors.acil)),
                                  ),
                                ]),
                              ),
                            ]);
                          }),
                        ],

                        const SizedBox(height: 24),

                        // ─── KAYDET BUTONU ─────────────────────────────────
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: ElevatedButton.icon(
                            onPressed: _saving ? null : _save,
                            icon: _saving
                                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : const Icon(Icons.save_rounded, size: 20),
                            label: Text(_saving ? 'Kaydediliyor...' : 'Tercihleri Kaydet'),
                          ),
                        ),

                        const SizedBox(height: 28),

                        // ─── UYGULAMA AYARLARI ──────────────────────────────
                        _SectionTitle(title: 'Uygulama Ayarları', icon: Icons.settings_outlined),
                        const SizedBox(height: 10),

                        _SettingsCard(children: [
                          _SettingsTile(
                            icon: Icons.privacy_tip_outlined,
                            iconColor: AppColors.anaMavi,
                            title: 'Gizlilik Politikası',
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const KvkkMetniScreen())),
                          ),
                          const Divider(height: 1, color: AppColors.cizgi, indent: 56),
                          _SettingsTile(
                            icon: Icons.article_outlined,
                            iconColor: AppColors.turkuaz,
                            title: 'KVKK Aydınlatma Metni',
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AcikRizaMetniScreen())),
                          ),
                          const Divider(height: 1, color: AppColors.cizgi, indent: 56),
                          _SettingsTile(
                            icon: Icons.description_outlined,
                            iconColor: AppColors.etkinlik,
                            title: 'Kullanım Koşulları',
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const KvkkMetniScreen())),
                          ),
                        ]),

                        const SizedBox(height: 16),

                        _SettingsCard(children: [
                          _SettingsTile(
                            icon: Icons.info_outline_rounded,
                            iconColor: AppColors.ikinciMetin,
                            title: 'Uygulama Hakkında',
                            subtitle: 'Ünye Burada v2.0.0',
                            onTap: () => _showAbout(context),
                          ),
                          const Divider(height: 1, color: AppColors.cizgi, indent: 56),
                          _SettingsTile(
                            icon: Icons.star_outline_rounded,
                            iconColor: AppColors.uyari,
                            title: 'Uygulamayı Değerlendir',
                            onTap: () {},
                          ),
                        ]),

                        const SizedBox(height: 24),

                        // ─── ÇIKIŞ ─────────────────────────────────────────
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (_) => AlertDialog(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                  title: const Text('Çıkış Yap', style: TextStyle(fontWeight: FontWeight.w700)),
                                  content: const Text('Hesabınızdan çıkmak istiyor musunuz?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: const Text('İptal', style: TextStyle(color: AppColors.ikinciMetin)),
                                    ),
                                    ElevatedButton(
                                      onPressed: () => Navigator.pop(context, true),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.acil,
                                        minimumSize: const Size(0, 40),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      ),
                                      child: const Text('Çıkış Yap'),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true && mounted) {
                                await context.read<AuthProvider>().logout();
                                if (mounted) Navigator.pushReplacementNamed(context, '/login');
                              }
                            },
                            icon: const Icon(Icons.logout_rounded, color: AppColors.acil, size: 20),
                            label: const Text('Çıkış Yap', style: TextStyle(color: AppColors.acil, fontWeight: FontWeight.w600)),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.acil),
                              minimumSize: const Size(double.infinity, 52),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                          ),
                        ),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  void _showAbout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72, height: 72,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppColors.lacivermavi, AppColors.anaMavi]),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Center(child: Text('ÜB', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.white))),
            ),
            const SizedBox(height: 16),
            const Text('Ünye Burada', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.anaMetin)),
            const SizedBox(height: 4),
            const Text('Sürüm 2.0.0', style: TextStyle(fontSize: 13, color: AppColors.ikinciMetin)),
            const SizedBox(height: 12),
            const Text('Ünye Belediyesi\'nin resmi mobil uygulamasıdır.\nÜnye\'nin haberi burada, hizmeti yanınızda.',
                textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: AppColors.ikinciMetin, height: 1.5)),
            const SizedBox(height: 16),
            const Text('© 2024 Ünye Belediyesi', style: TextStyle(fontSize: 11, color: AppColors.ikinciMetin)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam', style: TextStyle(color: AppColors.anaMavi, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

// ─── YARDIMCI WİDGETLER ───────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;
  const _SectionTitle({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.anaMavi),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.anaMetin)),
        ],
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 2))],
        ),
        child: Column(children: children),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const _SettingsTile({required this.icon, required this.iconColor, required this.title, required this.onTap, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.anaMetin)),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitle!, style: const TextStyle(fontSize: 12, color: AppColors.ikinciMetin)),
                  ],
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, size: 20, color: AppColors.ikinciMetin),
          ],
        ),
      ),
    );
  }
}

class _ModButon extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool aktif;
  final VoidCallback onTap;
  const _ModButon({required this.label, required this.icon, required this.aktif, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: aktif ? AppColors.anaMavi : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: aktif ? AppColors.anaMavi : AppColors.cizgi),
          boxShadow: aktif
              ? [BoxShadow(color: AppColors.anaMavi.withValues(alpha: 0.25), blurRadius: 8, offset: const Offset(0, 2))]
              : const [BoxShadow(color: Color(0x08000000), blurRadius: 4)],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: aktif ? Colors.white : AppColors.ikinciMetin),
            const SizedBox(width: 6),
            Flexible(
              child: Text(label, textAlign: TextAlign.center,
                  style: TextStyle(color: aktif ? Colors.white : AppColors.ikinciMetin,
                      fontWeight: aktif ? FontWeight.w600 : FontWeight.normal, fontSize: 13)),
            ),
          ],
        ),
      ),
    );
  }
}

class _PuanRozetKart extends StatefulWidget {
  final int userId;
  const _PuanRozetKart({required this.userId});

  @override
  State<_PuanRozetKart> createState() => _PuanRozetKartState();
}

class _PuanRozetKartState extends State<_PuanRozetKart> {
  Map<String, dynamic>? _data;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final d = await ApiService().getBenimPuan();
      setState(() { _data = d; _loading = false; });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  IconData _rozetIkon(String? rozet) {
    switch (rozet) {
      case 'Ünye Elçisi': return Icons.emoji_events_rounded;
      case 'Güvenilir Vatandaş': return Icons.star_rounded;
      case 'Aktif Vatandaş': return Icons.workspace_premium_rounded;
      default: return Icons.person_add_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Container(
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 2))],
        ),
        child: const Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.anaMavi)),
      );
    }
    if (_data == null) return const SizedBox.shrink();

    final puan = _data!['puan'] ?? 0;
    final rozet = _data!['rozet'] ?? 'Yeni Üye';
    final int sonrakiPuan = puan < 50 ? 50 : puan < 150 ? 150 : puan < 500 ? 500 : 1000;
    final double ilerleme = puan < 50 ? puan / 50.0 : puan < 150 ? (puan - 50) / 100.0 : puan < 500 ? (puan - 150) / 350.0 : 1.0;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFD97706), Color(0xFFF59E0B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: const Color(0xFFF59E0B).withValues(alpha: 0.35), blurRadius: 16, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 52, height: 52,
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
                child: Icon(_rozetIkon(rozet), color: Colors.white, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(rozet, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                    Text('$puan Puan', style: const TextStyle(color: Colors.white70, fontSize: 13)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Sonraki rozet', style: TextStyle(color: Colors.white70, fontSize: 10)),
                  Text(
                    puan >= 500 ? 'Maksimum!' : '${sonrakiPuan - puan} puan',
                    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ],
          ),
          if (puan < 1000) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: ilerleme.clamp(0.0, 1.0),
                backgroundColor: Colors.white.withValues(alpha: 0.25),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                minHeight: 5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
