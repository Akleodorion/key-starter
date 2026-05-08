import 'package:flutter/material.dart';

/// Écran d'erreur affiché quand le notifier est en état [SessionSetupError].
class SessionSetupErrorView extends StatelessWidget {
  const SessionSetupErrorView({super.key, required this.message});

  /// Message d'erreur provenant de [SessionSetupError.message].
  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text(message)));
  }
}
