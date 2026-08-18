import 'dart:async';
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
  final _phone = TextEditingController();
  final _code = TextEditingController();
  String? _token;
  String? _masked;
  String? _error;
  int _remaining = 0;
  Timer? _timer;

  bool get _codeStep => _token != null;

  @override
  void dispose() {
    _timer?.cancel();
    _phone.dispose();
    _code.dispose();
    super.dispose();
  }

  void _countdown() {
    _timer?.cancel();
    setState(() => _remaining = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || _remaining <= 1) { timer.cancel(); if (mounted) setState(() => _remaining = 0); }
      else setState(() => _remaining--);
    });
  }

  Future<void> _requestCode() async {
    final digits = _phone.text.replaceAll(RegExp(r'\D'), '');
    if (!RegExp(r'^(?:90|0)?5\d{9}$').hasMatch(digits)) {
      setState(() => _error = 'Telefon numarasını 05XXXXXXXXX biçiminde girin');
      return;
    }
    setState(() => _error = null);
    final result = await context.read<AuthProvider>().requestLoginCode(_phone.text);
    if (!mounted) return;
    if (result == null) setState(() => _error = context.read<AuthProvider>().error);
    else {
      setState(() { _token = result['token']; _masked = result['telefon_maskeli']; _code.clear(); });
      _countdown();
    }
  }

  Future<void> _verify() async {
    if (!RegExp(r'^\d{6}$').hasMatch(_code.text)) {
      setState(() => _error = '6 haneli doğrulama kodunu girin');
      return;
    }
    setState(() => _error = null);
    final ok = await context.read<AuthProvider>().verifyLoginCode(_token!, _code.text);
    if (!mounted) return;
    if (ok) Navigator.pushReplacementNamed(context, '/home');
    else setState(() => _error = context.read<AuthProvider>().error);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.lacivermavi,
        body: Container(
          decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppColors.lacivermavi, AppColors.anaMavi])),
          child: SafeArea(child: Center(child: SingleChildScrollView(padding: const EdgeInsets.all(24), child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Column(children: [
              ClipRRect(borderRadius: BorderRadius.circular(22), child: Image.asset('assets/images/logo.jpg', width: 82, height: 82, fit: BoxFit.cover)),
              const SizedBox(height: 14),
              const Text('e-Ünye Duyuru', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w800, color: Colors.white)),
              const SizedBox(height: 24),
              Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28), boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 24)]), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(_codeStep ? 'Kodunuzu doğrulayın' : 'Telefonla giriş yapın', style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800, color: AppColors.anaMetin)),
                const SizedBox(height: 8),
                Text(_codeStep ? '$_masked numaralı telefonunuza gönderilen 6 haneli kodu girin.' : 'Şifreye ihtiyacınız yok. Telefonunuza gelen tek kullanımlık kodla güvenle giriş yapın.', style: const TextStyle(color: AppColors.ikinciMetin, height: 1.45)),
                const SizedBox(height: 22),
                if (!_codeStep) TextField(controller: _phone, keyboardType: TextInputType.phone, textInputAction: TextInputAction.done, onSubmitted: (_) => _requestCode(), inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9+ ()-]'))], decoration: _decoration('Telefon numarası', Icons.phone_outlined, '05XX XXX XX XX')),
                if (_codeStep) TextField(controller: _code, autofocus: true, keyboardType: TextInputType.number, textInputAction: TextInputAction.done, maxLength: 6, onSubmitted: (_) => _verify(), inputFormatters: [FilteringTextInputFormatter.digitsOnly], style: const TextStyle(fontSize: 25, letterSpacing: 9, fontWeight: FontWeight.bold), textAlign: TextAlign.center, decoration: _decoration('Doğrulama kodu', Icons.sms_outlined, '------').copyWith(counterText: '')),
                if (_error != null) Padding(padding: const EdgeInsets.only(top: 12), child: Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 13))),
                const SizedBox(height: 18),
                SizedBox(width: double.infinity, height: 54, child: ElevatedButton(onPressed: auth.loading ? null : (_codeStep ? _verify : _requestCode), style: ElevatedButton.styleFrom(backgroundColor: AppColors.anaMavi, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))), child: auth.loading ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : Text(_codeStep ? 'Giriş Yap' : 'SMS Kodu Gönder', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)))),
                if (_codeStep) Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  TextButton(onPressed: () => setState(() { _token = null; _error = null; }), child: const Text('Numarayı değiştir')),
                  TextButton(onPressed: _remaining == 0 && !auth.loading ? _requestCode : null, child: Text(_remaining > 0 ? 'Tekrar gönder ($_remaining)' : 'Kodu tekrar gönder')),
                ]),
                if (!_codeStep) ...[
                  const Divider(height: 28),
                  Center(child: TextButton(onPressed: () => Navigator.pushNamed(context, '/register'), child: const Text('Hesabınız yok mu? Kayıt olun'))),
                ],
              ])),
            ]),
          )))),
        ),
      ),
    );
  }

  InputDecoration _decoration(String label, IconData icon, String hint) => InputDecoration(labelText: label, hintText: hint, prefixIcon: Icon(icon), filled: true, fillColor: const Color(0xfff5f7fb), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.anaMavi, width: 1.5)));
}
