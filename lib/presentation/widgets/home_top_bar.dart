import 'package:flutter/material.dart';
import 'package:key_starter/core/widgets/input_source_pill.dart';
import 'package:key_starter/core/widgets/primary_icon_button.dart';
import 'package:key_starter/presentation/pages/settings_page.dart';
import 'package:key_starter/presentation/widgets/app_brand.dart';

/// Barre supérieure de l'accueil : logo + nom à gauche, MIDI pill +
/// bouton réglages à droite.
class HomeTopBar extends StatelessWidget {
  const HomeTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Le nom se réduit plutôt que de déborder à côté de « Aucune entrée »
        // quand la police est agrandie.
        const Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: AppBrand(),
          ),
        ),
        const SizedBox(width: 8),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const InputSourcePill(),
            const SizedBox(width: 8),
            PrimaryIconButton(
              icon: Icons.tune_rounded,
              onTap: () => Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const SettingsPage())),
            ),
          ],
        ),
      ],
    );
  }
}
