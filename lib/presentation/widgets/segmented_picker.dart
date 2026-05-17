import 'package:flutter/material.dart';
import 'package:key_starter/core/theme/app_colors.dart';
import 'package:key_starter/core/theme/app_text_styles.dart';

class SegmentedPicker<T> extends StatelessWidget {
  final List<(T, String)> options;
  final T selected;
  final ValueChanged<T> onChanged;

  const SegmentedPicker({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  static const double _segmentWidth = 56.0;
  static const double _padding = 3.0;

  @override
  Widget build(BuildContext context) {
    final selectedIndex = options.indexWhere((opt) => opt.$1 == selected);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgInset,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Stack(
        children: [
          AnimatedPositioned(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            left: _padding + selectedIndex * _segmentWidth,
            top: _padding,
            bottom: _padding,
            width: _segmentWidth,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(7),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(_padding),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: options.map((option) {
                final (value, label) = option;
                final isSelected = value == selected;
                return GestureDetector(
                  onTap: () => onChanged(value),
                  behavior: HitTestBehavior.opaque,
                  child: SizedBox(
                    width: _segmentWidth,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Center(
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 150),
                          style: AppTextStyles.ui(
                            size: 13,
                            weight: isSelected ? FontWeight.w600 : FontWeight.w400,
                            color: isSelected ? AppColors.text : AppColors.text2,
                          ),
                          child: Text(label),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
