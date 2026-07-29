class MeslekGrubu {
  final String baslik;
  final List<String> meslekler;
  const MeslekGrubu(this.baslik, this.meslekler);
}

const List<MeslekGrubu> meslekGruplari = [
  MeslekGrubu('MEMURİYET VE KAMU', [
    'Vali','Vali Yardımcısı','Kaymakam','Kaymakam Adayı','Belediye Başkanı',
    'Belediye Başkan Yardımcısı','Müdür','Şef','Memur','VHKİ','Zabıta Memuru',
    'İtfaiye Eri','Polis Memuru','Bekçi','Cezaevi Personeli','Sosyal Hizmet Uzmanı',
    'Denetmen','Müfettiş','İcra Müdürü','Nüfus Personeli','Tapu Personeli',
  ]),
  MeslekGrubu('EĞİTİM', [
    'Öğretmen','Okul Müdürü','Müdür Yardımcısı','Rehber Öğretmen',
    'Anaokulu Öğretmeni','Sınıf Öğretmeni','Özel Eğitim Öğretmeni',
    'Branş Öğretmeni','Akademisyen','Öğretim Görevlisi','Araştırma Görevlisi',
    'Eğitmen','Usta Öğretici',
  ]),
  MeslekGrubu('SAĞLIK', [
    'Doktor','Uzman Doktor','Diş Hekimi','Eczacı','Hemşire','Ebe',
    'Paramedik','ATT','Sağlık Memuru','Sağlık Teknikeri','Laborant',
    'Psikolog','Psikiyatrist','Diyetisyen','Fizyoterapist',
    'Veteriner Hekim','Veteriner Sağlık Teknikeri',
  ]),
  MeslekGrubu('MÜHENDİSLİK VE TEKNİK', [
    'İnşaat Mühendisi','Harita Mühendisi','Makine Mühendisi','Elektrik Mühendisi',
    'Elektrik Elektronik Mühendisi','Bilgisayar Mühendisi','Yazılım Mühendisi',
    'Endüstri Mühendisi','Çevre Mühendisi','Jeoloji Mühendisi','Gıda Mühendisi',
    'Tekniker','Teknisyen','Harita Teknikeri','CBS Teknikeri',
    'Elektrik Teknikeri','Makine Teknikeri',
  ]),
  MeslekGrubu('BİLİŞİM', [
    'Yazılım Geliştirici','Web Geliştirici','Mobil Uygulama Geliştirici',
    'Sistem Uzmanı','Sistem Yöneticisi','Ağ Uzmanı','Veritabanı Uzmanı',
    'Bilgi İşlem Personeli','Teknik Destek Personeli','Siber Güvenlik Uzmanı','Veri Analisti',
  ]),
  MeslekGrubu('HUKUK', [
    'Avukat','Hakim','Savcı','Noter','Arabulucu','Hukuk Müşaviri',
  ]),
  MeslekGrubu('MİMARLIK VE TASARIM', [
    'Mimar','İç Mimar','Peyzaj Mimarı','Şehir Plancısı',
    'Grafik Tasarımcı','Web Tasarımcı','Moda Tasarımcısı',
  ]),
  MeslekGrubu('MUHASEBE VE FİNANS', [
    'Muhasebeci','Mali Müşavir','Finans Uzmanı','Bankacı','Sigortacı','Tahsilat Personeli',
  ]),
  MeslekGrubu('TİCARET VE OFİS', [
    'İşletmeci','Şirket Sahibi','Esnaf','Girişimci','Sekreter','Ofis Personeli',
    'İnsan Kaynakları Uzmanı','Satış Temsilcisi','Pazarlama Uzmanı',
    'Çağrı Merkezi Personeli','Müşteri Temsilcisi',
  ]),
  MeslekGrubu('ULAŞIM', [
    'Şoför','Taksi Şoförü','Otobüs Şoförü','Servis Şoförü',
    'Kamyon Şoförü','Tır Şoförü','Kaptan','Pilot','Hostes',
  ]),
  MeslekGrubu('İNŞAAT VE ÜRETİM', [
    'Müteahhit','İnşaat Ustası','Kalıpçı','Demirci','Boyacı','Sıvacı',
    'Fayans Ustası','Marangoz','Mobilya Ustası','İşçi','Fabrika İşçisi','Üretim Personeli',
  ]),
  MeslekGrubu('TEKNİK MESLEKLER', [
    'Elektrikçi','Elektronikçi','Kaynakçı','Tesisatçı','Klima Teknisyeni',
    'Bilgisayar Teknisyeni','Oto Elektrikçisi','Oto Tamircisi','Lastikçi',
  ]),
  MeslekGrubu('TARIM VE HAYVANCILIK', [
    'Çiftçi','Besici','Arıcı','Balıkçı','Hayvan Yetiştiricisi','Tarım İşçisi','Ziraat Teknikeri',
  ]),
  MeslekGrubu('ESNAF VE HİZMET', [
    'Bakkal','Kasap','Manav','Fırıncı','Berber','Kuaför','Terzi',
    'Saatçi','Kuyumcu','Nalbur','Mobilyacı','Galerici',
  ]),
  MeslekGrubu('GIDA VE KONAKLAMA', [
    'Aşçı','Pastacı','Garson','Barista','Kasiyer','Market Personeli',
    'Restoran İşletmecisi','Otel Personeli','Resepsiyonist',
  ]),
  MeslekGrubu('MEDYA VE SANAT', [
    'Gazeteci','Muhabir','Yazar','Editör','Fotoğrafçı',
    'Kameraman','Sunucu','Oyuncu','Müzisyen','Ressam',
  ]),
  MeslekGrubu('SPOR', [
    'Antrenör','Hakem','Sporcu','Fitness Eğitmeni',
  ]),
  MeslekGrubu('DİĞER', [
    'Serbest Meslek','Freelancer','Emekli','Ev Hanımı','Öğrenci','İşsiz','Diğer',
  ]),
];

List<String> get tumMeslekler => meslekGruplari.expand((g) => g.meslekler).toList();
