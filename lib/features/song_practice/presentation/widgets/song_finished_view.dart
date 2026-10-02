import 'package:flutter/material.dart';
import 'package:key_starter/core/theme/app_color_theme.dart';
import 'package:key_starter/core/theme/app_colors.dart';
import 'package:key_starter/core/widgets/display_text.dart';
import 'package:key_starter/core/widgets/primary_button.dart';
import 'package:key_starter/core/widgets/ui_text.dart';

class SongFinishedView extends StatelessWidget {
  final int errorCount;
  final VoidCallback onRestart;

  const SongFinishedView({
    super.key,
    required this.errorCount,
    required this.onRestart,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColorTheme.of(context);
    final errorLabel = switch (errorCount) {
      0 => 'Aucune erreur',
      1 => '1 erreur',
      _ => '$errorCount erreurs',
    };

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const DisplayText('Morceau terminé'),
            const SizedBox(height: 8),
            UiText(errorLabel, size: 16, color: colors.text2),
            const SizedBox(height: 24),
            PrimaryButton(
              label: 'Recommencer',
              color: AppColors.songsFg,
              onPressed: onRestart,
            ),
          ],
        ),
      ),
    );
  }
}
