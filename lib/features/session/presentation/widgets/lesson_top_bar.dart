import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:key_starter/features/session/domain/entities/session.dart';
import 'package:key_starter/features/session/presentation/providers/lesson_notifier.dart';
import 'package:key_starter/features/session/presentation/providers/lesson_state.dart';

/// Barre supérieure de la session : bouton de fermeture, progression
/// (note courante / total) et compteur de bonnes réponses.
class LessonTopBar extends ConsumerWidget {
  final Session session;

  const LessonTopBar({super.key, required this.session});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state =
        ref.watch(lessonNotifierProvider(session)) as LessonInProgress;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: const SizedBox(
              width: 40,
              height: 40,
              child: Icon(Icons.close),
            ),
          ),
          SizedBox(
            width: 60,
            height: 36,
            child: Center(
              child: Text('${state.currentIndex} / ${session.totalNotes}'),
            ),
          ),
          SizedBox(
            width: 60,
            height: 36,
            child: Center(child: Text('✓ ${state.correctCount}')),
          ),
        ],
      ),
    );
  }
}
