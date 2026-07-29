import 'package:flutter/material.dart';
import '../utils/theme.dart';

class AcikRizaMetniScreen extends StatelessWidget {
  const AcikRizaMetniScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Açık Rıza Metni'),
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
            _baslik('KİŞİSEL VERİLERİN İŞLENMESİNE İLİŞKİN AÇIK RIZA METNİ'),
            const SizedBox(height: 6),
            _paragraf(
              'Ünye Belediye Başkanlığı tarafından yürütülen "Ünye İlan" mobil uygulaması '
              'kapsamında, 6698 sayılı Kişisel Verilerin Korunması Kanunu ("KVKK") uyarınca '
              'aşağıda belirtilen kişisel verilerimin işlenmesine ilişkin bilgilendirildim.',
            ),
            const SizedBox(height: 16),

            _altBaslik('1. VERİ SORUMLUSU'),
            _paragraf('Ünye Belediye Başkanlığı (Kaledere Mahallesi Belediye Caddesi No:3 Ünye/Ordu)'),

            _altBaslik('2. İŞLENECEK KİŞİSEL VERİLER'),
            _paragraf(
              'Aşağıdaki kişisel verilerim işlenecektir:\n\n'
              '• Ad ve soyad\n'
              '• E-posta adresi\n'
              '• Telefon numarası (isteğe bağlı)\n'
              '• Mahalle bilgisi (isteğe bağlı)\n'
              '• Cihaz kimlik bilgileri ve FCM token\n'
              '• Uygulama içi davranış verileri (görüntüleme geçmişi)',
            ),

            _altBaslik('3. İŞLEME AMAÇLARI'),
            _paragraf(
              'Kişisel verilerim aşağıdaki amaçlarla işlenecektir:\n\n'
              '• Belediye ilan, duyuru, haber ve etkinliklerinin tarafıma iletilmesi\n'
              '• Mahalle bazlı kişiselleştirilmiş bildirim hizmeti sunulması\n'
              '• Mobil uygulama üyelik ve hesap yönetiminin sağlanması\n'
              '• Hizmet kalitesinin artırılması ve kullanıcı deneyiminin iyileştirilmesi\n'
              '• Anonim istatistiksel analizlerin gerçekleştirilmesi',
            ),

            _altBaslik('4. VERİLERİN AKTARIMI'),
            _paragraf(
              'Kişisel verilerim yalnızca;\n\n'
              '• Yasal zorunluluklar çerçevesinde ilgili kamu kurum ve kuruluşlarına,\n'
              '• Firebase Cloud Messaging (Google) altyapısı aracılığıyla yalnızca bildirim '
              'iletimi amacıyla ve yalnızca cihaz token bilgisi kapsamında\n\n'
              'aktarılabilecektir. Verilerim hiçbir koşulda ticari amaçla üçüncü kişilere '
              'satılmayacak, kiralanmayacak veya pazarlama amacıyla paylaşılmayacaktır.',
            ),

            _altBaslik('5. SAKLAMA SÜRESİ'),
            _paragraf(
              'Kişisel verilerim üyelik sürem boyunca ve üyeliğimin sona ermesinden itibaren '
              'ilgili mevzuatta öngörülen yasal süreler boyunca saklanacak; bu sürelerin '
              'dolması halinde güvenli biçimde silinecek veya anonim hale getirilecektir.',
            ),

            _altBaslik('6. HAKLARIM'),
            _paragraf(
              'KVKK\'nın 11. maddesi kapsamında;\n\n'
              '• Verilerimin işlenip işlenmediğini öğrenme,\n'
              '• İşlenmişse bu konuda bilgi talep etme,\n'
              '• İşlenme amacını öğrenme ve amacına uygun kullanılıp kullanılmadığını sorgulama,\n'
              '• Yurt içi/yurt dışında aktarıldığı üçüncü kişileri bilme,\n'
              '• Eksik veya yanlış işlenmiş verilerin düzeltilmesini isteme,\n'
              '• Kanun\'un 7. maddesi çerçevesinde silinmesini talep etme,\n'
              '• Otomatik sistemlerle analiz sonucu aleyhime oluşan kararlara itiraz etme,\n'
              '• Kanuna aykırı işleme nedeniyle uğradığım zararın giderilmesini talep etme\n\n'
              'haklarına sahibim. Bu haklarımı unye@unye.bel.tr adresine veya yazılı başvuru '
              'yoluyla kullanabilirim.',
            ),

            _altBaslik('7. ONAY BEYANI'),
            _paragraf(
              'Yukarıda açıklanan kapsamda kişisel verilerimin işlenmesine, aktarılmasına ve '
              'saklanmasına; KVKK\'nın 3. maddesi uyarınca özgür iradem ile, açık ve bilinçli '
              'bir şekilde ONAY VERİYORUM.\n\n'
              'Bu onayımı dilediğim zaman geri alabileceğimi ve geri alımın ileriye dönük '
              'sonuç doğuracağını biliyorum.',
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
