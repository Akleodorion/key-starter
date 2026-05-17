import 'package:flutter/material.dart';
import 'package:key_starter/core/theme/app_text_styles.dart';
import 'package:key_starter/core/widgets/primary_icon_button.dart';

class SettingsTopBar extends StatelessWidget {
  const SettingsTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: PrimaryIconButton(
            icon: Icons.arrow_back_rounded,
            onTap: () => Navigator.of(context).pop(),
          ),
        ),
        Text('Réglages', style: AppTextStyles.display(size: 22)),
      ],
    );
  }
}
