import 'package:flutter/material.dart';
import 'package:key_starter/core/enums/note_language.dart';
import 'package:key_starter/core/theme/app_colors.dart';
import 'package:key_starter/core/theme/app_text_styles.dart';

class NoteDisplayPicker extends StatelessWidget {
  final NoteLanguage? value; // null = off
  final ValueChanged<NoteLanguage?> onChanged;

  const NoteDisplayPicker({
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
          _Option(
            label: 'OFF',
            active: value == null,
            onTap: () => onChanged(null),
          ),
          Container(width: 1, color: AppColors.lineStrong),
          _Option(
            label: 'Do',
            active: value == NoteLanguage.fr,
            onTap: () => onChanged(NoteLanguage.fr),
          ),
          Container(width: 1, color: AppColors.lineStrong),
          _Option(
            label: 'C',
            active: value == NoteLanguage.en,
            onTap: () => onChanged(NoteLanguage.en),
          ),
        ],
      ),
    );
  }
}

class _Option extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _Option({
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
          padding: const EdgeInsets.symmetric(vertical: 14),
          color: active ? AppColors.accent : AppColors.paper,
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppTextStyles.ui(size: 15, weight: FontWeight.w600).copyWith(
              color: active ? Colors.white : AppColors.ink,
            ),
          ),
        ),
      ),
    );
  }
}
