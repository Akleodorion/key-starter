import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:key_starter/core/enums/note_display_mode.dart';
import 'package:key_starter/core/enums/note_language.dart';
import 'package:key_starter/core/theme/app_colors.dart';
import 'package:key_starter/core/widgets/note_display_option.dart';

/// Sélecteur abstrait du mode d'affichage du nom des notes (OFF / Do / C).
///
/// Affiche trois options côte à côte correspondant aux valeurs de
/// [NoteDisplayMode]. La conversion entre [NoteDisplayMode] et
/// [NoteLanguage?] est gérée en interne — les sous-classes travaillent
/// uniquement avec [NoteLanguage?] (null = pas d'affichage).
///
/// Les sous-classes fournissent la valeur courante et la réaction au
/// changement en implémentant [value] et [onChanged].
///
/// ```dart
/// class SessionNoteDisplayPicker extends NoteDisplayPicker {
///   const SessionNoteDisplayPicker({super.key});
///
///   @override
///   NoteLanguage? value(WidgetRef ref) {
///     final state = ref.watch(sessionSetupNotifierProvider);
///     return state is SessionSetupLoaded ? state.noteLanguage : null;
///   }
///
///   @override
///   void onChanged(WidgetRef ref, NoteLanguage? lang) =>
///       ref.read(sessionSetupNotifierProvider.notifier).setNoteLanguage(lang);
/// }
/// ```
///
/// Voir aussi : [SessionNoteDisplayPicker]
abstract class NoteDisplayPicker extends ConsumerWidget {
  const NoteDisplayPicker({super.key});

  /// Langue courante sélectionnée ; null correspond à l'option OFF.
  NoteLanguage? value(WidgetRef ref);

  /// Appelé quand l'utilisateur choisit une option ; [lang] est null pour OFF.
  void onChanged(WidgetRef ref, NoteLanguage? lang);

  static NoteDisplayMode _toMode(NoteLanguage? lang) => switch (lang) {
    null => NoteDisplayMode.off,
    NoteLanguage.fr => NoteDisplayMode.fr,
    NoteLanguage.en => NoteDisplayMode.en,
  };

  static NoteLanguage? _toLang(NoteDisplayMode mode) => switch (mode) {
    NoteDisplayMode.off => null,
    NoteDisplayMode.fr => NoteLanguage.fr,
    NoteDisplayMode.en => NoteLanguage.en,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentMode = _toMode(value(ref));
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.lineStrong),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: NoteDisplayMode.values
            .expand(
              (mode) => [
                if (mode != NoteDisplayMode.values.first)
                  Container(width: 1, color: AppColors.lineStrong),
                NoteDisplayOption(
                  mode: mode,
                  active: currentMode == mode,
                  onSelect: (selected) => onChanged(ref, _toLang(selected)),
                ),
              ],
            )
            .toList(),
      ),
    );
  }
}
