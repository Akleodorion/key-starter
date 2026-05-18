import 'package:flutter/material.dart';
import 'package:key_starter/core/theme/app_color_theme.dart';
import 'package:key_starter/core/widgets/ui_text.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColorTheme.of(context);

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: colors.text,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Center(
        child: UiText('◐', size: 15, weight: FontWeight.w700, color: colors.surface),
      ),
    );
  }
}
