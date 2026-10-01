import 'package:flutter/material.dart';
import 'package:key_starter/core/theme/app_color_theme.dart';
import 'package:key_starter/core/widgets/ui_text.dart';

/// Voile posé sur un exercice réservé au MIDI quand le clavier est débranché.
class MidiDisconnectedOverlay extends StatelessWidget {
  static const message = 'Clavier MIDI déconnecté';
  static const hint = "Rebranchez-le pour reprendre l'exercice, ou quittez.";

  const MidiDisconnectedOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColorTheme.of(context);
    return ColoredBox(
      color: colors.bg.withValues(alpha: 0.92),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.piano_off_rounded, size: 36, color: colors.text2),
            const SizedBox(height: 12),
            UiText(
              message,
              size: 17,
              weight: FontWeight.w700,
              color: colors.text,
            ),
            const SizedBox(height: 4),
            UiText(hint, size: 13, color: colors.text2),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Quitter'),
            ),
          ],
        ),
      ),
    );
  }
}
