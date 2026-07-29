import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _emailFocus = FocusNode();
  final _passFocus = FocusNode();
  bool _obscure = true;
  String? _emailError;
  String? _passError;

  @override
  void initState() {
    super.initState();
    _emailFocus.addListener(() => setState(() {}));
    _passFocus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _emailFocus.dispose();
    _passFocus.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() {
      _emailError = _validateEmail(_emailCtrl.text);
      _passError = _validatePass(_passCtrl.text);
    });
    if (_emailError != null || _passError != null) return;

    final ok = await context.read<AuthProvider>().login(
          _emailCtrl.text.trim(),
          _passCtrl.text,
        );
    if (!mounted) return;
    if (ok) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.read<AuthProvider>().error ?? 'Giriş yapılamadı'),
          backgroundColor: AppColors.acil,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  String? _validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'E-posta adresi gerekli';
    if (!v.contains('@') || !v.contains('.')) return 'Geçerli bir e-posta girin';
    return null;
  }

  String? _validatePass(String? v) {
    if (v == null || v.isEmpty) return 'Şifre gerekli';
    if (v.length < 6) return 'En az 6 karakter olmalı';
    return null;
  }

  void _misafirDevam() {
    // Misafir akışı: mevcut home rotasına doğrudan yönlendir
    // Auth gerektiren özellikler home içinde kilitlidir
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final mq = MediaQuery.of(context);
    final isLandscape = mq.orientation == Orientation.landscape;
    final screenW = mq.size.width;
    final cardMaxW = isLandscape ? 460.0 : (screenW - 40.0).clamp(0.0, 460.0);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: AppColors.lacivermavi,
        body: Stack(
          children: [
            // ── Arka plan gradient ──────────────────────────────────────
            Positioned.fill(
              child: _GradientArkaplan(isLandscape: isLandscape),
            ),

            // ── İçerik ─────────────────────────────────────────────────
            SafeArea(
              child: isLandscape
                  ? _LandscapeLayout(
                      cardMaxW: cardMaxW,
                      auth: auth,
                      emailCtrl: _emailCtrl,
                      passCtrl: _passCtrl,
                      emailFocus: _emailFocus,
                      passFocus: _passFocus,
                      obscure: _obscure,
                      emailError: _emailError,
                      passError: _passError,
                      onToggleObscure: () => setState(() => _obscure = !_obscure),
                      onLogin: _login,
                      onMisafir: _misafirDevam,
                      onEmailChanged: (v) => setState(() => _emailError = null),
                      onPassChanged: (v) => setState(() => _passError = null),
                    )
                  : _PortraitLayout(
                      cardMaxW: cardMaxW,
                      auth: auth,
                      emailCtrl: _emailCtrl,
                      passCtrl: _passCtrl,
                      emailFocus: _emailFocus,
                      passFocus: _passFocus,
                      obscure: _obscure,
                      emailError: _emailError,
                      passError: _passError,
                      onToggleObscure: () => setState(() => _obscure = !_obscure),
                      onLogin: _login,
                      onMisafir: _misafirDevam,
                      onEmailChanged: (v) => setState(() => _emailError = null),
                      onPassChanged: (v) => setState(() => _passError = null),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Gradient arka plan ──────────────────────────────────────────────────────
class _GradientArkaplan extends StatelessWidget {
  final bool isLandscape;
  const _GradientArkaplan({required this.isLandscape});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DalgaPainter(),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.lacivermavi, AppColors.anaMavi],
            stops: [0.0, 1.0],
          ),
        ),
      ),
    );
  }
}

