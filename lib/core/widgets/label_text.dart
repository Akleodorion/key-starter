import 'package:flutter/material.dart';
import 'package:key_starter/core/theme/app_text_styles.dart';

class LabelText extends StatelessWidget {
  final String data;
  final double size;
  final Color? color;
  final FontWeight weight;
  final double letterSpacing;

  const LabelText(
    this.data, {
    super.key,
    this.size = 11,
    this.color,
    this.weight = FontWeight.w600,
    this.letterSpacing = 2.0,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      data,
      style: AppTextStyles.label(
        size: size,
        color: color,
        weight: weight,
        letterSpacing: letterSpacing,
      ),
    );
  }
}
