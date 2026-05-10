import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:key_starter/core/theme/app_theme.dart';
import 'package:key_starter/features/session/presentation/pages/session_setup_page.dart';
import 'package:key_starter/injection_container.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();
  runApp(const ProviderScope(child: KeyStarterApp()));
}

class KeyStarterApp extends StatelessWidget {
  const KeyStarterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Key Starter',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const SessionSetupPage(),
    );
  }
}
