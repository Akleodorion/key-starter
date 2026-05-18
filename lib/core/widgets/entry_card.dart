import 'package:flutter/material.dart';
import 'package:key_starter/core/models/card_entry.dart';
import 'package:key_starter/core/theme/app_color_theme.dart';
import 'package:key_starter/core/widgets/primary_icon_button.dart';
import 'package:key_starter/core/widgets/ui_text.dart';

class EntryCard extends StatelessWidget {
  final CardEntry entry;
  final VoidCallback? onTap;

  const EntryCard({super.key, required this.entry, this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = AppColorTheme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tint = isDark ? entry.darkTintColor : entry.tintColor;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(color: colors.line),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: tint,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Icon(entry.icon, color: entry.color, size: 24),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                UiText(entry.title, size: 17, weight: FontWeight.w700, color: colors.text),
                const SizedBox(height: 2),
                UiText(entry.description, size: 13, color: colors.text2),
              ],
            ),
          ),
          const SizedBox(width: 12),
          PrimaryIconButton(icon: Icons.chevron_right_rounded, onTap: onTap),
        ],
      ),
    );
  }
}
