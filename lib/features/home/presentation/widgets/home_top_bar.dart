import 'package:flutter/material.dart';
import 'package:key_starter/core/theme/app_colors.dart';
import 'package:key_starter/core/theme/app_text_styles.dart';
import 'package:key_starter/core/widgets/midi_pill.dart';

/// Barre supérieure de l'accueil : logo + nom à gauche, MIDI pill +
/// bouton réglages à droite.
class HomeTopBar extends StatelessWidget {
  final String? midiDeviceName;
  final VoidCallback? onSettingsTap;

  const HomeTopBar({
    super.key,
    this.midiDeviceName,
    this.onSettingsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // ── Logo + nom ────────────────────────────────────────────────────
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _AppLogo(),
            const SizedBox(width: 8),
            Text(
              'Key',
              style: AppTextStyles.ui(
                size: 17,
                weight: FontWeight.w700,
                color: AppColors.text,
              ),
            ),
          ],
        ),

        const Spacer(),

        // ── MIDI pill + réglages ──────────────────────────────────────────
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            MidiPill(deviceName: midiDeviceName),
            const SizedBox(width: 8),
            _SettingsButton(onTap: onSettingsTap),
          ],
        ),
      ],
    );
  }
}

class _AppLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: AppColors.text,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Center(
        child: Text(
          '◐',
          style: AppTextStyles.ui(
            size: 15,
            weight: FontWeight.w700,
            color: AppColors.surface,
          ),
        ),
      ),
    );
  }
}

class _SettingsButton extends StatelessWidget {
  final VoidCallback? onTap;

  const _SettingsButton({this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.line),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Center(
          child: Icon(
            Icons.tune_rounded,
            size: 15,
            color: AppColors.text2,
          ),
        ),
      ),
    );
  }
}
