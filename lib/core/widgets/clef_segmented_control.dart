import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:key_starter/core/enums/clef_mode.dart';
import 'package:key_starter/core/theme/app_colors.dart';
import 'package:key_starter/core/widgets/clef_option.dart';

/// Contrôle segmenté permettant de choisir entre la clef de Sol et la clef de Fa.
///
/// Classe abstraite : l'UI est définie ici, mais la source de données et
/// l'action sont fournis par la sous-classe via [value] et [onChanged].
///
/// Usage :
/// ```dart
/// class MyClefControl extends ClefSegmentedControl {
///   const MyClefControl({super.key});
///
///   @override
///   ClefMode value(WidgetRef ref) => ref.watch(myProvider).clef;
///
///   @override
///   void onChanged(WidgetRef ref, ClefMode clef) =>
///       ref.read(myProvider.notifier).setClef(clef);
/// }
/// ```
///
/// Voir aussi : [SessionClefSegmentedControl] pour l'implémentation liée
/// à la page de configuration de session.
abstract class ClefSegmentedControl extends ConsumerWidget {
  const ClefSegmentedControl({super.key});

  /// Retourne la clef actuellement sélectionnée.
  ClefMode value(WidgetRef ref);

  /// Appelé quand l'utilisateur sélectionne une nouvelle clef.
  void onChanged(WidgetRef ref, ClefMode clef);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentClef = value(ref);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.lineStrong),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          ClefOption(
            clef: ClefMode.treble,
            active: currentClef == ClefMode.treble,
            onSelect: (clef) => onChanged(ref, clef),
          ),
          Container(width: 1, color: AppColors.lineStrong),
          ClefOption(
            clef: ClefMode.bass,
            active: currentClef == ClefMode.bass,
            onSelect: (clef) => onChanged(ref, clef),
          ),
        ],
      ),
    );
  }
}
