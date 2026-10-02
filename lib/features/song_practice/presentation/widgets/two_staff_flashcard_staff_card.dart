import 'package:flutter/material.dart';
import 'package:key_starter/core/theme/app_color_theme.dart';
import 'package:key_starter/features/song_practice/presentation/widgets/two_staff_flashcard_staff_widget.dart';

class TwoStaffFlashcardStaffCard extends StatelessWidget {
  const TwoStaffFlashcardStaffCard({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColorTheme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(color: colors.line),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const TwoStaffFlashcardStaffWidget(),
    );
  }
}
