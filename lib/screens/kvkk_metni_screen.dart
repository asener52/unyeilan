import 'package:flutter/material.dart';
import '../utils/theme.dart';

class KvkkMetniScreen extends StatelessWidget {
  const KvkkMetniScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KVKK Aydınlatma Metni'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _baslik('KİŞİSEL VERİLERİN KORUNMASI KANUNU KAPSAMINDA AYDINLATMA METNİ'),
            const SizedBox(height: 6),
            _paragraf(
              'Ünye Belediye Başkanlığı olarak 6698 sayılı Kişisel Verilerin Korunması Kanunu '
              '("KVKK") uyarınca, Veri Sorumlusu sıfatıyla, kişisel verilerinizin işlenmesine '
              'ilişkin sizi bilgilendirmek amacıyla bu Aydınlatma Metni hazırlanmıştır.',
            ),
            const SizedBox(height: 16),

            _altBaslik('1. VERİ SORUMLUSUNUN KİMLİĞİ'),
            _paragraf(
              'Veri Sorumlusu: Ünye Belediye Başkanlığı\n'
              'Adres: Kaledere Mahallesi Belediye Caddesi No:3 Ünye/Ordu\n'
              'Telefon: 0452 323 19 41\n'
              'E-posta: unye@unye.bel.tr\n'
              'Web Sitesi: www.unye.bel.tr',
            ),

            _altBaslik('2. İŞLENEN KİŞİSEL VERİLER'),
            _paragraf(
              'Ünye İlan uygulaması aracılığıyla aşağıdaki kişisel verileriniz işlenmektedir:\n\n'
              '• Ad ve soyad\n'
              '• E-posta adresi\n'
              '• Telefon numarası (isteğe bağlı)\n'
              '• Mahalle bilgisi (isteğe bağlı)\n'
              '• Cihaz bilgileri ve FCM token (bildirim gönderimi amacıyla)\n'
              '• Uygulama kullanım verileri (görüntüleme kayıtları)',
            ),

            _altBaslik('3. KİŞİSEL VERİLERİN İŞLENME AMAÇLARI'),
            _paragraf(
              'Kişisel verileriniz aşağıdaki amaçlarla işlenmektedir:\n\n'
              '• Ünye Belediyesi\'nin ilan, duyuru, haber ve etkinliklerinin vatandaşlara iletilmesi\n'
              '• Mahalle bazlı bildirim hizmetinin sunulması\n'
              '• Uygulama üyelik ve hesap yönetiminin sağlanması\n'
              '• Hizmet kalitesinin artırılması ve kullanıcı deneyiminin geliştirilmesi\n'
              '• Yasal yükümlülüklerin yerine getirilmesi\n'
              '• İstatistiksel analizlerin gerçekleştirilmesi (kimliğiniz gizlenerek)',
            ),

            _altBaslik('4. KİŞİSEL VERİLERİN AKTARILMASI'),
            _paragraf(
              'Kişisel verileriniz yalnızca aşağıdaki durumlarda üçüncü taraflarla paylaşılabilir:\n\n'
              '• Yasal zorunluluklar çerçevesinde ilgili kamu kurum ve kuruluşları ile\n'
              '• Firebase Cloud Messaging (Google) altyapısı üzerinden bildirim iletimi amacıyla '
              '(yalnızca cihaz token bilgisi)\n\n'
              'Kişisel verileriniz hiçbir koşulda ticari amaçla üçüncü kişilere satılmaz, '
              'kiralanmaz veya pazarlama amacıyla paylaşılmaz.',
            ),

            _altBaslik('5. VERİLERİN SAKLANMA SÜRESİ'),
            _paragraf(
              'Kişisel verileriniz, üyelik süreniz boyunca ve üyeliğinizin sona ermesinden '
              'itibaren ilgili mevzuatta öngörülen süreler boyunca saklanacaktır. '
              'Yasal saklama süresi dolduğunda veriler güvenli biçimde silinecek veya '
              'anonim hale getirilecektir.',
            ),

