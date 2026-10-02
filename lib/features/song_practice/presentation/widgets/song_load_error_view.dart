import 'package:flutter/material.dart';
import 'package:key_starter/core/theme/app_color_theme.dart';
import 'package:key_starter/core/widgets/ui_text.dart';

class SongLoadErrorView extends StatelessWidget {
  final String message;

  const SongLoadErrorView({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final colors = AppColorTheme.of(context);

    return Center(child: UiText(message, size: 15, color: colors.text2));
  }
}
