import 'package:flutter/material.dart';
import 'package:key_starter/core/theme/app_text_styles.dart';

class DisplayText extends StatelessWidget {
  final String data;
  final double size;
  final Color? color;
  final FontWeight weight;

  const DisplayText(
    this.data, {
    super.key,
    this.size = 44,
    this.color,
    this.weight = FontWeight.w600,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      data,
      style: AppTextStyles.display(size: size, color: color, weight: weight),
    );
  }
}
