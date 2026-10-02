import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:key_starter/core/theme/app_color_theme.dart';
import 'package:key_starter/core/widgets/ui_text.dart';
import 'package:key_starter/features/song_practice/presentation/providers/hand_selection.dart';
import 'package:key_starter/features/song_practice/presentation/providers/hand_selection_notifier.dart';
import 'package:key_starter/presentation/widgets/segmented_picker.dart';

/// Choix de la ou des mains travaillées, sous son libellé : les trois
/// options ne tiennent pas à côté d'un libellé sur un téléphone.
class SongHandSelectionRow extends ConsumerWidget {
  const SongHandSelectionRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColorTheme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          UiText(
            'Mains',
            size: 15,
            weight: FontWeight.w600,
            color: colors.text,
          ),
          const SizedBox(height: 2),
          UiText(
            "l'autre main reste affichée en gris",
            size: 12,
            color: colors.text2,
          ),
          const SizedBox(height: 12),
          SegmentedPicker<HandSelection>(
            options: const [
              (HandSelection.rightOnly, 'Main droite'),
              (HandSelection.both, 'Deux mains'),
              (HandSelection.leftOnly, 'Main gauche'),
            ],
            selected: ref.watch(handSelectionProvider),
            onChanged: (hands) =>
                ref.read(handSelectionProvider.notifier).select(hands),
            segmentWidth: 92,
          ),
        ],
      ),
    );
  }
}
