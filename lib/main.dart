import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'app/app.dart';
import 'core/di/injection_container.dart';
import 'shared/services/notification_service.dart';

// Values injected at build time via --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
const _supabaseUrl = String.fromEnvironment('SUPABASE_URL');
const _supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (_supabaseUrl.isEmpty) {
    throw StateError(
      'SUPABASE_URL not set. Build with --dart-define=SUPABASE_URL=https://your-project.supabase.co',
    );
  }
  if (_supabaseAnonKey.isEmpty) {
    throw StateError(
      'SUPABASE_ANON_KEY not set. Build with --dart-define=SUPABASE_ANON_KEY=your-key',
    );
  }

  // System UI
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // French locale for date formatting
  await initializeDateFormatting('fr');

  await Supabase.initialize(
    url: _supabaseUrl,
    publishableKey: _supabaseAnonKey,
    realtimeClientOptions: const RealtimeClientOptions(
      logLevel: RealtimeLogLevel.info,
    ),
  );

  // Firebase (optional — skip if not configured yet)
  try {
    await Firebase.initializeApp();
    await NotificationService().initialize();
  } catch (_) {
    // Firebase not configured yet — run without FCM
  }

  // Dependency Injection
  await initDependencies();

  runApp(
    const ProviderScope(
      child: WagafApp(),
    ),
  );
}
