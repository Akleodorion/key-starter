import 'package:flutter/material.dart';
import 'package:key_starter/core/enums/clef_mode.dart';
import 'package:key_starter/core/theme/app_colors.dart';
import 'package:key_starter/core/theme/app_text_styles.dart';

/// Une option cliquable du [ClefSegmentedControl].
///
/// Le glyphe et le label sont dérivés de [clef] — seul [active] reflète un état externe.
class ClefOption extends StatelessWidget {
  final ClefMode clef;
  final bool active;
  final void Function(ClefMode) onSelect;

  static const _glyphs = {ClefMode.treble: '𝄞', ClefMode.bass: '𝄢'};
  static const _labels = {ClefMode.treble: 'Sol', ClefMode.bass: 'Fa'};

  const ClefOption({
    super.key,
    required this.clef,
    required this.active,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () => onSelect(clef),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 16),
          color: active ? AppColors.accent : AppColors.paper,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _glyphs[clef]!,
                style: AppTextStyles.display(
                  size: 28,
                ).copyWith(color: active ? Colors.white : AppColors.ink),
              ),
              const SizedBox(height: 2),
              Text(
                _labels[clef]!.toUpperCase(),
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
