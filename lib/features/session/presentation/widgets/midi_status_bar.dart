import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:key_starter/core/providers/midi_connection_provider.dart';
import 'package:key_starter/core/theme/app_colors.dart';
import 'package:key_starter/core/theme/app_text_styles.dart';

/// Indicateur de connexion MIDI : point coloré + libellé.
///
/// S'abonne directement à [midiConnectedProvider] — aucun paramètre requis.
class MidiStatusBar extends ConsumerWidget {
  const MidiStatusBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connected = ref.watch(midiConnectedProvider).asData?.value ?? false;

    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: connected ? AppColors.ok : AppColors.inkMute,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          connected ? 'Clavier connecté' : 'Aucun clavier connecté',
          style: AppTextStyles.ui(
            size: 13,
            color: connected ? AppColors.ok : AppColors.inkMute,
          ),
        ),
      ],
    );
  }
}
