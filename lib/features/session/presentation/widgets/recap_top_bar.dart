import 'package:flutter/material.dart';
import 'package:key_starter/core/theme/app_color_theme.dart';
import 'package:key_starter/core/theme/app_colors.dart';
import 'package:key_starter/core/widgets/primary_icon_button.dart';
import 'package:key_starter/core/widgets/ui_text.dart';

class RecapTopBar extends StatelessWidget {
  final String exerciseLabel;

  const RecapTopBar({super.key, required this.exerciseLabel});

  @override
  Widget build(BuildContext context) {
    final colors = AppColorTheme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.notesTint,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const UiText(
            'TERMINÉ',
            size: 12,
            weight: FontWeight.w700,
            color: AppColors.notesFg,
          ),
        ),
        UiText(exerciseLabel, size: 14, color: colors.text2),
        PrimaryIconButton(
          icon: Icons.close_rounded,
          onTap: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
