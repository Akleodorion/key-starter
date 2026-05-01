import 'package:flutter/material.dart';
import 'package:key_starter/core/enums/clef_mode.dart';
import 'package:key_starter/core/theme/app_colors.dart';
import 'package:key_starter/core/theme/app_text_styles.dart';

class ClefSegmentedControl extends StatelessWidget {
  final ClefMode value;
  final ValueChanged<ClefMode> onChanged;

  const ClefSegmentedControl({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.lineStrong),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          _ClefOption(
            glyph: '𝄞',
            label: 'Sol',
            active: value == ClefMode.treble,
            onTap: () => onChanged(ClefMode.treble),
          ),
          Container(width: 1, color: AppColors.lineStrong),
          _ClefOption(
            glyph: '𝄢',
            label: 'Fa',
            active: value == ClefMode.bass,
            onTap: () => onChanged(ClefMode.bass),
          ),
        ],
      ),
    );
  }
}

class _ClefOption extends StatelessWidget {
  final String glyph;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _ClefOption({
    required this.glyph,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 16),
          color: active ? AppColors.accent : AppColors.paper,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                glyph,
                style: AppTextStyles.display(size: 28).copyWith(
                  color: active ? Colors.white : AppColors.ink,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label.toUpperCase(),
                style: AppTextStyles.mono(
                  size: 11,
                  color: active ? Colors.white : AppColors.ink,
                  letterSpacing: 0.08,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
