import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'app.dart';
import 'config/api_client.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Lock portrait orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Setup Dio interceptors
  ApiClient.setupInterceptors();

  // Global error handlers — route all unhandled errors to Crashlytics
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('en'),
        Locale('tr'),
        Locale('de'),
        Locale('fr'),
        Locale('es'),
        Locale('it'),
        Locale('pt'),
        Locale('ru'),
        Locale('ar'),
        Locale('zh'),
        Locale('ja'),
        Locale('ko'),
        Locale('hi'),
        Locale('az'),
        Locale('pl'),
        Locale('id'),
      ],
      path: 'assets/i18n',
      fallbackLocale: const Locale('en'),
      child: const ProviderScope(
        child: NeuralQApp(),
      ),
    ),
  );
}
