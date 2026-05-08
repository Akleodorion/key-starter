import 'package:flutter/material.dart';
import 'package:key_starter/core/theme/app_colors.dart';
import 'package:key_starter/core/theme/app_text_styles.dart';
import 'package:key_starter/features/session/domain/entities/session.dart';
import 'package:key_starter/features/session/presentation/pages/lesson_page.dart';
import 'package:uuid/uuid.dart';

/// Boutons de fin de session : « Recommencer » repart avec les mêmes
/// paramètres vers [LessonPage] ; « Nouvelle session » remonte à la
/// configuration via [Navigator.pop].
class ResultsActions extends StatelessWidget {
  final Session session;

  const ResultsActions({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
          child: SizedBox(
            width: double.infinity,
            height: 54,
            child: OutlinedButton(
              onPressed: () {
                final fresh = Session(
                  id: const Uuid().v4(),
                  clef: session.clef,
                  minNote: session.minNote,
                  maxNote: session.maxNote,
                  totalNotes: session.totalNotes,
                  showNoteName: session.showNoteName,
                  language: session.language,
                  startedAt: DateTime.now(),
                );
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => LessonPage(session: fresh)),
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.accent,
                side: const BorderSide(color: AppColors.accent),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                'Recommencer',
                style: AppTextStyles.ui(
                  size: 16,
                  weight: FontWeight.w600,
                  color: AppColors.accent,
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: SizedBox(
            width: double.infinity,
            height: 54,
            child: FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.accent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                'Nouvelle session',
                style: AppTextStyles.ui(
                  size: 16,
                  weight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
