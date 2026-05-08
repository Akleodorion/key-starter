import 'package:flutter/material.dart';
import 'package:key_starter/core/enums/note_language.dart';
import 'package:key_starter/core/enums/note_range_bound.dart';
import 'package:key_starter/core/theme/app_colors.dart';
import 'package:key_starter/core/theme/app_text_styles.dart';
import 'package:key_starter/core/utils/note_utils.dart';
import 'package:key_starter/core/widgets/arrow_button.dart';

/// Un contrôle MIN ou MAX au sein du [NoteRangeWidget].
///
/// Le label, la couleur et les callbacks haut/bas sont tous dérivés
/// de [bound], [step], [lowerLimit] et [upperLimit].
/// Seul [onChanged] reflète une action externe.
class NoteControl extends StatelessWidget {
  final NoteRangeBound bound;
  final int step;
  final NoteLanguage lang;
  final int lowerLimit;
  final int upperLimit;
  final void Function(int) onChanged;

  static const _labels = {NoteRangeBound.min: 'MIN', NoteRangeBound.max: 'MAX'};
  static const _colors = {
    NoteRangeBound.min: AppColors.accent,
    NoteRangeBound.max: AppColors.accentDeep,
  };

  const NoteControl({
    super.key,
    required this.bound,
    required this.step,
    required this.lang,
    required this.lowerLimit,
    required this.upperLimit,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(_labels[bound]!, style: AppTextStyles.eyebrow()),
          const SizedBox(height: 6),
          ArrowButton(
            icon: Icons.keyboard_arrow_up_rounded,
            onTap: step < upperLimit ? () => onChanged(step + 1) : null,
          ),
          const SizedBox(height: 2),
          Text(
            noteLabel(step, lang),
            style: AppTextStyles.ui(
              size: 18,
              weight: FontWeight.w600,
            ).copyWith(color: _colors[bound]!),
          ),
          const SizedBox(height: 2),
          ArrowButton(
            icon: Icons.keyboard_arrow_down_rounded,
            onTap: step > lowerLimit ? () => onChanged(step - 1) : null,
          ),
        ],
      ),
    );
  }
}
