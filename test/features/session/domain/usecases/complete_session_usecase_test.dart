import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:key_starter/core/enums/clef_mode.dart';
import 'package:key_starter/core/enums/note_language.dart';
import 'package:key_starter/core/errors/failures.dart';
import 'package:key_starter/features/note_recognition/domain/entities/note.dart';
import 'package:key_starter/features/session/domain/entities/session.dart';
import 'package:key_starter/features/session/domain/entities/session_result.dart';
import 'package:key_starter/features/session/domain/repositories/session_repository.dart';
import 'package:key_starter/features/session/domain/usecases/complete_session_usecase.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'complete_session_usecase_test.mocks.dart';

@GenerateMocks([SessionRepository])
void main() {
  late MockSessionRepository mockRepository;
  late CompleteSessionUseCase sut;

  final tSession = Session(
    id: 'abc-123',
    clef: ClefMode.treble,
    minNote: const Note(midiNumber: 64, name: 'E', octave: 4),
    maxNote: const Note(midiNumber: 77, name: 'F', octave: 5),
    totalNotes: 25,
    showNoteName: false,
    language: NoteLanguage.fr,
    startedAt: DateTime(2026, 4, 25, 10, 0),
  );

  const tResult = SessionResult(
    correctCount: 22,
    totalNotes: 25,
    durationSec: 96,
    bestStreak: 14,
    avgResponseMs: 1240,
  );

  setUp(() {
    mockRepository = MockSessionRepository();
    sut = CompleteSessionUseCase(repository: mockRepository);
  });

  group('CompleteSessionUseCase', () {
    group('call', () {
      test('retourne la Session complétée depuis le repository', () {
        //arrange
        final tParams = CompleteSessionParams(session: tSession, result: tResult);
        final tCompletedSession = tSession.copyWith(result: tResult);
        when(mockRepository.completeSession(tParams))
            .thenReturn(Right(tCompletedSession));

        //act
        final result = sut(tParams);

        //assert
        expect(result, Right(tCompletedSession));
        expect((result as Right).value.isCompleted, isTrue);
        verify(mockRepository.completeSession(tParams));
        verifyNoMoreInteractions(mockRepository);
      });

      test('retourne SessionAlreadyCompletedFailure si la session est déjà terminée', () {
        //arrange
        final alreadyCompleted = tSession.copyWith(result: tResult);
        final tParams = CompleteSessionParams(
          session: alreadyCompleted,
          result: tResult,
        );
        when(mockRepository.completeSession(tParams))
            .thenReturn(const Left(SessionAlreadyCompletedFailure()));

        //act
        final result = sut(tParams);

        //assert
        expect(result, const Left(SessionAlreadyCompletedFailure()));
        verify(mockRepository.completeSession(tParams));
        verifyNoMoreInteractions(mockRepository);
      });
    });
  });
}
