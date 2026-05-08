import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:key_starter/features/session/domain/entities/session.dart';
import 'package:key_starter/features/session/presentation/providers/lesson_notifier.dart';

/// Boutons de réponse provisoires (test ✓ / ✗) qui simulent
/// ce que le MIDI déclenche automatiquement en production.
class LessonAnswerButtons extends ConsumerWidget {
  final Session session;

  const LessonAnswerButtons({super.key, required this.session});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(lessonNotifierProvider(session).notifier);

    return Column(
      children: [
        const Text('Joue la note sur ton clavier'),
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: notifier.onCorrect,
                child: const Text(
                  'test ✓',
                  style: TextStyle(color: Colors.green),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: notifier.onWrong,
                child: const Text(
                  'test ✗',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
