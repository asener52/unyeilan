import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/content_provider.dart';
import '../utils/theme.dart';
import '../utils/meslekler.dart';
import 'kvkk_metni_screen.dart';
import 'acik_riza_metni_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _adCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _telCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _engelOraniCtrl = TextEditingController();

  bool _obscure = true;
  int? _selectedMahalle;
  bool _tumHaberler = true;
  bool _kvkkOnay = false;
  bool _kvkkAcildi = false;
  bool _acikRizaOnay = false;
  bool _acikRizaAcildi = false;

  // Yeni alanlar
  DateTime? _dogumTarihi;
  String? _cinsiyet;
  String? _meslek;
  bool _engelDurumu = false;
  int? _engelOrani;

  // Meslek arama
  final _meslekAraCtrl = TextEditingController();
  String _meslekArama = '';

  @override
  void initState() {
    super.initState();
    _meslekAraCtrl.addListener(() => setState(() => _meslekArama = _meslekAraCtrl.text.toLowerCase()));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ContentProvider>().loadMahalles();
    });
  }

  @override
  void dispose() {
    _adCtrl.dispose(); _emailCtrl.dispose(); _telCtrl.dispose();
    _passCtrl.dispose(); _engelOraniCtrl.dispose(); _meslekAraCtrl.dispose();
    super.dispose();
  }

  Future<void> _secDogumTarihi() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1990),
      firstDate: DateTime(1920),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 5)),
      locale: const Locale('tr', 'TR'),
      builder: (ctx, child) => Theme(
        data: ThemeData.light().copyWith(colorScheme: const ColorScheme.light(primary: AppTheme.primary)),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _dogumTarihi = picked);
  }

  Future<void> _secMeslek() async {
    _meslekAraCtrl.clear();
    setState(() => _meslekArama = '');
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _MeslekSeciciSheet(araCtrl: _meslekAraCtrl),
    );
    if (result != null) setState(() => _meslek = result);
  }

  Future<void> _openKvkk() async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => const KvkkMetniScreen()));
    setState(() => _kvkkAcildi = true);
  }

  Future<void> _openAcikRiza() async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => const AcikRizaMetniScreen()));
    setState(() => _acikRizaAcildi = true);
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_kvkkOnay) {
      _showError(!_kvkkAcildi ? 'KVKK metnini okuyunuz, ardından onaylayınız.' : 'KVKK Aydınlatma Metni\'ni onaylamanız gerekmektedir.');
      return;
    }
    if (!_acikRizaOnay) {
      _showError(!_acikRizaAcildi ? 'Açık Rıza metnini okuyunuz, ardından onaylayınız.' : 'Açık Rıza Metni\'ni onaylamanız gerekmektedir.');
      return;
    }

    final engelOrani = _engelDurumu ? int.tryParse(_engelOraniCtrl.text) : null;

    final ok = await context.read<AuthProvider>().register(
      adSoyad: _adCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _passCtrl.text,
      telefon: _telCtrl.text.trim(),
      mahalleId: _selectedMahalle,
      tumHaberler: _tumHaberler,
      kvkkOnay: _kvkkOnay,
      acikRizaOnay: _acikRizaOnay,
      dogumTarihi: _dogumTarihi != null
          ? '${_dogumTarihi!.year}-${_dogumTarihi!.month.toString().padLeft(2, '0')}-${_dogumTarihi!.day.toString().padLeft(2, '0')}'
          : null,
      cinsiyet: _cinsiyet,
      meslek: _meslek,
      engelDurumu: _engelDurumu,
      engelOrani: engelOrani,
    );
    if (!mounted) return;
    if (ok) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      _showError(context.read<AuthProvider>().error ?? 'Kayıt başarısız');
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red.shade600));
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final mahalles = context.watch<ContentProvider>().mahalles;

    return Scaffold(
      backgroundColor: AppTheme.primary,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text('Kayıt Ol', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFF8FAFF),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Hesap Oluştur', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                        const SizedBox(height: 4),
                        const Text('Bilgilerinizi doldurun', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                        const SizedBox(height: 24),

                        _SectionTitle('Temel Bilgiler'),
                        const SizedBox(height: 12),

                        _buildField(_adCtrl, 'Ad Soyad *', Icons.person_outline,
                            validator: (v) => (v == null || v.trim().length < 2) ? 'Ad soyad giriniz' : null),
                        const SizedBox(height: 10),
                        _buildField(_emailCtrl, 'E-posta *', Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) => (v == null || !v.contains('@')) ? 'Geçerli e-posta girin' : null),
                        const SizedBox(height: 10),
                        _buildField(_telCtrl, 'Telefon *', Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                            validator: (v) => (v == null || v.trim().isEmpty) ? 'Telefon numarası zorunludur' : null),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _passCtrl,
                          obscureText: _obscure,
                          decoration: InputDecoration(
                            labelText: 'Şifre *',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                              onPressed: () => setState(() => _obscure = !_obscure),
                            ),
                            filled: true, fillColor: Colors.white,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primary)),
                          ),
                          validator: (v) => (v == null || v.length < 6) ? 'En az 6 karakter' : null,
                        ),

                        const SizedBox(height: 24),
                        _SectionTitle('Kişisel Bilgiler'),
                        const SizedBox(height: 12),

                        // Doğum tarihi
                        GestureDetector(
                          onTap: _secDogumTarihi,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.cake_outlined, color: Colors.grey.shade600, size: 20),
                                const SizedBox(width: 12),
                                Text(
                                  _dogumTarihi == null
                                      ? 'Doğum Tarihi (isteğe bağlı)'
                                      : '${_dogumTarihi!.day}.${_dogumTarihi!.month}.${_dogumTarihi!.year}',
                                  style: TextStyle(
                                    color: _dogumTarihi == null ? Colors.grey.shade500 : AppTheme.textPrimary,
                                    fontSize: 15,
                                  ),
                                ),
                                const Spacer(),
                                Icon(Icons.arrow_drop_down, color: Colors.grey.shade400),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Cinsiyet
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                                child: Row(
                                  children: [
                                    Icon(Icons.wc_outlined, color: Colors.grey.shade600, size: 20),
                                    const SizedBox(width: 8),
                                    Text('Cinsiyet (isteğe bağlı)', style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
                                  ],
                                ),
                              ),
                              Row(
                                children: ['Kadın', 'Erkek'].map((c) => Expanded(
                                  child: RadioListTile<String>(
                                    title: Text(c, style: const TextStyle(fontSize: 14)),
                                    value: c,
                                    groupValue: _cinsiyet,
                                    onChanged: (v) => setState(() => _cinsiyet = v),
                                    activeColor: AppTheme.primary,
                                    dense: true,
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                                  ),
                                )).toList(),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Meslek seçici
                        GestureDetector(
                          onTap: _secMeslek,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.work_outline, color: Colors.grey.shade600, size: 20),
                                const SizedBox(width: 12),
                                Text(
                                  _meslek ?? 'Meslek seçin (isteğe bağlı)',
                                  style: TextStyle(
                                    color: _meslek == null ? Colors.grey.shade500 : AppTheme.textPrimary,
                                    fontSize: 15,
                                  ),
                                ),
                                const Spacer(),
                                Icon(Icons.arrow_drop_down, color: Colors.grey.shade400),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Engel durumu
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: ['Engel Durumu Yok', 'Engel Durumu Var'].map((e) => Expanded(
                                  child: RadioListTile<bool>(
                                    title: Text(e, style: const TextStyle(fontSize: 13)),
                                    value: e == 'Engel Durumu Var',
                                    groupValue: _engelDurumu,
                                    onChanged: (v) => setState(() { _engelDurumu = v!; if (!v) _engelOraniCtrl.clear(); }),
                                    activeColor: AppTheme.primary,
                                    dense: true,
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                                  ),
                                )).toList(),
                              ),
                              if (_engelDurumu)
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                                  child: TextFormField(
                                    controller: _engelOraniCtrl,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                    decoration: InputDecoration(
                                      labelText: 'Engel Oranı (%) *',
                                      hintText: '1-100 arası',
                                      prefixIcon: const Icon(Icons.accessibility_new, size: 20),
                                      filled: true, fillColor: const Color(0xFFF8FAFF),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade200)),
                                    ),
                                    validator: (v) {
                                      if (!_engelDurumu) return null;
                                      final n = int.tryParse(v ?? '');
                                      if (n == null || n < 1 || n > 100) return '1-100 arası bir değer girin';
                                      return null;
                                    },
                                  ),
                                ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),
                        _SectionTitle('Mahalle & Bildirimler'),
                        const SizedBox(height: 12),

                        DropdownButtonFormField<int>(
                          value: _selectedMahalle,
                          decoration: InputDecoration(
                            hintText: 'Mahalle seçin (isteğe bağlı)',
                            prefixIcon: const Icon(Icons.location_on_outlined),
                            filled: true, fillColor: Colors.white,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
                          ),
                          items: [
                            const DropdownMenuItem(value: null, child: Text('Tüm mahalleler')),
                            ...mahalles.map((m) => DropdownMenuItem(value: m.id, child: Text(m.ad))),
                          ],
                          onChanged: (v) => setState(() => _selectedMahalle = v),
                        ),
                        const SizedBox(height: 10),

                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: SwitchListTile(
                            title: const Text('Tüm haberleri takip et', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                            subtitle: Text(
                              _tumHaberler ? 'Tüm mahallelerin haberlerini alırsınız' : 'Sadece seçtiğiniz mahallenin haberlerini alırsınız',
                              style: const TextStyle(fontSize: 12),
                            ),
                            value: _tumHaberler,
                            activeColor: AppTheme.primary,
                            onChanged: (v) => setState(() => _tumHaberler = v),
                          ),
                        ),

                        const SizedBox(height: 24),
                        _SectionTitle('Sözleşmeler'),
                        const SizedBox(height: 12),

                        _ConsentTile(
                          value: _kvkkOnay,
                          acildi: _kvkkAcildi,
                          onChanged: (v) {
                            if (v && !_kvkkAcildi) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Lütfen önce KVKK metnini okuyunuz'), backgroundColor: Colors.orange),
                              );
                              return;
                            }
                            setState(() => _kvkkOnay = v);
                          },
                          labelText: 'KVKK Aydınlatma Metni\'ni okudum ve onaylıyorum.',
                          linkText: 'Metni Oku',
                          onLinkTap: _openKvkk,
                        ),
                        const SizedBox(height: 10),

                        _ConsentTile(
                          value: _acikRizaOnay,
                          acildi: _acikRizaAcildi,
                          onChanged: (v) {
                            if (v && !_acikRizaAcildi) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Lütfen önce Açık Rıza metnini okuyunuz'), backgroundColor: Colors.orange),
                              );
                              return;
                            }
                            setState(() => _acikRizaOnay = v);
                          },
                          labelText: 'Açık Rıza Metni\'ni okudum ve onaylıyorum.',
                          linkText: 'Metni Oku',
                          onLinkTap: _openAcikRiza,
                        ),

                        const SizedBox(height: 28),

                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: auth.loading ? null : _register,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              elevation: 0,
                            ),
                            child: auth.loading
                                ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : const Text('Kayıt Ol', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(height: 16),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Zaten hesabınız var mı?', style: TextStyle(color: AppTheme.textSecondary)),
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Giriş Yap', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController ctrl, String label, IconData icon, {
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true, fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primary)),
      ),
      validator: validator,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(width: 4, height: 18, decoration: BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.circular(2))),
      const SizedBox(width: 8),
      Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
    ],
  );
}

