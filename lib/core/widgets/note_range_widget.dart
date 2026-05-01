import 'package:flutter/material.dart';
import 'package:key_starter/core/enums/clef_mode.dart';
import 'package:key_starter/core/enums/note_language.dart';
import 'package:key_starter/core/theme/app_colors.dart';
import 'package:key_starter/core/theme/app_text_styles.dart';
import 'package:key_starter/core/widgets/staff_range_widget.dart';

class NoteRangeWidget extends StatelessWidget {
  final ClefMode clef;
  final int minStep;
  final int maxStep;
  final NoteLanguage language;
  final ValueChanged<int> onMinChanged;
  final ValueChanged<int> onMaxChanged;

  const NoteRangeWidget({
    super.key,
    required this.clef,
    required this.minStep,
    required this.maxStep,
    this.language = NoteLanguage.fr,
    required this.onMinChanged,
    required this.onMaxChanged,
  });

  static const _minStepByClef = {
    ClefMode.treble: -3, // Sol 3
    ClefMode.bass: -17,  // Sol 1
  };
  static const _maxStepByClef = {
    ClefMode.treble: 15, // Ré 6
    ClefMode.bass: 3,    // Fa 4
  };

  static const _noteNamesEn = ['C', 'D', 'E', 'F', 'G', 'A', 'B'];
  static const _noteNamesFr = ['Do', 'Ré', 'Mi', 'Fa', 'Sol', 'La', 'Si'];

  String _noteLabel(int step) {
    final noteIndex = ((step % 7) + 7) % 7;
    final octave = 4 + (step - noteIndex) ~/ 7;
    final names = language == NoteLanguage.fr ? _noteNamesFr : _noteNamesEn;
    return '${names[noteIndex]} $octave';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [

        IntrinsicHeight(
          child: Row(
            children: [
              Expanded(
                child: _NoteControl(
                  label: 'MIN',
                  noteName: _noteLabel(minStep),
                  color: AppColors.accent,
                  onUp: minStep + 1 < maxStep
                      ? () => onMinChanged(minStep + 1)
                      : null,
                  onDown: minStep > _minStepByClef[clef]!
                      ? () => onMinChanged(minStep - 1)
                      : null,
                ),
              ),
              VerticalDivider(
                  width: 1, thickness: 1, color: AppColors.lineStrong),
              Expanded(
                child: _NoteControl(
                  label: 'MAX',
                  noteName: _noteLabel(maxStep),
                  color: AppColors.accentDeep,
                  onUp: maxStep < _maxStepByClef[clef]!
                      ? () => onMaxChanged(maxStep + 1)
                      : null,
                  onDown: maxStep - 1 > minStep
                      ? () => onMaxChanged(maxStep - 1)
                      : null,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 56),
          child: StaffRangeWidget(
            clef: clef,
            minDiatonicStep: minStep,
            maxDiatonicStep: maxStep,
            height: 100,
          ),
        ),
      ],
    );
  }
}

class _NoteControl extends StatelessWidget {
  final String label;
  final String noteName;
  final Color color;
  final VoidCallback? onUp;
  final VoidCallback? onDown;

  const _NoteControl({
    required this.label,
    required this.noteName,
    required this.color,
    this.onUp,
    this.onDown,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: AppTextStyles.eyebrow()),
          const SizedBox(height: 6),
          _ArrowButton(
            icon: Icons.keyboard_arrow_up_rounded,
            onTap: onUp,
          ),
          const SizedBox(height: 2),
          Text(
            noteName,
            style: AppTextStyles.ui(size: 18, weight: FontWeight.w600)
                .copyWith(color: color),
          ),
          const SizedBox(height: 2),
          _ArrowButton(
            icon: Icons.keyboard_arrow_down_rounded,
            onTap: onDown,
          ),
        ],
      ),
    );
  }
}

class _ArrowButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _ArrowButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(
          icon,
          size: 24,
          color: enabled ? AppColors.ink : AppColors.line,
        ),
      ),
    );
  }
}
