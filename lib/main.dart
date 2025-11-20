import 'package:bloc/bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_strategy/url_strategy.dart';

import 'app.dart';
import 'firebase_options.dart';
import 'simple_bloc_observer.dart';

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
