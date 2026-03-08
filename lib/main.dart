import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'app.dart';
import 'config/api_client.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  // Lock portrait orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Setup Dio interceptors
  ApiClient.setupInterceptors();

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
