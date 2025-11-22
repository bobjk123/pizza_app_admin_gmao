import 'package:bloc/bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_strategy/url_strategy.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app.dart';
import 'firebase_options.dart';
import 'simple_bloc_observer.dart';

// Runtime flag to know if Supabase was initialized. Useful for debugging.
bool kSupabaseInitialized = false;

void main() async {
  setPathUrlStrategy();
  GoRouter.optionURLReflectsImperativeAPIs = true;
  WidgetsFlutterBinding.ensureInitialized();
  try {
    if (kIsWeb) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } else {
      await Firebase.initializeApp();
    }
    // Initialize Supabase. Priority: --dart-define > .env file.
    // Load .env if present so developers can drop a local .env without using
    // --dart-define during development.
    try {
      await dotenv.load();
    } catch (_) {
      // ignore: avoid_print
      print('.env not found or failed to load; continuing');
    }

    final supabaseUrlDefine = const String.fromEnvironment('SUPABASE_URL');
    final supabaseAnonDefine =
        const String.fromEnvironment('SUPABASE_ANON_KEY');

    final supabaseUrlEnv = dotenv.env['SUPABASE_URL'] ?? '';
    final supabaseAnonEnv = dotenv.env['SUPABASE_ANON_KEY'] ?? '';

    final supabaseUrl =
        supabaseUrlDefine.isNotEmpty ? supabaseUrlDefine : supabaseUrlEnv;
    final supabaseAnonKey =
        supabaseAnonDefine.isNotEmpty ? supabaseAnonDefine : supabaseAnonEnv;

    if (supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty) {
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
      );
      kSupabaseInitialized = true;
      // ignore: avoid_print
      print('Supabase initialized (SUPABASE_URL set)');
    } else {
      // ignore: avoid_print
      print(
          'Supabase not initialized (SUPABASE_URL or SUPABASE_ANON_KEY missing)');
    }
  } catch (e, st) {
    // Log and rethrow so developer can see initialization failures
    // during development on web/other platforms.
    // Use dart:developer log in app logs.
    // If Firebase isn't configured for the current platform this will help
    // identify the issue quickly.
    // ignore: avoid_print
    print('Firebase.initializeApp failed: $e\n$st');
    rethrow;
  }
  Bloc.observer = SimpleBlocObserver();
  runApp(const MyApp());
}
