import 'package:flutter/material.dart';
import 'package:key_starter/core/theme/app_color_theme.dart';
import 'package:key_starter/core/widgets/ui_text.dart';

class SongMeasureLabel extends StatelessWidget {
  final int measureNumber;
  final int measureCount;

  const SongMeasureLabel({
    super.key,
    required this.measureNumber,
    required this.measureCount,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColorTheme.of(context);

    return Center(
      child: UiText(
        'Mesure $measureNumber / $measureCount',
        size: 14,
        color: colors.text2,
      ),
    );
  }
}
