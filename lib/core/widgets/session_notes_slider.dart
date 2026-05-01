import 'package:flutter/material.dart';
import 'package:key_starter/core/theme/app_colors.dart';
import 'package:key_starter/core/theme/app_text_styles.dart';

class SessionNotesSlider extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;

  const SessionNotesSlider({
    super.key,
    required this.value,
    required this.onChanged,
  });

  static const _min = 5;
  static const _max = 100;
  static const _divisions = (_max - _min) ~/ 5; // pas de 5

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('NOTES', style: AppTextStyles.eyebrow()),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: Slider(
                value: value.toDouble(),
                min: _min.toDouble(),
                max: _max.toDouble(),
                divisions: _divisions,
                onChanged: (v) => onChanged(v.round()),
              ),
            ),
            SizedBox(
              width: 44,
              child: Text(
                '$value',
                style: AppTextStyles.ui(size: 18, weight: FontWeight.w600)
                    .copyWith(color: AppColors.accent),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$_min', style: AppTextStyles.mono(size: 11)),
              Text('$_max', style: AppTextStyles.mono(size: 11)),
            ],
          ),
        ),
      ],
    );
  }
}
