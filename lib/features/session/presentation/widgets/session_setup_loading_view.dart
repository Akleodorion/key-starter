import 'package:flutter/material.dart';

/// Écran affiché pendant les états transitoires de la session setup
/// ([SessionSetupInitial], [SessionSetupLoading], [SessionSetupCreated]).
class SessionSetupLoadingView extends StatelessWidget {
  const SessionSetupLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
