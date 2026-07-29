import 'package:flutter/material.dart';

class AppColors {
  // Ana renkler
  static const Color lacivermavi = Color(0xFF073B78);
  static const Color anaMavi = Color(0xFF075EAF);
  static const Color acikMavi = Color(0xFFEAF4FF);
  static const Color turkuaz = Color(0xFF10A7A0);

  // Nötr renkler
  static const Color beyaz = Color(0xFFFFFFFF);
  static const Color arkaplan = Color(0xFFF5F8FC);
  static const Color anaMetin = Color(0xFF15233B);
  static const Color ikinciMetin = Color(0xFF66758A);
  static const Color cizgi = Color(0xFFE2EAF4);

  // Durum renkleri
  static const Color basarili = Color(0xFF28A745);
  static const Color uyari = Color(0xFFF59E0B);
  static const Color acil = Color(0xFFE5484D);
  static const Color etkinlik = Color(0xFF6957E8);

  // Kategori renkleri
  static const Color altyapi = Color(0xFF075EAF);
  static const Color ulasim = Color(0xFFF59E0B);
  static const Color cevre = Color(0xFF28A745);
  static const Color kultur = Color(0xFF6957E8);
  static const Color spor = Color(0xFF10A7A0);
  static const Color saglik = Color(0xFFE5484D);
  static const Color egitim = Color(0xFFFF6B35);
  static const Color ihale = Color(0xFF8B5CF6);
}

class AppTheme {
  // Backwards compat
  static const Color primary = AppColors.anaMavi;
  static const Color primaryDark = AppColors.lacivermavi;
  static const Color accent = AppColors.turkuaz;
  static const Color surface = AppColors.arkaplan;
  static const Color cardBg = AppColors.beyaz;
  static const Color textPrimary = AppColors.anaMetin;
  static const Color textSecondary = AppColors.ikinciMetin;
  static const Color divider = AppColors.cizgi;

  static final ThemeData light = ThemeData(
    useMaterial3: true,
    fontFamily: 'Inter',
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.anaMavi,
      brightness: Brightness.light,
      primary: AppColors.anaMavi,
      secondary: AppColors.turkuaz,
      surface: AppColors.beyaz,
    ),
    scaffoldBackgroundColor: AppColors.arkaplan,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.lacivermavi,
      foregroundColor: AppColors.beyaz,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: AppColors.beyaz,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.beyaz,
      elevation: 0,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.anaMavi,
        foregroundColor: AppColors.beyaz,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        elevation: 0,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.cizgi),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.cizgi),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.anaMavi, width: 2),
      ),
      filled: true,
      fillColor: AppColors.beyaz,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: const TextStyle(color: AppColors.ikinciMetin, fontSize: 14),
    ),
    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.beyaz,
      selectedItemColor: AppColors.anaMavi,
      unselectedItemColor: AppColors.ikinciMetin,
      elevation: 0,
      type: BottomNavigationBarType.fixed,
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.anaMetin, letterSpacing: -0.5),
      headlineMedium: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.anaMetin, letterSpacing: -0.3),
      headlineSmall: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.anaMetin),
      titleLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.anaMetin),
      titleMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.anaMetin),
      titleSmall: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.anaMetin),
      bodyLarge: TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: AppColors.anaMetin, height: 1.6),
      bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.anaMetin, height: 1.5),
      bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.ikinciMetin),
      labelLarge: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.ikinciMetin, letterSpacing: 0.5),
      labelSmall: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: AppColors.ikinciMetin),
    ),
  );

  // Kategori renk eşlemesi
  static Color kategoriRenk(String? slug) {
    switch (slug) {
      case 'haber': return AppColors.anaMavi;
      case 'duyuru': return AppColors.turkuaz;
      case 'ilan': return AppColors.uyari;
      case 'cenaze': return const Color(0xFF6B7280);
      case 'imar': return AppColors.ihale;
      case 'etkinlik': return AppColors.etkinlik;
      case 'altyapi': return AppColors.altyapi;
      case 'ulasim': return AppColors.ulasim;
      case 'cevre': return AppColors.cevre;
      case 'kultur': return AppColors.kultur;
      case 'spor': return AppColors.spor;
      case 'saglik': return AppColors.saglik;
      case 'egitim': return AppColors.egitim;
      case 'ihale': return AppColors.ihale;
      case 'acil': return AppColors.acil;
      default: return AppColors.anaMavi;
    }
  }

  static IconData kategoriIkon(String? slug) {
    switch (slug) {
      case 'haber': return Icons.newspaper_outlined;
      case 'duyuru': return Icons.campaign_outlined;
      case 'ilan': return Icons.assignment_outlined;
      case 'cenaze': return Icons.church_outlined;
      case 'imar': return Icons.map_outlined;
      case 'etkinlik': return Icons.event_outlined;
      case 'altyapi': return Icons.construction_outlined;
      case 'ulasim': return Icons.directions_bus_outlined;
      case 'cevre': return Icons.eco_outlined;
      case 'kultur': return Icons.museum_outlined;
      case 'spor': return Icons.sports_outlined;
      case 'saglik': return Icons.local_hospital_outlined;
      case 'egitim': return Icons.school_outlined;
      case 'ihale': return Icons.gavel_outlined;
      case 'acil': return Icons.warning_amber_outlined;
      default: return Icons.article_outlined;
    }
  }

  static String kategoriEmoji(String? slug) {
    switch (slug) {
      case 'haber': return '📰';
      case 'duyuru': return '📢';
      case 'ilan': return '📋';
      case 'cenaze': return '🕊️';
      case 'imar': return '🗺️';
      case 'etkinlik': return '🎭';
      case 'altyapi': return '🏗️';
      case 'ulasim': return '🚌';
      case 'cevre': return '🌿';
      case 'kultur': return '🎨';
      case 'spor': return '⚽';
      case 'saglik': return '🏥';
      case 'egitim': return '🎓';
      case 'ihale': return '⚖️';
      case 'acil': return '🚨';
      default: return '📄';
    }
  }

  static String kategoriLabel(String? slug) {
    switch (slug) {
      case 'haber': return 'Haber';
      case 'duyuru': return 'Duyuru';
      case 'ilan': return 'İlan';
      case 'cenaze': return 'Cenaze';
      case 'imar': return 'İmar';
      case 'etkinlik': return 'Etkinlik';
      case 'altyapi': return 'Altyapı';
      case 'ulasim': return 'Ulaşım';
      case 'cevre': return 'Çevre';
      case 'kultur': return 'Kültür';
      case 'spor': return 'Spor';
      case 'saglik': return 'Sağlık';
      case 'egitim': return 'Eğitim';
      case 'ihale': return 'İhale';
      case 'acil': return 'Acil';
      default: return 'Diğer';
    }
  }
}
