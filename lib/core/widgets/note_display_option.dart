import 'package:flutter/material.dart';
import 'package:key_starter/core/enums/note_display_mode.dart';
import 'package:key_starter/core/theme/app_colors.dart';
import 'package:key_starter/core/theme/app_text_styles.dart';

/// Une option cliquable du [NoteDisplayPicker].
/// Le label est dérivé de [mode] — seul [active] reflète un état externe.
class NoteDisplayOption extends StatelessWidget {
  final NoteDisplayMode mode;
  final bool active;
  final void Function(NoteDisplayMode) onSelect;

  const NoteDisplayOption({
    super.key,
    required this.mode,
    required this.active,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () => onSelect(mode),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 14),
          color: active ? AppColors.accent : AppColors.paper,
          alignment: Alignment.center,
          child: Text(
            mode.label,
            style: AppTextStyles.ui(
              size: 15,
              weight: FontWeight.w600,
            ).copyWith(color: active ? Colors.white : AppColors.ink),
          ),
        ),
      ),
    );
  }
}
