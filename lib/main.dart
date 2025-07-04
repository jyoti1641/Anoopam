import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:anoopam_mission/Views/Login/splash_screen.dart';
import 'package:anoopam_mission/providers/theme_provider.dart';
import 'package:anoopam_mission/Views/Video/providers/favorites_provider.dart';
import 'package:anoopam_mission/Views/Video/providers/watch_history_provider.dart';
import 'package:just_audio_background/just_audio_background.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  // ✅ Load .env file
  try {
    await dotenv.load(fileName: ".env");
    debugPrint("✅ .env loaded successfully");
    debugPrint(
        "🔑 YOUTUBE_API_KEY: ${dotenv.env['YOUTUBE_API_KEY']?.substring(0, 10)}...");
    debugPrint("📺 YOUTUBE_CHANNEL_ID: ${dotenv.env['YOUTUBE_CHANNEL_ID']}");
  } catch (e) {
    debugPrint("❌ .env loading failed: $e");
  }

  try {
    await JustAudioBackground.init(
      androidNotificationChannelId: 'com.anoopam_mission.audio',
      androidNotificationChannelName: 'Audio Playback',
      androidNotificationOngoing: true,
      androidShowNotificationBadge: true,
      androidStopForegroundOnPause: true,
      notificationColor: Colors.blue,
    );
  } catch (e) {
    // If AudioService initialization fails, continue without it
    debugPrint('AudioService initialization failed: $e');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
        ChangeNotifierProvider(create: (_) => WatchHistoryProvider()),
      ],
      child: EasyLocalization(
        supportedLocales: const [
          Locale('en'),
          Locale('hi'),
          Locale('gu'),
        ],
        path: 'assets/translations',
        fallbackLocale: const Locale('en'),
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return MaterialApp(
          title: 'Anoopam Mission',
          themeMode: themeProvider.currentTheme,
          theme: ThemeData(
            brightness: Brightness.light,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.deepPurple,
              brightness: Brightness.light,
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              iconTheme: IconThemeData(color: Colors.black),
              titleTextStyle: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.w600),
            ),
            textTheme: const TextTheme(
              bodyLarge: TextStyle(color: Colors.black),
              bodyMedium: TextStyle(color: Colors.black87),
              bodySmall: TextStyle(color: Colors.black54),
              titleLarge:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.deepPurple,
              brightness: Brightness.dark,
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF181818),
              foregroundColor: Colors.white,
              iconTheme: IconThemeData(color: Colors.white),
              titleTextStyle: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600),
            ),
            textTheme: const TextTheme(
              bodyLarge: TextStyle(color: Colors.white),
              bodyMedium: TextStyle(color: Colors.white70),
              bodySmall: TextStyle(color: Colors.white60),
              titleLarge:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            useMaterial3: true,
          ),
          debugShowCheckedModeBanner: false,
          home: const SplashScreen(),
          // Localization settings
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
        );
      },
    );
  }
}

// Responsive wrapper widget
class ResponsiveWrapper extends StatelessWidget {
  final Widget child;

  const ResponsiveWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Determine screen size
        final screenWidth = constraints.maxWidth;

        // Apply responsive constraints
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: _getTextScaler(screenWidth),
          ),
          child: child,
        );
      },
    );
  }

  TextScaler _getTextScaler(double screenWidth) {
    if (screenWidth < 600) return const TextScaler.linear(1.0); // Mobile
    if (screenWidth < 1200) return const TextScaler.linear(1.1); // Tablet
    return const TextScaler.linear(1.2); // Desktop
  }
}
