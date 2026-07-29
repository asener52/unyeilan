import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/content_provider.dart';
import '../models/harita.dart';
import '../utils/theme.dart';

class HaritaScreen extends StatefulWidget {
  const HaritaScreen({super.key});

  @override
  State<HaritaScreen> createState() => _HaritaScreenState();
}

class _HaritaScreenState extends State<HaritaScreen> {
  final MapController _mapController = MapController();
  int? _aktifKategoriId;
  HaritaNokta? _secilenNokta;
  bool _listePaneliAcik = false;

  static const LatLng _unyeMerkez = LatLng(41.1339, 37.2679); // Ünye merkez

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ContentProvider>().loadHarita();
    });
  }

  void _filtrele(int? kategoriId) {
    setState(() {
      _aktifKategoriId = kategoriId;
      _secilenNokta = null;
      _listePaneliAcik = false;
    });
    context.read<ContentProvider>().loadHarita(kategoriId: kategoriId);
  }

  void _noktaSec(HaritaNokta nokta) {
    setState(() {
      _secilenNokta = nokta;
      _listePaneliAcik = false;
    });
    // Haritayı seçilen noktaya animasyonlu taşı ve yakınlaştır
    Future.delayed(const Duration(milliseconds: 100), () {
      _mapController.move(LatLng(nokta.lat, nokta.lng), 17);
    });
  }

  Color _hexRenk(String? hex) {
    if (hex == null) return AppTheme.primary;
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return AppTheme.primary;
    }
  }

  // Noktaları kategoriye göre grupla
  Map<String, List<HaritaNokta>> _grupla(List<HaritaNokta> noktalar) {
    final Map<String, List<HaritaNokta>> gruplar = {};
    for (final n in noktalar) {
      final kategori = n.kategoriAd ?? 'Diğer';
      gruplar.putIfAbsent(kategori, () => []).add(n);
    }
    return gruplar;
  }

  @override
  Widget build(BuildContext context) {
    final cp = context.watch<ContentProvider>();

    return Scaffold(
      body: Stack(
        children: [
          // ── Harita ──────────────────────────────────────────────
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _unyeMerkez,
              initialZoom: 13,
              onTap: (_, __) => setState(() {
                _secilenNokta = null;
                _listePaneliAcik = false;
              }),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'tr.bel.unye.burada',
              ),
              MarkerLayer(
                markers: cp.haritaNoktalar.map((nokta) {
                  final renk = _hexRenk(nokta.kategoriRenk);
                  final secili = _secilenNokta?.id == nokta.id;
                  return Marker(
                    point: LatLng(nokta.lat, nokta.lng),
                    width: secili ? 54 : 44,
                    height: secili ? 54 : 44,
                    child: GestureDetector(
                      onTap: () => _noktaSec(nokta),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: renk,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: secili ? 3 : 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: renk.withOpacity(secili ? 0.6 : 0.3),
                              blurRadius: secili ? 16 : 8,
                              spreadRadius: secili ? 4 : 2,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.place,
                          color: Colors.white,
                          size: secili ? 28 : 22,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),

          // ── Üst bar + kategori filtresi ──────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1A56DB), Color(0xFF0E3A9E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
                      child: Row(
                        children: [
                          const Icon(Icons.map, color: Colors.white, size: 22),
                          const SizedBox(width: 8),
                          const Text(
                            'Harita',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          // Liste paneli aç/kapa
                          if (cp.haritaNoktalar.isNotEmpty)
                            Tooltip(
                              message: 'Nokta Listesi',
                              child: IconButton(
                                onPressed: () => setState(() {
                                  _listePaneliAcik = !_listePaneliAcik;
                                  if (_listePaneliAcik) _secilenNokta = null;
                                }),
                                icon: Icon(
                                  _listePaneliAcik
                                      ? Icons.format_list_bulleted_outlined
                                      : Icons.format_list_bulleted,
                                  color: _listePaneliAcik
                                      ? Colors.yellow
                                      : Colors.white,
                                ),
                              ),
                            ),
                          // Merkeze dön
                          IconButton(
                            onPressed: () =>
                                _mapController.move(_unyeMerkez, 13),
                            icon: const Icon(
                              Icons.my_location,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Kategori chip filtreleri
                    if (cp.haritaKategoriler.isNotEmpty)
                      SizedBox(
                        height: 36,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                          children: [
                            _KategoriChip(
                              label: 'Tümü',
                              aktif: _aktifKategoriId == null,
                              renk: AppTheme.primary,
                              onTap: () => _filtrele(null),
                            ),
                            ...cp.haritaKategoriler.map((k) => _KategoriChip(
                                  label: k.ad,
                                  aktif: _aktifKategoriId == k.id,
                                  renk: _hexRenk(k.renk),
                                  onTap: () => _filtrele(k.id),
                                )),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          // ── Liste Paneli (sağ/alt sayfa içi panel) ──────────────
          if (_listePaneliAcik)
            Positioned(
              top: 0,
              bottom: 0,
              right: 0,
              width: MediaQuery.of(context).size.width > 500
                  ? 320
                  : MediaQuery.of(context).size.width * 0.85,
              child: _NoktalListePaneli(
                noktalar: cp.haritaNoktalar,
                grupla: _grupla,
                hexRenk: _hexRenk,
                secilenId: _secilenNokta?.id,
                onNokta: _noktaSec,
                onKapat: () => setState(() => _listePaneliAcik = false),
              ),
            ),

          // ── Seçilen nokta detay kartı ───────────────────────────
          if (_secilenNokta != null && !_listePaneliAcik)
            Positioned(
              bottom: 24,
              left: 16,
              right: 16,
              child: _NoktaDetayKart(
                nokta: _secilenNokta!,
                hexRenk: _hexRenk,
                onKapat: () => setState(() => _secilenNokta = null),
                onListeAc: () => setState(() {
                  _listePaneliAcik = true;
                  _secilenNokta = null;
                }),
              ),
            ),

          // ── Nokta sayısı badge ──────────────────────────────────
          if (cp.haritaNoktalar.isNotEmpty &&
              _secilenNokta == null &&
              !_listePaneliAcik)
            Positioned(
              bottom: 24,
              left: 16,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.place, size: 14, color: AppTheme.primary),
                    const SizedBox(width: 4),
                    Text(
                      '${cp.haritaNoktalar.length} nokta',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
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

// ── Nokta Liste Paneli ───────────────────────────────────────────────────────
class _NoktalListePaneli extends StatelessWidget {
  final List<HaritaNokta> noktalar;
  final Map<String, List<HaritaNokta>> Function(List<HaritaNokta>) grupla;
  final Color Function(String?) hexRenk;
  final int? secilenId;
  final void Function(HaritaNokta) onNokta;
  final VoidCallback onKapat;

  const _NoktalListePaneli({
    required this.noktalar,
    required this.grupla,
    required this.hexRenk,
    required this.secilenId,
    required this.onNokta,
    required this.onKapat,
  });

  @override
  Widget build(BuildContext context) {
    final gruplar = grupla(noktalar);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 20,
            offset: const Offset(-4, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Panel başlığı
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1A56DB), Color(0xFF0E3A9E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
                child: Row(
                  children: [
                    const Icon(Icons.format_list_bulleted,
                        color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Noktalar (${noktalar.length})',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: onKapat,
                      icon: const Icon(Icons.close,
                          color: Colors.white, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 36,
                        minHeight: 36,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Gruplu liste
          Expanded(
            child: noktalar.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('🗺️', style: TextStyle(fontSize: 40)),
                        SizedBox(height: 8),
                        Text('Nokta bulunamadı',
                            style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  )
                : ListView(
                    padding: EdgeInsets.zero,
                    children: gruplar.entries.map((entry) {
                      final kategoriAd = entry.key;
                      final noktaListesi = entry.value;
                      // Kategori rengi ilk noktadan al
                      final renk = hexRenk(noktaListesi.first.kategoriRenk);

                      return Theme(
                        data: Theme.of(context)
                            .copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          initiallyExpanded: true,
                          tilePadding:
                              const EdgeInsets.symmetric(horizontal: 16),
                          leading: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: renk,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.place,
                                color: Colors.white, size: 18),
                          ),
                          title: Text(
                            kategoriAd,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: renk,
                            ),
                          ),
                          subtitle: Text(
                            '${noktaListesi.length} nokta',
                            style: const TextStyle(
                                fontSize: 11, color: Colors.grey),
                          ),
                          children: noktaListesi.map((nokta) {
                            final secili = secilenId == nokta.id;
                            return InkWell(
                              onTap: () => onNokta(nokta),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                color: secili
                                    ? renk.withOpacity(0.08)
                                    : Colors.transparent,
                                padding: const EdgeInsets.fromLTRB(
                                    56, 10, 16, 10),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            nokta.ad,
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: secili
                                                  ? FontWeight.bold
                                                  : FontWeight.w500,
                                              color: secili
                                                  ? renk
                                                  : const Color(0xFF1F2937),
                                            ),
                                          ),
                                          if (nokta.adres != null &&
                                              nokta.adres!.isNotEmpty)
                                            Padding(
                                              padding:
                                                  const EdgeInsets.only(top: 2),
                                              child: Text(
                                                nokta.adres!,
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.grey,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      secili
                                          ? Icons.my_location
                                          : Icons.chevron_right,
                                      size: 18,
                                      color: secili ? renk : Colors.grey,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }
}

// ── Kategori Chip ────────────────────────────────────────────────────────────
class _KategoriChip extends StatelessWidget {
  final String label;
  final bool aktif;
  final Color renk;
  final VoidCallback onTap;

  const _KategoriChip({
    required this.label,
    required this.aktif,
    required this.renk,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: aktif ? Colors.white : Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: aktif ? renk : Colors.white,
          ),
        ),
      ),
    );
  }
}

// ── Nokta Detay Kartı ────────────────────────────────────────────────────────
class _NoktaDetayKart extends StatelessWidget {
  final HaritaNokta nokta;
  final Color Function(String?) hexRenk;
  final VoidCallback onKapat;
  final VoidCallback onListeAc;

  const _NoktaDetayKart({
    required this.nokta,
    required this.hexRenk,
    required this.onKapat,
    required this.onListeAc,
  });

  @override
  Widget build(BuildContext context) {
    final renk = hexRenk(nokta.kategoriRenk);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Başlık
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 8, 12),
            decoration: BoxDecoration(
              color: renk.withOpacity(0.08),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: renk,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child:
                      const Icon(Icons.place, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nokta.ad,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      if (nokta.kategoriAd != null)
                        Text(
                          nokta.kategoriAd!,
                          style: TextStyle(
                            fontSize: 12,
                            color: renk,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                ),
                // Listeye git butonu
                IconButton(
                  onPressed: onListeAc,
                  icon: const Icon(Icons.format_list_bulleted,
                      size: 20, color: Colors.grey),
                  tooltip: 'Listeye dön',
                ),
                IconButton(
                  onPressed: onKapat,
                  icon: const Icon(Icons.close, size: 20, color: Colors.grey),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (nokta.aciklama != null && nokta.aciklama!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      nokta.aciklama!,
                      style: const TextStyle(
                          fontSize: 13, color: AppTheme.textSecondary),
                    ),
                  ),
                if (nokta.adres != null && nokta.adres!.isNotEmpty)
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 15, color: AppTheme.textSecondary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          nokta.adres!,
                          style: const TextStyle(
                              fontSize: 13, color: AppTheme.textSecondary),
                        ),
                      ),
                    ],
                  ),
                if (nokta.telefon != null && nokta.telefon!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.phone_outlined,
                          size: 15, color: AppTheme.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        nokta.telefon!,
                        style: const TextStyle(
                            fontSize: 13, color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (nokta.telefon != null && nokta.telefon!.isNotEmpty)
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () =>
                              launchUrl(Uri.parse('tel:${nokta.telefon}')),
                          icon: const Icon(Icons.phone, size: 15),
                          label: const Text('Ara',
                              style: TextStyle(fontSize: 13)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: renk,
                            side: BorderSide(color: renk),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                    if (nokta.telefon != null && nokta.telefon!.isNotEmpty)
                      const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => launchUrl(Uri.parse(
                            'https://maps.google.com/?q=${nokta.lat},${nokta.lng}')),
                        icon: const Icon(Icons.directions, size: 15),
                        label: const Text('Yol Tarifi',
                            style: TextStyle(fontSize: 13)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: renk,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