class _ConsentTile extends StatelessWidget {
  final bool value;
  final bool acildi;
  final ValueChanged<bool> onChanged;
  final String labelText;
  final String linkText;
  final VoidCallback onLinkTap;

  const _ConsentTile({
    required this.value,
    required this.acildi,
    required this.onChanged,
    required this.labelText,
    required this.linkText,
    required this.onLinkTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: value ? AppTheme.primary.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: value ? AppTheme.primary.withOpacity(0.4) : Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
            child: GestureDetector(
              onTap: onLinkTap,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.article_outlined, color: Colors.white, size: 14),
                        const SizedBox(width: 4),
                        Text(linkText, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (acildi)
                    Row(children: [
                      Icon(Icons.check_circle, color: Colors.green.shade600, size: 14),
                      const SizedBox(width: 4),
                      Text('Okundu', style: TextStyle(color: Colors.green.shade600, fontSize: 11, fontWeight: FontWeight.w500)),
                    ]),
                ],
              ),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: value,
                onChanged: acildi ? (v) => onChanged(v ?? false) : null,
                activeColor: AppTheme.primary,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 12, right: 12, bottom: 12),
                  child: Text(
                    labelText,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: acildi ? AppTheme.textPrimary : AppTheme.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Meslek seçici bottom sheet
class _MeslekSeciciSheet extends StatefulWidget {
  final TextEditingController araCtrl;
  const _MeslekSeciciSheet({required this.araCtrl});

  @override
  State<_MeslekSeciciSheet> createState() => _MeslekSeciciSheetState();
}

class _MeslekSeciciSheetState extends State<_MeslekSeciciSheet> {
  String _arama = '';

  @override
  void initState() {
    super.initState();
    widget.araCtrl.addListener(() => setState(() => _arama = widget.araCtrl.text.toLowerCase()));
  }

  @override
  Widget build(BuildContext context) {
    final filtred = _arama.isEmpty
        ? null
        : tumMeslekler.where((m) => m.toLowerCase().contains(_arama)).toList();

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (_, ctrl) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle
            Container(margin: const EdgeInsets.only(top: 10), width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 12),
            const Text('Meslek Seçin', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: widget.araCtrl,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Meslek ara...',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  filled: true, fillColor: const Color(0xFFF4F6F8),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: filtred != null
                  ? filtred.isEmpty
                      ? const Center(child: Text('Sonuç bulunamadı', style: TextStyle(color: Colors.grey)))
                      : ListView.builder(
                          controller: ctrl,
                          itemCount: filtred.length,
                          itemBuilder: (_, i) => _MeslekItem(meslek: filtred[i]),
                        )
                  : ListView.builder(
                      controller: ctrl,
                      itemCount: meslekGruplari.length,
                      itemBuilder: (_, gi) {
                        final grup = meslekGruplari[gi];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: double.infinity,
                              color: const Color(0xFFF0F4FF),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: Text(grup.baslik, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primary, letterSpacing: 0.5)),
                            ),
                            ...grup.meslekler.map((m) => _MeslekItem(meslek: m)),
                          ],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MeslekItem extends StatelessWidget {
  final String meslek;
  const _MeslekItem({required this.meslek});

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: () => Navigator.pop(context, meslek),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
      child: Text(meslek, style: const TextStyle(fontSize: 14, color: AppTheme.textPrimary)),
    ),
  );
}
