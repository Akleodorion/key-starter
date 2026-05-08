import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:key_starter/features/session/domain/entities/session.dart';
import 'package:key_starter/features/session/presentation/pages/results_page.dart';
import 'package:key_starter/features/session/presentation/providers/lesson_notifier.dart';
import 'package:key_starter/features/session/presentation/providers/lesson_state.dart';
import 'package:key_starter/features/session/presentation/widgets/lesson_in_progress_view.dart';

/// Point d'entrée d'une session de jeu.
///
/// Ce widget est un routeur d'état pur : il délègue chaque état de
/// [lessonNotifierProvider] à un widget dédié et utilise [ref.listen]
/// pour déclencher la navigation vers [ResultsPage] en effet de bord
/// (sans provoquer de rebuild) dès que la session est terminée.
class LessonPage extends ConsumerWidget {
  final Session session;

  const LessonPage({super.key, required this.session});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<LessonState>(lessonNotifierProvider(session), (_, next) {
      if (next is LessonCompleted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => ResultsPage(session: next.completedSession),
          ),
        );
      }
    });

    return switch (ref.watch(lessonNotifierProvider(session))) {
      LessonInProgress() => LessonInProgressView(session: session),
      LessonCompleted() => const SizedBox.shrink(),
    };
  }
}
