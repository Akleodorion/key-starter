import 'package:flutter/material.dart';
import 'package:key_starter/core/theme/app_colors.dart';

class ArrowButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const ArrowButton({super.key, required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(
          icon,
          size: 24,
          color: enabled ? AppColors.ink : AppColors.line,
        ),
      ),
    );
  }
}
