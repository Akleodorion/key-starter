import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:key_starter/core/input/input_source_provider.dart';
import 'package:key_starter/core/theme/app_color_theme.dart';
import 'package:key_starter/core/widgets/ui_text.dart';

/// Contenu du bandeau affiché dans un exercice quand rien ne peut être
/// entendu : ni clavier MIDI, ni micro autorisé.
class NoInputSourceBanner extends ConsumerWidget {
  static const message =
      'Branchez un clavier MIDI ou autorisez le micro dans les réglages.';

  const NoInputSourceBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColorTheme.of(context);
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 4, 12, 4),
        child: Row(
          children: [
            Icon(Icons.mic_off_rounded, size: 18, color: colors.text2),
            const SizedBox(width: 10),
            Expanded(child: UiText(message, size: 13, color: colors.text2)),
            TextButton(
              onPressed: () => ref
                  .read(microphonePermissionProvider.notifier)
                  .openSettings(),
              child: const Text('Réglages'),
            ),
          ],
        ),
      ),
    );
  }
}
