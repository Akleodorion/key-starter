import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:key_starter/core/datasources/app_settings_local_datasource.dart';
import 'package:key_starter/core/input/input_source_provider.dart';
import 'package:key_starter/core/providers/app_settings_datasource_provider.dart';
import 'package:key_starter/core/providers/theme_provider.dart';
import 'package:key_starter/core/theme/app_theme.dart';
import 'package:key_starter/injection_container.dart';
import 'package:key_starter/presentation/pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();
  runApp(
    ProviderScope(
      overrides: [
        // Sans ce remplacement, les réglages ne seraient gardés qu'en mémoire.
        appSettingsLocalDataSourceProvider.overrideWithValue(
          sl<AppSettingsLocalDataSource>(),
        ),
      ],
      child: const KeyStarterApp(),
    ),
  );
}

class KeyStarterApp extends ConsumerStatefulWidget {
  const KeyStarterApp({super.key});

  @override
  ConsumerState<KeyStarterApp> createState() => _KeyStarterAppState();
}

class _KeyStarterAppState extends ConsumerState<KeyStarterApp> {
  @override
  void initState() {
    super.initState();
    // Le micro sert de repli sans clavier MIDI : on le demande dès le premier
    // lancement, une seule fois.
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => ref
          .read(microphonePermissionProvider.notifier)
          .requestOnFirstLaunch(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Key Starter',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ref.watch(themeProvider),
      home: const HomePage(),
    );
  }
}
