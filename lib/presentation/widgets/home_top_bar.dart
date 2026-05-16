import 'package:flutter/material.dart';
import 'package:key_starter/core/widgets/midi_pill.dart';
import 'package:key_starter/core/widgets/primary_icon_button.dart';
import 'package:key_starter/presentation/widgets/app_brand.dart';

/// Barre supérieure de l'accueil : logo + nom à gauche, MIDI pill +
/// bouton réglages à droite.
class HomeTopBar extends StatelessWidget {
  const HomeTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AppBrand(),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [MidiPill(), SizedBox(width: 8), PrimaryIconButton(icon: Icons.tune_rounded)],
        ),
      ],
    );
  }
}
