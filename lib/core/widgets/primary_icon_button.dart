import 'package:flutter/material.dart';
import 'package:key_starter/core/theme/app_color_theme.dart';

class PrimaryIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const PrimaryIconButton({super.key, required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = AppColorTheme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: colors.surface,
          border: Border.all(color: colors.line),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Center(child: Icon(icon, size: 15, color: colors.text2)),
      ),
    );
  }
}
