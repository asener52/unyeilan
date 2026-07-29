import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../utils/theme.dart';

/// Uygulama içi evrensel WebView ekranı.
/// Tüm web bağlantıları buradan açılır — Chrome'a atmaz.
class WebViewEkrani extends StatefulWidget {
  final String url;
  final String baslik;
  final String? altBaslik;
  final IconData? ikon;
  final Color? ikonRenk;

  const WebViewEkrani({
    super.key,
    required this.url,
    required this.baslik,
    this.altBaslik,
    this.ikon,
    this.ikonRenk,
  });

  /// Kısayol: push ile aç
  static Future<void> ac(
    BuildContext context, {
    required String url,
    required String baslik,
    String? altBaslik,
    IconData? ikon,
    Color? ikonRenk,
  }) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WebViewEkrani(
          url: url,
          baslik: baslik,
          altBaslik: altBaslik,
          ikon: ikon,
          ikonRenk: ikonRenk,
        ),
      ),
    );
  }

  @override
  State<WebViewEkrani> createState() => _WebViewEkraniState();
}

class _WebViewEkraniState extends State<WebViewEkrani> {
  late final WebViewController _ctrl;
  bool _yukleniyor = true;
  int _yuklemeYuzdesi = 0;
  bool _geriVar = false;
  bool _ileriVar = false;
  String _mevcutUrl = '';

  @override
  void initState() {
    super.initState();
    _mevcutUrl = widget.url;
    _ctrl = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent(
        'Mozilla/5.0 (Linux; Android 13; Mobile) AppleWebKit/537.36 '
        '(KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36',
      )
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (url) {
          setState(() {
            _yukleniyor = true;
            _yuklemeYuzdesi = 0;
            _mevcutUrl = url;
          });
        },
        onProgress: (p) {
          setState(() => _yuklemeYuzdesi = p);
        },
        onPageFinished: (url) async {
          final geri = await _ctrl.canGoBack();
          final ileri = await _ctrl.canGoForward();
          if (mounted) {
            setState(() {
              _yukleniyor = false;
              _geriVar = geri;
              _ileriVar = ileri;
              _mevcutUrl = url;
            });
          }
        },
        onWebResourceError: (err) {
          if (mounted) setState(() => _yukleniyor = false);
        },
      ))
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    final ikonRenk = widget.ikonRenk ?? AppTheme.primary;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // ─── BAŞLIK BARI ───
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [ikonRenk, Color.lerp(ikonRenk, Colors.black, 0.25)!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(4, 8, 12, 10),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        if (widget.ikon != null) ...[
                          Container(
                            width: 36, height: 36,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(widget.ikon, color: Colors.white, size: 20),
                          ),
                          const SizedBox(width: 10),
                        ],
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.baslik,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (widget.altBaslik != null)
                                Text(
                                  widget.altBaslik!,
                                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.refresh, color: Colors.white, size: 22),
                          onPressed: () => _ctrl.reload(),
                          tooltip: 'Yenile',
                        ),
                      ],
                    ),
                  ),
                  // Yükleme ilerleme çubuğu
                  if (_yukleniyor)
                    LinearProgressIndicator(
                      value: _yuklemeYuzdesi / 100,
                      backgroundColor: Colors.white24,
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                      minHeight: 2,
                    ),
                ],
              ),
            ),
          ),

          // ─── URL ÇUBUĞU (mini) ───
          if (_mevcutUrl.isNotEmpty)
            Container(
              color: Colors.grey.shade100,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  const Icon(Icons.lock, size: 12, color: Colors.green),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      _mevcutUrl
                          .replaceFirst('https://', '')
                          .replaceFirst('http://', ''),
                      style: const TextStyle(fontSize: 11, color: Colors.black54),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

          // ─── WEB VIEW ───
          Expanded(
            child: WebViewWidget(controller: _ctrl),
          ),

          // ─── ALT NAVİGASYON ───
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, -1))],
            ),
            child: SafeArea(
              top: false,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _NavBtn(
                    icon: Icons.arrow_back_ios,
                    label: 'Geri',
                    aktif: _geriVar,
                    onTap: _geriVar ? () => _ctrl.goBack() : null,
                  ),
                  _NavBtn(
                    icon: Icons.arrow_forward_ios,
                    label: 'İleri',
                    aktif: _ileriVar,
                    onTap: _ileriVar ? () => _ctrl.goForward() : null,
                  ),
                  _NavBtn(
                    icon: Icons.home_outlined,
                    label: 'Ana Sayfa',
                    aktif: true,
                    onTap: () => _ctrl.loadRequest(Uri.parse(widget.url)),
                  ),
                  _NavBtn(
                    icon: Icons.refresh,
                    label: 'Yenile',
                    aktif: true,
                    onTap: () => _ctrl.reload(),
                  ),
                  _NavBtn(
                    icon: Icons.close,
                    label: 'Kapat',
                    aktif: true,
                    onTap: () => Navigator.pop(context),
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

class _NavBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool aktif;
  final VoidCallback? onTap;

  const _NavBtn({required this.icon, required this.label, required this.aktif, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: aktif ? AppTheme.primary : Colors.grey.shade300),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(fontSize: 9, color: aktif ? AppTheme.primary : Colors.grey.shade300),
            ),
          ],
        ),
      ),
    );
  }
}
