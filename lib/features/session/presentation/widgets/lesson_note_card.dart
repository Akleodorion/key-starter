import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:key_starter/core/utils/note_utils.dart';
import 'package:key_starter/features/session/domain/entities/session.dart';
import 'package:key_starter/features/session/presentation/providers/lesson_notifier.dart';
import 'package:key_starter/features/session/presentation/providers/lesson_state.dart';
import 'package:key_starter/features/session/presentation/widgets/lesson_staff_widget.dart';

/// Carte centrale affichant la note à jouer : nom de la note (si activé)
/// et portée musicale colorée selon la réponse via [LessonStaffWidget].
class LessonNoteCard extends ConsumerWidget {
  final Session session;

  const LessonNoteCard({super.key, required this.session});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state =
        ref.watch(lessonNotifierProvider(session)) as LessonInProgress;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        color: const Color.fromARGB(179, 247, 241, 229),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: double.infinity,
              child: Builder(
                builder: (context) {
                  final isLandscape =
                      MediaQuery.orientationOf(context) ==
                      Orientation.landscape;
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (session.showNoteName)
                        Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: isLandscape ? 8 : 24,
                          ),
                          child: Center(
                            child: Text(
                              noteLabel(state.currentStep, session.language),
                              style: TextStyle(fontSize: isLandscape ? 32 : 56),
                            ),
                          ),
                        ),
                      SizedBox(height: isLandscape ? 8 : 24),
                      LessonStaffWidget(
                        session: session,
                        height: isLandscape ? 70 : 100,
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
