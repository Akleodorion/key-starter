import 'package:flutter/material.dart';
import 'package:key_starter/core/theme/app_color_theme.dart';
import 'package:key_starter/core/theme/app_text_styles.dart';
import 'package:key_starter/core/widgets/input_source_pill.dart';
import 'package:key_starter/core/widgets/primary_icon_button.dart';

/// Barre du haut de la page de jeu : retour, titre de la grille, source
/// d'entrée.
class ChordChartPlayTopBar extends StatelessWidget {
  final String title;

  const ChordChartPlayTopBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final colors = AppColorTheme.of(context);

    return Row(
      children: [
        PrimaryIconButton(
          icon: Icons.arrow_back_rounded,
          onTap: () => Navigator.of(context).pop(),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.ui(size: 14, color: colors.text2),
          ),
        ),
        const SizedBox(width: 12),
        const InputSourcePill(),
      ],
    );
  }
}
