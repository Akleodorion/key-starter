import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:key_starter/core/providers/midi_connection_provider.dart';
import 'package:key_starter/core/theme/app_color_theme.dart';
import 'package:key_starter/core/theme/app_colors.dart';
import 'package:key_starter/core/theme/app_text_styles.dart';

/// Badge indiquant l'état de connexion MIDI.
class MidiPill extends ConsumerWidget {
  const MidiPill({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColorTheme.of(context);
    final deviceName = ref
        .watch(midiConnectionProvider)
        .when(data: (name) => name, loading: () => null, error: (_, _) => null);
    final connected = deviceName != null;
    final dotColor = connected ? AppColors.intervalsFg : colors.text3;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(color: colors.line),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 7),
          Text(
            connected
                ? (deviceName.length > 15
                      ? '${deviceName.substring(0, 15)}…'
                      : deviceName)
                : 'Non connecté',
            style: AppTextStyles.ui(
              size: 11,
              weight: FontWeight.w500,
              color: colors.text2,
            ),
          ),
        ],
      ),
    );
  }
}