class _DalgaPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..style = PaintingStyle.fill;

    // Dalga 1
    final path1 = Path();
    path1.moveTo(0, size.height * 0.55);
    path1.quadraticBezierTo(size.width * 0.25, size.height * 0.48, size.width * 0.5, size.height * 0.54);
    path1.quadraticBezierTo(size.width * 0.75, size.height * 0.60, size.width, size.height * 0.52);
    path1.lineTo(size.width, size.height);
    path1.lineTo(0, size.height);
    path1.close();
    canvas.drawPath(path1, paint);

    // Dalga 2
    final paint2 = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..style = PaintingStyle.fill;
    final path2 = Path();
    path2.moveTo(0, size.height * 0.65);
    path2.quadraticBezierTo(size.width * 0.3, size.height * 0.58, size.width * 0.6, size.height * 0.64);
    path2.quadraticBezierTo(size.width * 0.8, size.height * 0.68, size.width, size.height * 0.62);
    path2.lineTo(size.width, size.height);
    path2.lineTo(0, size.height);
    path2.close();
    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(_) => false;
}

// ── Portrait layout ─────────────────────────────────────────────────────────
class _PortraitLayout extends StatelessWidget {
  final double cardMaxW;
  final AuthProvider auth;
  final TextEditingController emailCtrl, passCtrl;
  final FocusNode emailFocus, passFocus;
  final bool obscure;
  final String? emailError, passError;
  final VoidCallback onToggleObscure, onLogin, onMisafir;
  final ValueChanged<String> onEmailChanged, onPassChanged;

