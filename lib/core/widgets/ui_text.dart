import 'package:flutter/material.dart';
import 'package:key_starter/core/theme/app_text_styles.dart';

class UiText extends StatelessWidget {
  final String data;
  final double size;
  final Color? color;
  final FontWeight weight;

  const UiText(
    this.data, {
    super.key,
    this.size = 14,
    this.color,
    this.weight = FontWeight.w400,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      data,
      style: AppTextStyles.ui(size: size, color: color, weight: weight),
    );
  }
}
