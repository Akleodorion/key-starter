import 'package:flutter/material.dart';
import 'package:key_starter/features/session/domain/entities/session.dart';
import 'package:key_starter/features/session/presentation/widgets/lesson_answer_buttons.dart';
import 'package:key_starter/features/session/presentation/widgets/lesson_note_card.dart';
import 'package:key_starter/features/session/presentation/widgets/lesson_top_bar.dart';

/// Layout principal de la session en cours : empile [LessonTopBar],
/// [LessonNoteCard] et [LessonAnswerButtons]. N'accède à aucun provider.
class LessonInProgressView extends StatelessWidget {
  final Session session;

  const LessonInProgressView({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F7),
      body: SafeArea(
        child: Column(
          children: [
            LessonTopBar(session: session),
            Expanded(child: LessonNoteCard(session: session)),
            LessonAnswerButtons(session: session),
          ],
        ),
      ),
    );
  }
}
