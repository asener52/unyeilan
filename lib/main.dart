import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'providers/auth_provider.dart';
import 'providers/content_provider.dart';
import 'services/api_service.dart';

import 'services/notification_service.dart';
import 'utils/theme.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/content_detail_screen.dart';

/// Global navigator key — ApiService'in 401/403'te login'e yönlendirmesi için
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  timeago.setLocaleMessages('tr', timeago.TrMessages());

  // navigatorKey'i ApiService'e bağla (401/403 otomatik çıkış için)
  ApiService.setNavigatorKey(navigatorKey);


  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  runApp(const UnyeBuradaApp());
  _initializeServices();
}

Future<void> _initializeServices() async {
  try {
    await initializeDateFormatting('tr_TR', null);
  } catch (e) {
    debugPrint('Türkçe tarih biçimleri yüklenemedi: $e');
  }

  try {
    await Firebase.initializeApp();
    await NotificationService().initialize();
  } catch (e, stackTrace) {
    // Firebase/bildirim sorunu uygulamanın ilk ekranını engellememeli.
    debugPrint('Bildirim servisi kullanılamıyor: $e');
    debugPrintStack(stackTrace: stackTrace);
  }
}

class UnyeBuradaApp extends StatelessWidget {
  const UnyeBuradaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ContentProvider()),
      ],
      child: MaterialApp(
        title: 'e-Ünye Duyuru',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        navigatorKey: navigatorKey,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('tr', 'TR'),
          Locale('en', 'US'),
        ],
        locale: const Locale('tr', 'TR'),
        initialRoute: '/',
        routes: {
          '/': (_) => const SplashScreen(),
          '/login': (_) => const LoginScreen(),
          '/register': (_) => const RegisterScreen(),
          '/home': (_) => const HomeScreen(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == '/content-detail') {
            final id = settings.arguments as int;
            return MaterialPageRoute(
              builder: (_) => ContentDetailScreen(icerikId: id),
            );
          }
          return null;
        },
      ),
    );
  }
}
