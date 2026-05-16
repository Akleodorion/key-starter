import 'package:flutter/material.dart';
import 'package:key_starter/core/theme/app_colors.dart';
import 'package:key_starter/core/theme/app_text_styles.dart';

/// Badge indiquant l'état de connexion MIDI.
/// [deviceName] null = non connecté (point gris).
class MidiPill extends StatelessWidget {
  final String? deviceName;

  const MidiPill({super.key, this.deviceName});

  @override
  Widget build(BuildContext context) {
    final connected = deviceName != null;
    final dotColor = connected ? AppColors.intervalsFg : AppColors.text3;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 7),
          Text(
            connected ? deviceName! : 'Non connecté',
            style: AppTextStyles.ui(size: 11, weight: FontWeight.w500, color: AppColors.text2),
          ),
        ],
      ),
    );
  }
}
