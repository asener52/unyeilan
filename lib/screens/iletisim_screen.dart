import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/theme.dart';
import 'webview_ekrani.dart';

class IletisimScreen extends StatelessWidget {
  const IletisimScreen({super.key});

  /// Telefon, WhatsApp, E-posta: harici uygulama
  Future<void> _hariciAc(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  /// Web / sosyal medya linkleri: uygulama içi WebView
  void _webAc(BuildContext context, String url, String baslik) {
    WebViewEkrani.ac(
      context,
      url: url,
      baslik: baslik,
      altBaslik: 'unye.bel.tr',
      ikon: Icons.language,
      ikonRenk: AppTheme.primary,
    );
  }

  // Geriye dönük uyumluluk için (eski kod çağrıları)
  Future<void> _ac(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('İletişim'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            tooltip: 'Web sitesini aç',
            onPressed: () => _webAc(context, 'https://www.unye.bel.tr/iletisim/', 'İletişim'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Belediye başlık kartı
          Container(
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1A56DB), Color(0xFF0E3A9E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 6)),
              ],
            ),
            child: Column(
              children: [
                ClipOval(
                  child: Image.asset('assets/images/logo.jpg', width: 72, height: 72, fit: BoxFit.cover),
                ),
                const SizedBox(height: 14),
                const Text('Ünye Belediyesi', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                const Text(
                  'Kaledere Mah. Belediye Cad. No:3\n52300 Ünye / ORDU',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.5),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          _Section(
            title: '📞 Telefon & İletişim',
            children: [
              _ContactTile(
                icon: Icons.phone,
                title: 'Santral',
                subtitle: '0452 323 19 41',
                color: Colors.blue,
                onTap: () => _ac('tel:+904523231941'),
              ),
              _ContactTile(
                icon: Icons.chat,
                title: 'WhatsApp',
                subtitle: '0530 948 75 52',
                color: const Color(0xFF25D366),
                onTap: () => _ac('https://wa.me/905309487552'),
              ),
              _ContactTile(
                icon: Icons.print,
                title: 'Faks',
                subtitle: '0452 324 84 05',
                color: Colors.grey,
                onTap: () => _ac('tel:+904523248405'),
              ),
              _ContactTile(
                icon: Icons.email_outlined,
                title: 'KEP E-posta',
                subtitle: 'unyebelediyesi@hs01.kep.tr',
                color: Colors.orange,
                onTap: () => _ac('mailto:unyebelediyesi@hs01.kep.tr'),
              ),
            ],
          ),

          const SizedBox(height: 16),

          _Section(
            title: '📍 Adres',
            children: [
              _ContactTile(
                icon: Icons.location_on,
                title: 'Belediye Binası',
                subtitle: 'Kaledere Mah. Belediye Cad. No:3, 52300 Ünye/Ordu',
                color: Colors.red,
                onTap: () => _webAc(context, 'https://www.google.com/maps/search/?api=1&query=Ünye+Belediyesi', 'Harita'),
              ),
            ],
          ),

          const SizedBox(height: 16),

          _Section(
            title: '🌐 Web Sitesi',
            children: [
              _ContactTile(
                icon: Icons.language,
                title: 'unye.bel.tr',
                subtitle: 'Resmi belediye web sitesi',
                color: AppTheme.primary,
                onTap: () => _webAc(context, 'https://www.unye.bel.tr', 'Ünye Belediyesi'),
              ),
            ],
          ),

          const SizedBox(height: 16),

          _Section(
            title: '🌍 Sosyal Medya',
            children: [
              _ContactTile(
                icon: Icons.facebook,
                title: 'Facebook',
                subtitle: 'Ünye Belediyesi',
                color: const Color(0xFF1877F2),
                onTap: () => _webAc(context, 'https://www.facebook.com/unyebelediyesi', 'Facebook'),
              ),
              _ContactTile(
                icon: Icons.camera_alt_outlined,
                title: 'Instagram',
                subtitle: '@unyebelediyesi',
                color: const Color(0xFFE1306C),
                onTap: () => _webAc(context, 'https://www.instagram.com/unyebelediyesi', 'Instagram'),
              ),
              _ContactTile(
                icon: Icons.alternate_email,
                title: 'X (Twitter)',
                subtitle: '@unyebelediyesi',
                color: Colors.black87,
                onTap: () => _webAc(context, 'https://twitter.com/unyebelediyesi', 'X (Twitter)'),
              ),
              _ContactTile(
                icon: Icons.play_circle_outline,
                title: 'YouTube',
                subtitle: 'Ünye Belediyesi',
                color: Colors.red,
                onTap: () => _webAc(context, 'https://www.youtube.com/@unyebelediyesi', 'YouTube'),
              ),
            ],
          ),

          const SizedBox(height: 16),

          _Section(
            title: '🕐 Çalışma Saatleri',
            children: [
              _InfoTile(
                icon: Icons.work_outline,
                title: 'Hafta İçi',
                subtitle: 'Pazartesi – Cuma: 08:00 – 17:00',
              ),
              _InfoTile(
                icon: Icons.weekend_outlined,
                title: 'Hafta Sonu',
                subtitle: 'Cumartesi – Pazar: Kapalı',
              ),
            ],
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black54),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
          ),
          child: Column(
            children: children.asMap().entries.map((e) => Column(
              children: [
                e.value,
                if (e.key < children.length - 1) const Divider(height: 1, indent: 56),
              ],
            )).toList(),
          ),
        ),
      ],
    );
  }
}

class _ContactTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ContactTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      subtitle: Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
      trailing: Icon(Icons.arrow_forward_ios, size: 13, color: Colors.grey[400]),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _InfoTile({required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: Colors.grey[600], size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      subtitle: Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
    );
  }
}