            _altBaslik('6. VERİ GÜVENLİĞİ'),
            _paragraf(
              'Ünye Belediye Başkanlığı, kişisel verilerinizin güvenliğini sağlamak amacıyla '
              'teknik ve idari tedbirler almaktadır. Şifreler tek yönlü şifreleme (bcrypt) '
              'ile saklanmakta, iletişim HTTPS protokolü üzerinden gerçekleştirilmektedir.',
            ),

            _altBaslik('7. HAKLARINIZ'),
            _paragraf(
              'KVKK\'nın 11. maddesi uyarınca aşağıdaki haklara sahipsiniz:\n\n'
              '• Kişisel verilerinizin işlenip işlenmediğini öğrenme\n'
              '• İşlenmişse buna ilişkin bilgi talep etme\n'
              '• İşlenme amacını ve bunların amacına uygun kullanılıp kullanılmadığını öğrenme\n'
              '• Yurt içinde veya yurt dışında aktarıldığı üçüncü kişileri bilme\n'
              '• Eksik veya yanlış işlenmiş olması hâlinde bunların düzeltilmesini isteme\n'
              '• Kanun\'un 7. maddesinde öngörülen şartlar çerçevesinde silinmesini isteme\n'
              '• İşlenen verilerin münhasıran otomatik sistemler vasıtasıyla analiz edilmesi '
              'suretiyle kişinin kendisi aleyhine bir sonucun ortaya çıkmasına itiraz etme\n'
              '• Kanuna aykırı olarak işlenmesi sebebiyle zarara uğraması hâlinde zararın '
              'giderilmesini talep etme',
            ),

            _altBaslik('8. BAŞVURU YÖNTEMİ'),
            _paragraf(
              'Yukarıda belirtilen haklarınızı kullanmak için;\n\n'
              '• Yazılı başvurunuzu kimliğinizi ispatlayan belgeler ile birlikte '
              '"Kaledere Mahallesi Belediye Caddesi No:3 Ünye/Ordu" adresine bizzat iletebilir,\n'
              '• unye@unye.bel.tr e-posta adresine güvenli elektronik imza veya mobil imzayla '
              'iletebilir,\n'
              '• KEP (Kayıtlı Elektronik Posta) adresi üzerinden gönderebilirsiniz.\n\n'
              'Başvurularınız, niteliğine göre en kısa sürede ve en geç 30 (otuz) gün içinde '
              'ücretsiz olarak sonuçlandırılacaktır.',
            ),

            _altBaslik('9. KVKK KURULU\'NA ŞİKÂYET'),
            _paragraf(
              'Başvurunuzun reddedilmesi, verilen cevabın yetersiz bulunması veya süresinde '
              'yanıt verilmemesi hâlinde; cevabı öğrendiğiniz tarihten itibaren 30 ve her '
              'hâlde başvuru tarihinden itibaren 60 gün içinde Kişisel Verileri Koruma '
              'Kurulu\'na şikâyette bulunabilirsiniz.',
            ),

            const SizedBox(height: 8),
            _paragraf(
              'Son güncelleme: Haziran 2026\n'
              'Ünye Belediye Başkanlığı',
              italic: true,
            ),
            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Okudum, Anladım'),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _baslik(String text) => Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppTheme.primary,
          height: 1.5,
        ),
        textAlign: TextAlign.center,
      );

  Widget _altBaslik(String text) => Padding(
        padding: const EdgeInsets.only(top: 20, bottom: 6),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
      );

  Widget _paragraf(String text, {bool italic = false}) => Text(
        text,
        style: TextStyle(
          fontSize: 13,
          color: AppTheme.textSecondary,
          height: 1.65,
          fontStyle: italic ? FontStyle.italic : FontStyle.normal,
        ),
      );
}
