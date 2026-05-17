import 'package:flutter/material.dart';
import 'package:key_starter/core/widgets/midi_pill.dart';
import 'package:key_starter/core/widgets/primary_icon_button.dart';

class ConceptTopBar extends StatelessWidget {
  const ConceptTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        PrimaryIconButton(
          icon: Icons.arrow_back_rounded,
          onTap: () => Navigator.of(context).pop(),
        ),
        const MidiPill(),
      ],
    );
  }
}