  const _PortraitLayout({
    required this.cardMaxW,
    required this.auth,
    required this.emailCtrl,
    required this.passCtrl,
    required this.emailFocus,
    required this.passFocus,
    required this.obscure,
    required this.emailError,
    required this.passError,
    required this.onToggleObscure,
    required this.onLogin,
    required this.onMisafir,
    required this.onEmailChanged,
    required this.onPassChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height -
              MediaQuery.of(context).padding.top -
              MediaQuery.of(context).padding.bottom,
        ),
        child: IntrinsicHeight(
          child: Column(
            children: [
              // ── Üst hero bölüm ──────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 36, 24, 0),
                child: _HeroBolum(),
              ),
              const SizedBox(height: 28),

              // ── Form kartı (üste biniyor) ────────────────────────────
              Expanded(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    width: cardMaxW,
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.lacivermavi.withValues(alpha: 0.18),
                          blurRadius: 32,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: _FormIcerigi(
                      auth: auth,
                      emailCtrl: emailCtrl,
                      passCtrl: passCtrl,
                      emailFocus: emailFocus,
                      passFocus: passFocus,
                      obscure: obscure,
                      emailError: emailError,
                      passError: passError,
                      onToggleObscure: onToggleObscure,
                      onLogin: onLogin,
                      onMisafir: onMisafir,
                      onEmailChanged: onEmailChanged,
                      onPassChanged: onPassChanged,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Landscape layout ─────────────────────────────────────────────────────────
class _LandscapeLayout extends StatelessWidget {
  final double cardMaxW;
  final AuthProvider auth;
  final TextEditingController emailCtrl, passCtrl;
  final FocusNode emailFocus, passFocus;
  final bool obscure;
  final String? emailError, passError;
  final VoidCallback onToggleObscure, onLogin, onMisafir;
  final ValueChanged<String> onEmailChanged, onPassChanged;

  const _LandscapeLayout({
    required this.cardMaxW,
    required this.auth,
    required this.emailCtrl,
    required this.passCtrl,
    required this.emailFocus,
    required this.passFocus,
    required this.obscure,
    required this.emailError,
    required this.passError,
    required this.onToggleObscure,
    required this.onLogin,
    required this.onMisafir,
    required this.onEmailChanged,
    required this.onPassChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Sol: hero
        Expanded(
          flex: 4,
          child: Center(child: _HeroBolum()),
        ),
        // Sağ: form
        Expanded(
          flex: 6,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.lacivermavi.withValues(alpha: 0.18),
                        blurRadius: 32,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: _FormIcerigi(
                    auth: auth,
                    emailCtrl: emailCtrl,
                    passCtrl: passCtrl,
                    emailFocus: emailFocus,
                    passFocus: passFocus,
                    obscure: obscure,
                    emailError: emailError,
                    passError: passError,
                    onToggleObscure: onToggleObscure,
                    onLogin: onLogin,
                    onMisafir: onMisafir,
                    onEmailChanged: onEmailChanged,
                    onPassChanged: onPassChanged,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Hero bölüm (logo + başlık) ───────────────────────────────────────────────
class _HeroBolum extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Logo
        Semantics(
          label: 'Ünye Belediyesi logosu',
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Image.asset(
                'assets/images/logo.jpg',
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          'Ünye Burada',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Şehrinizden haberdar olun',
          style: TextStyle(
            fontSize: 13,
            color: Colors.white70,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ── Form içeriği ─────────────────────────────────────────────────────────────
class _FormIcerigi extends StatelessWidget {
  final AuthProvider auth;
  final TextEditingController emailCtrl, passCtrl;
  final FocusNode emailFocus, passFocus;
  final bool obscure;
  final String? emailError, passError;
  final VoidCallback onToggleObscure, onLogin, onMisafir;
  final ValueChanged<String> onEmailChanged, onPassChanged;

  const _FormIcerigi({
    required this.auth,
    required this.emailCtrl,
    required this.passCtrl,
    required this.emailFocus,
    required this.passFocus,
    required this.obscure,
    required this.emailError,
    required this.passError,
    required this.onToggleObscure,
    required this.onLogin,
    required this.onMisafir,
    required this.onEmailChanged,
    required this.onPassChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Başlık
          const Text(
            'Tekrar hoş geldiniz',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.anaMetin,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Bildirim tercihlerinize ve kişisel ayarlarınıza ulaşmak için giriş yapın.',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.ikinciMetin,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),

          // E-posta alanı
          _GirisAlani(
            controller: emailCtrl,
            focusNode: emailFocus,
            label: 'E-posta adresi',
            ikon: Icons.email_outlined,
            hata: emailError,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            onChanged: onEmailChanged,
            semanticsLabel: 'E-posta adresi giriş alanı',
            onFieldSubmitted: (_) => passFocus.requestFocus(),
          ),
          const SizedBox(height: 14),

          // Şifre alanı
          _GirisAlani(
            controller: passCtrl,
            focusNode: passFocus,
            label: 'Şifre',
            ikon: Icons.lock_outline_rounded,
            hata: passError,
            obscureText: obscure,
            textInputAction: TextInputAction.done,
            onChanged: onPassChanged,
            semanticsLabel: 'Şifre giriş alanı',
            onFieldSubmitted: (_) => onLogin(),
            suffix: Semantics(
              label: obscure ? 'Şifreyi göster' : 'Şifreyi gizle',
              button: true,
              child: IconButton(
                icon: Icon(
                  obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  size: 20,
                  color: AppColors.ikinciMetin,
                ),
                onPressed: onToggleObscure,
                tooltip: obscure ? 'Şifreyi göster' : 'Şifreyi gizle',
              ),
            ),
          ),

          // Şifremi unuttum
          Align(
            alignment: Alignment.centerRight,
            child: Semantics(
              label: 'Şifremi unuttum bağlantısı',
              button: true,
              child: TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Şifre sıfırlama özelliği yakında aktif olacak.'),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      margin: const EdgeInsets.all(16),
                    ),
                  );
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  minimumSize: const Size(44, 44),
                ),
                child: const Text(
                  'Şifremi unuttum',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.anaMavi,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Giriş Yap butonu
          Semantics(
            label: 'Giriş yap butonu',
            button: true,
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: auth.loading ? null : onLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.anaMavi,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColors.anaMavi.withValues(alpha: 0.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 2,
                  shadowColor: AppColors.anaMavi.withValues(alpha: 0.4),
                ),
                child: auth.loading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                      )
                    : const Text(
                        'Giriş Yap',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Üye olmadan devam et
          Semantics(
            label: 'Üye olmadan devam et butonu',
            button: true,
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton(
                onPressed: onMisafir,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.anaMavi,
                  side: const BorderSide(color: AppColors.anaMavi, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  backgroundColor: AppColors.acikMavi,
                ),
                child: const Text(
                  'Üye Olmadan Devam Et',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Kayıt ol satırı
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Hesabınız yok mu? ',
                style: TextStyle(color: AppColors.ikinciMetin, fontSize: 13),
              ),
              Semantics(
                label: 'Ücretsiz hesap oluştur bağlantısı',
                button: true,
                child: GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/register'),
                  child: const Text(
                    'Ücretsiz hesap oluştur',
                    style: TextStyle(
                      color: AppColors.anaMavi,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Yasal bağlantılar
          const Divider(color: AppColors.cizgi, height: 1),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _YasalLink(metin: 'Kullanım Koşulları'),
              const SizedBox(width: 4),
              const Text('•', style: TextStyle(color: AppColors.cizgi, fontSize: 12)),
              const SizedBox(width: 4),
              _YasalLink(metin: 'KVKK Aydınlatma Metni'),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Giriş alanı bileşeni ─────────────────────────────────────────────────────
class _GirisAlani extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String label;
  final IconData ikon;
  final String? hata;
  final bool obscureText;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final ValueChanged<String> onChanged;
  final ValueChanged<String>? onFieldSubmitted;
  final Widget? suffix;
  final String semanticsLabel;

  const _GirisAlani({
    required this.controller,
    required this.focusNode,
    required this.label,
    required this.ikon,
    required this.hata,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    required this.textInputAction,
    required this.onChanged,
    this.onFieldSubmitted,
    this.suffix,
    required this.semanticsLabel,
  });

  @override
  Widget build(BuildContext context) {
    final hasFocus = focusNode.hasFocus;
    final hasError = hata != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Alan etiketi
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: hasError
                  ? AppColors.acil
                  : hasFocus
                      ? AppColors.anaMavi
                      : AppColors.ikinciMetin,
            ),
          ),
        ),
        Semantics(
          label: semanticsLabel,
          textField: true,
          child: TextFormField(
            controller: controller,
            focusNode: focusNode,
            obscureText: obscureText,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            onChanged: onChanged,
            onFieldSubmitted: onFieldSubmitted,
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.anaMetin,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              prefixIcon: Icon(
                ikon,
                size: 20,
                color: hasError
                    ? AppColors.acil
                    : hasFocus
                        ? AppColors.anaMavi
                        : AppColors.ikinciMetin,
              ),
              suffixIcon: suffix,
              hintText: label,
              hintStyle: const TextStyle(
                color: AppColors.ikinciMetin,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
              filled: true,
              fillColor: AppColors.arkaplan,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.cizgi),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: hasError ? AppColors.acil : AppColors.cizgi,
                  width: hasError ? 1.5 : 1.0,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: hasError ? AppColors.acil : AppColors.anaMavi,
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.acil, width: 1.5),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.acil, width: 2),
              ),
              isDense: false,
              constraints: const BoxConstraints(minHeight: 56),
              // Form hata mesajı gizlendi, aşağıda özel widget gösteriyoruz
              errorStyle: const TextStyle(height: 0, fontSize: 0),
            ),
          ),
        ),
        // Özel hata mesajı
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(left: 4, top: 5),
            child: Row(
              children: [
                const Icon(Icons.error_outline_rounded, size: 13, color: AppColors.acil),
                const SizedBox(width: 4),
                Text(
                  hata!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.acil,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

// ── Yasal bağlantı ───────────────────────────────────────────────────────────
class _YasalLink extends StatelessWidget {
  final String metin;
  const _YasalLink({required this.metin});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: metin,
      button: true,
      child: GestureDetector(
        onTap: () {},
        child: Text(
          metin,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.ikinciMetin,
            decoration: TextDecoration.underline,
            decorationColor: AppColors.cizgi,
          ),
        ),
      ),
    );
  }
}
