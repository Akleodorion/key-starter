import 'package:flutter/material.dart';
import 'package:key_starter/core/theme/app_color_theme.dart';
import 'package:key_starter/core/theme/app_text_styles.dart';
import 'package:key_starter/core/widgets/display_text.dart';
import 'package:key_starter/core/widgets/label_text.dart';

class RecapStatCell extends StatelessWidget {
  final String value;
  final String unit;
  final String label;
  final Color unitColor;

  const RecapStatCell({
    super.key,
    required this.value,
    required this.unit,
    required this.label,
    required this.unitColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColorTheme.of(context);
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              DisplayText(value, size: 52, weight: FontWeight.w700),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  unit,
                  style: AppTextStyles.display(
                    size: 24,
                    color: unitColor,
                    weight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LabelText(label, color: colors.text3),
        ],
      ),
    );
  }
}
