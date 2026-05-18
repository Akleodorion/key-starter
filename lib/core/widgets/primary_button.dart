import 'package:flutter/material.dart';
import 'package:key_starter/core/widgets/ui_text.dart';

class PrimaryButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      width: double.infinity,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: UiText(
          label,
          size: 16,
          weight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }
}
