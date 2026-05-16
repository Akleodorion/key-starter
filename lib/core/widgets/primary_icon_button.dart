import 'package:flutter/material.dart';
import 'package:key_starter/core/theme/app_colors.dart';

class PrimaryIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const PrimaryIconButton({super.key, required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.line),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Center(child: Icon(icon, size: 15, color: AppColors.text2)),
      ),
    );
  }
}
