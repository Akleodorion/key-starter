import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:key_starter/core/enums/clef_mode.dart';
import 'package:key_starter/core/widgets/staff_widget.dart';
import 'package:key_starter/features/session/domain/entities/session.dart';
import 'package:key_starter/features/session/presentation/providers/lesson_notifier.dart';
import 'package:key_starter/features/session/presentation/providers/lesson_state.dart';

/// Implémentation de [StaffWidget] liée à [lessonNotifierProvider].
class LessonStaffWidget extends StaffWidget {
  final Session session;

  const LessonStaffWidget({
    super.key,
    required this.session,
    super.height,
    super.staffwidth,
  });

  LessonInProgress? _inProgress(WidgetRef ref) {
    final lessonState = ref.watch(lessonNotifierProvider(session));
    return lessonState is LessonInProgress ? lessonState : null;
  }

  @override
  ClefMode clef(WidgetRef ref) => session.clef;

  @override
  int? diatonicStep(WidgetRef ref) => _inProgress(ref)?.currentStep;

  @override
  NoteState noteState(WidgetRef ref) {
    final inProgress = _inProgress(ref);
    if (inProgress == null) return NoteState.idle;
    return switch (inProgress.answer) {
      LessonAnswer.awaiting => NoteState.idle,
      LessonAnswer.correct => NoteState.correct,
      LessonAnswer.wrong => NoteState.wrong,
    };
  }
}
