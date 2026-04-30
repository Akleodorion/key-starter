import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:key_starter/core/enums/clef_mode.dart';
import 'package:key_starter/core/theme/app_colors.dart';
import 'package:key_starter/core/theme/app_theme.dart';
import 'package:key_starter/core/widgets/staff_widget.dart';
import 'package:key_starter/injection_container.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await initDependencies();
  runApp(
    const ProviderScope(
      child: KeyStarterApp(),
    ),
  );
}

class KeyStarterApp extends StatelessWidget {
  const KeyStarterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Key Starter',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const _Placeholder(),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ivory,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: StaffWidget(
            diatonicStep: 4,
            clef: ClefMode.treble,
          ),
        ),
      ),
    );
  }
}
