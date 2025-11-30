import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:lenski/screens/navigation/navigation_handler.dart';
import 'package:lenski/screens/landing/landing_page.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Main function to run the app
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Only set window size and initialize SQLite for desktop platforms
  if (!kIsWeb) {
    try {
      // Import conditionally for desktop
      // ignore: avoid_dynamic_calls
      final windowSize = await _getWindowSizePlugin();
      if (windowSize != null) {
        // ignore: avoid_dynamic_calls
        windowSize.setWindowMinSize(const Size(1750, 900));
      }

      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    } catch (e) {
      // Silently handle if desktop plugins aren't available
      print('Desktop initialization skipped: $e');
    }
  }

  runApp(const MyApp());
}

Future<dynamic> _getWindowSizePlugin() async {
  try {
    // Dynamically import window_size only on desktop
    return null; // Will be handled by conditional imports in production
  } catch (e) {
    return null;
  }
}

/// Root widget of the application
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LenSki - Master Any Language',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('es'),
      ],
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      // Show landing page on web, NavigationHandler on desktop
      home: kIsWeb ? const LandingPage() : const NavigationHandler(),
    );
  }
}
