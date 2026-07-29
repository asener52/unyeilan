import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../utils/theme.dart';

class VergiScreen extends StatefulWidget {
  const VergiScreen({super.key});

  @override
  State<VergiScreen> createState() => _VergiScreenState();
}

class _VergiScreenState extends State<VergiScreen> {
  late final WebViewController _controller;
  bool _loading = true;

  static const String _vergiUrl =
      'https://canli.belediye.gov.tr/vpos/debt-inquiry/natural-type-person-form?token=2a69005b-16a7-47e4-ac56-e3e879380630';

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (_) => setState(() => _loading = true),
        onPageFinished: (_) => setState(() => _loading = false),
      ))
      ..loadRequest(Uri.parse(_vergiUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      body: Column(
        children: [
          // Üst bar
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
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: Row(
                  children: [
                    // Geri butonu (Navigator stack'te sayfa varsa göster)
                    if (Navigator.canPop(context)) ...[
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        tooltip: 'Geri',
                      ),
                      const SizedBox(width: 4),
                    ],
                    Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.account_balance_wallet, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Vergi Borcu Sorgula', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                          Text('Emlak & Çevre Temizlik Vergisi', style: TextStyle(color: Colors.white70, fontSize: 12)),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => _controller.reload(),
                      icon: const Icon(Icons.refresh, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bilgi kartı
          Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF93C5FD)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Color(0xFF1D4ED8), size: 18),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'TC Kimlik No ve doğum yılınızla vergi borçlarınızı sorgulayıp online ödeme yapabilirsiniz.',
                    style: TextStyle(fontSize: 12, color: Color(0xFF1D4ED8)),
                  ),
                ),
              ],
            ),
          ),

          // WebView
          Expanded(
            child: Stack(
              children: [
                WebViewWidget(controller: _controller),
                if (_loading)
                  const Center(
                    child: CircularProgressIndicator(color: AppTheme.primary),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
