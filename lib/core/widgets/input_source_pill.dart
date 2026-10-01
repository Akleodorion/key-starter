import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:key_starter/core/input/input_source_kind.dart';
import 'package:key_starter/core/input/input_source_provider.dart';
import 'package:key_starter/core/providers/midi_connection_provider.dart';
import 'package:key_starter/core/theme/app_color_theme.dart';
import 'package:key_starter/core/theme/app_colors.dart';
import 'package:key_starter/core/widgets/ui_text.dart';

/// Badge indiquant la Source d'entrée active : le clavier MIDI connecté, le
/// micro, ou aucune entrée.
class InputSourcePill extends ConsumerWidget {
  static const _maxDeviceNameLength = 15;

  const InputSourcePill({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColorTheme.of(context);
    final kind = ref.watch(activeInputSourceKindProvider);
    final deviceName = ref.watch(midiConnectionProvider).value;
    final label = switch (kind) {
      InputSourceKind.midi => 'MIDI · ${_shortened(deviceName ?? '')}',
      InputSourceKind.microphone => 'Micro',
      InputSourceKind.none => 'Aucune entrée',
    };
    final dotColor = kind == InputSourceKind.none
        ? colors.text3
        : AppColors.intervalsFg;

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
          UiText(
            label,
            size: 11,
            weight: FontWeight.w500,
            color: colors.text2,
          ),
        ],
      ),
    );
  }

  String _shortened(String deviceName) =>
      deviceName.length > _maxDeviceNameLength
      ? '${deviceName.substring(0, _maxDeviceNameLength)}…'
      : deviceName;
}
