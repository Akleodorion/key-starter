import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:key_starter/core/providers/theme_provider.dart';
import 'package:key_starter/core/theme/app_theme.dart';
import 'package:key_starter/injection_container.dart';
import 'package:key_starter/presentation/pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();
  runApp(const ProviderScope(child: KeyStarterApp()));
}

class KeyStarterApp extends ConsumerWidget {
  const KeyStarterApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
