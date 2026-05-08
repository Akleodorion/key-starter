import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:key_starter/core/theme/app_colors.dart';
import 'package:key_starter/core/theme/app_text_styles.dart';

/// Slider abstrait pour choisir le nombre de notes d'une session (5–100).
///
/// Affiche un label « DURÉE DE LA SESSION », un [Slider] et la valeur
/// courante. Les bornes (5 / 100) sont fixes et gérées en interne.
///
/// Les sous-classes fournissent la valeur courante et la réaction au
/// changement en implémentant [value] et [onChanged].
///
/// ```dart
/// class SessionTotalNotesSlider extends SessionNotesSlider {
///   const SessionTotalNotesSlider({super.key});
///
///   @override
///   int value(WidgetRef ref) {
///     final state = ref.watch(sessionSetupNotifierProvider);
///     return state is SessionSetupLoaded ? state.totalNotes : 20;
///   }
///
///   @override
///   void onChanged(WidgetRef ref, int n) =>
///       ref.read(sessionSetupNotifierProvider.notifier).setTotalNotes(n);
/// }
/// ```
///
/// Voir aussi : [SessionTotalNotesSlider]
abstract class SessionNotesSlider extends ConsumerWidget {
  const SessionNotesSlider({super.key});

  /// Valeur courante du slider (nombre de notes).
  int value(WidgetRef ref);

  /// Appelé quand l'utilisateur déplace le slider ; [n] est la nouvelle valeur.
  void onChanged(WidgetRef ref, int n);

  static const _min = 5;
  static const _max = 100;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTotalNotes = value(ref);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('DURÉE DE LA SESSION', style: AppTextStyles.eyebrow()),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: Slider(
                value: currentTotalNotes.toDouble(),
                min: _min.toDouble(),
                max: _max.toDouble(),
                onChanged: (totalNotes) => onChanged(ref, totalNotes.round()),
              ),
            ),
            SizedBox(
              width: 44,
              child: Text(
                '$currentTotalNotes',
                style: AppTextStyles.ui(
                  size: 18,
                  weight: FontWeight.w600,
                ).copyWith(color: AppColors.accent),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$_min', style: AppTextStyles.mono(size: 11)),
              Text('$_max', style: AppTextStyles.mono(size: 11)),
            ],
          ),
        ),
      ],
    );
  }
}
