import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'app/app.dart';
import 'core/config/supabase_config.dart';
import 'core/di/injection_container.dart';
import 'shared/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Object? initError;
  try {
    await _initializeApp();
  } catch (e, stack) {
    debugPrint('[Wagaf] ⛔ Initialization error: $e');
    debugPrint('[Wagaf] $stack');
    initError = e;
  }

  if (initError != null) {
    runApp(_ErrorApp(error: initError));
    return;
  }

  runApp(const ProviderScope(child: WagafApp()));
}

Future<void> _initializeApp() async {
  // ── System UI ─────────────────────────────────────────────────────────────
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // ── Locale ────────────────────────────────────────────────────────────────
  await initializeDateFormatting('fr');

  // ── Supabase ──────────────────────────────────────────────────────────────
  await Supabase.initialize(
    url: SupabaseConfig.url,
    publishableKey: SupabaseConfig.anonKey,
    realtimeClientOptions: const RealtimeClientOptions(
      logLevel: RealtimeLogLevel.info,
    ),
  );

  // ── Firebase (optional) ───────────────────────────────────────────────────
  try {
    await Firebase.initializeApp();
    await NotificationService().initialize();
  } catch (e) {
    debugPrint('[Wagaf] Firebase skipped: $e');
  }

  // ── Dependency Injection ──────────────────────────────────────────────────
  await initDependencies();
}

/// Shown when [_initializeApp] throws before [runApp] is reached.
/// Displays the real error so TestFlight testers and developers can act on it.
class _ErrorApp extends StatelessWidget {
  final Object error;
  const _ErrorApp({required this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFF0F172A),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  color: Color(0xFFFF6B6B),
                  size: 72,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Erreur de démarrage',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.none,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                const Text(
                  "L'application n'a pas pu s'initialiser.",
                  style: TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 14,
                    decoration: TextDecoration.none,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF334155)),
                  ),
                  child: SelectableText(
                    error.toString(),
                    style: const TextStyle(
                      color: Color(0xFFF87171),
                      fontSize: 12,
                      fontFamily: 'monospace',
                      height: 1.6,
                      decoration: TextDecoration.none,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
